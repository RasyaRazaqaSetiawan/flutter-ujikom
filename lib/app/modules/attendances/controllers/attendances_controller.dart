// Web-Only AttendancesController.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' show cos, pow;
import 'package:ujikom/app/data/schedule_respones.dart';
import 'package:ujikom/app/utils/api.dart';

import 'dart:html' as html;
import 'package:flutter/services.dart';
import 'dart:ui_web' as ui_web;

class AttendancesController extends GetxController {
  final schedule = Rxn<ScheduleResponse>();

  // Storage for token
  final box = GetStorage();

  // API Connection
  final _getConnect = GetConnect();

  // Map controller to track zoom changes
  final mapController = MapController();

  // Radius in meters for the circle (now reactive)
  final RxInt radiusInMeters =
      100.obs; // Default radius 100m, will be updated from API

  // Location tracking
  StreamSubscription<Position>? _positionStream;
  final locationStatus = ''.obs;

  // Rx variables for reactive state
  final RxDouble currentZoom = 15.0.obs;
  final RxBool showOfficeLocation = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isWithinRadius = false.obs;
  final RxString selectedImagePath = ''.obs;

  // Web camera variables
  final RxBool isCameraInitialized = false.obs;
  final RxString webImageData = ''.obs;
  late html.VideoElement videoElement;
  late html.CanvasElement canvasElement;
  String viewId = 'webcam-view';
  html.MediaStream? _mediaStream; // Store media stream for proper cleanup

  // Coordinates
  final Rx<LatLng> userCoords =
      LatLng(-6.995927, 107.593684).obs; // Default location
  final Rx<LatLng> officeCoords =
      LatLng(-6.967105, 107.592861).obs; // Default office location

  @override
  void onInit() {
    super.onInit();

    // Request necessary permissions
    requestPermissions();

    // Fetch schedule data when controller is initialized
    fetchSchedule();

    // Setup webcam for web
    _initializeWebCamera();
  }

  @override
  void onClose() {
    // Cancel location stream subscription
    _positionStream?.cancel();
    
    stopWebCamera();

    super.onClose();
  }

  // Request necessary permissions
  Future<void> requestPermissions() async {
    // Request location permission
    await Permission.location.request();

    // Start tracking location after permissions granted
    _startLocationTracking();
  }

  // Start tracking user location
  void _startLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      locationStatus.value =
          'Layanan lokasi dinonaktifkan. Silakan aktifkan GPS di perangkat Anda.';
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        locationStatus.value =
            'Izin lokasi ditolak. Aplikasi memerlukan izin lokasi untuk mencatat kehadiran.';
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      locationStatus.value =
          'Izin lokasi ditolak secara permanen. Silakan ubah pengaturan izin lokasi di perangkat Anda.';
      return;
    }

    // Clear any previous error status
    locationStatus.value = '';

    // Get current position immediately
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _updateUserLocation(position);
    } catch (e) {
      print('Error getting initial position: $e');
      locationStatus.value = 'Gagal mendapatkan lokasi: $e';
    }

    // Then start listening to position updates
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters movement
      ),
    ).listen(
      _updateUserLocation,
      onError: (e) {
        print('Error from location stream: $e');
        locationStatus.value = 'Error dari layanan lokasi: $e';
      },
    );
  }

  // Update user location
  void _updateUserLocation(Position position) {
    userCoords.value = LatLng(position.latitude, position.longitude);

    // If we're showing user location, update the map center
    if (!showOfficeLocation.value) {
      mapController.move(userCoords.value, currentZoom.value);
    }

    // Recalculate distance from office
    _calculateDistanceFromOffice();
  }

  // Calculate distance from office
  void _calculateDistanceFromOffice() {
    final distance = Geolocator.distanceBetween(
      userCoords.value.latitude,
      userCoords.value.longitude,
      officeCoords.value.latitude,
      officeCoords.value.longitude,
    );

    isWithinRadius.value = distance <= radiusInMeters.value;
  }

  // Helper method to check if attendance can be submitted
  bool get canSubmitAttendance => isWithinRadius.value || isWfa;

  // Get token from storage
  Future<String?> getToken() async {
    return await box.read('token');
  }

  // Fetch schedule data from API
  Future<void> fetchSchedule() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception("Token tidak ditemukan, silakan login kembali.");
      }

      final response = await _getConnect.get(
        BaseUrl.schedule,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        schedule.value = ScheduleResponse.fromJson(response.body);

        // If office coordinates are available in the schedule data, use them
        if (schedule.value?.data?.office?.latitude != null &&
            schedule.value?.data?.office?.longitude != null) {
          final officeLat = schedule.value!.data!.office!.latitude;
          final officeLng = schedule.value!.data!.office!.longitude;

          if (officeLat != null && officeLng != null) {
            officeCoords.value = LatLng(officeLat, officeLng);

            // Update radius if available in the schedule data
            if (schedule.value?.data?.office?.radius != null) {
              final officeRadius = schedule.value!.data!.office!.radius;
              if (officeRadius != null) {
                radiusInMeters.value = officeRadius;
              }
            }

            // Recalculate distance after getting office location and radius
            _calculateDistanceFromOffice();
          }
        }
      } else {
        throw Exception("Gagal mengambil jadwal: ${response.statusText}");
      }
    } catch (e) {
      print("Error saat mengambil data jadwal: $e");
      Get.snackbar(
        'Error',
        'Gagal memuat data jadwal: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Method to move map to a specific location
  void moveToLocation(LatLng location, double zoom) {
    mapController.move(location, zoom);
    currentZoom.value = zoom;
  }

  // Method to toggle displayed location (office or user)
  void toggleLocationView() {
    showOfficeLocation.value = !showOfficeLocation.value;
    moveToLocation(
        showOfficeLocation.value ? officeCoords.value : userCoords.value,
        showOfficeLocation.value ? 15.0 : 17.0);
  }

  // Method to calculate radius in pixels based on zoom level
  double calculateRadiusInPixels() {
    final metersPerPixel = 156543.03392 *
        cos(officeCoords.value.latitude * pi / 180) /
        pow(2, currentZoom.value);
    return radiusInMeters.value / metersPerPixel;
  }

  Future<bool> requestCameraPermission() async {
    // For web, we'll use the browser's mediaDevices API directly
    try {
      // Just request access to verify permission - we'll properly initialize later
      final stream = await html.window.navigator.mediaDevices
          ?.getUserMedia({'video': true, 'audio': false});

      // If we get here, permission was granted
      // We immediately stop the stream since we're just checking permission
      if (stream != null) {
        final tracks = stream.getTracks();
        for (var track in tracks) {
          track.stop();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Camera permission denied: $e');
      return false;
    }
  }

  // Initialize web camera
  void _initializeWebCamera() {
    // Create video and canvas elements
    videoElement = html.VideoElement()
      ..id = 'webcamVideo'
      ..autoplay = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover';

    canvasElement = html.CanvasElement(width: 640, height: 480);

    // Register view factory using ui_web for newer Flutter versions
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
      return videoElement;
    });
  }

  // Start web camera stream with improved error handling
  Future<bool> startWebCamera() async {
    // Always ensure we're starting with a clean state
    stopWebCamera();

    // Make sure to wait long enough for browser resources to be released
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Request camera permission and access
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': {
          'facingMode': 'user', // Use front camera
          'width': {'ideal': 1280},
          'height': {'ideal': 720}
        },
        'audio': false
      });

      if (stream != null) {
        _mediaStream = stream;

        // Create fresh video element for each camera start
        videoElement.srcObject = stream;

        // Wait for the video to be ready
        try {
          await videoElement.onLoadedMetadata.first
              .timeout(const Duration(seconds: 3), onTimeout: () {
            print('Metadata loading timed out, continuing anyway');
            return html.Event('timeout');
          });
        } catch (e) {
          print('Error waiting for metadata: $e');
        }

        // Explicitly play the video
        try {
          await videoElement.play();
        } catch (e) {
          print('Error playing video: $e');
        }

        isCameraInitialized.value = true;
        return true;
      } else {
        Get.snackbar('Error', 'Tidak dapat mengakses kamera',
            backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print('Error accessing camera: $e');
      Get.snackbar('Error', 'Gagal akses kamera: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
      isCameraInitialized.value = false;
      return false;
    }
  }

  // Stop web camera stream with improved cleanup
  void stopWebCamera() {
    try {
      if (_mediaStream != null) {
        final tracks = _mediaStream!.getTracks();
        for (var track in tracks) {
          track.stop();
        }
        _mediaStream = null;
      }

      // Completely clear video source
      videoElement.srcObject = null;
      videoElement.pause();

      isCameraInitialized.value = false;
    } catch (e) {
      print('Error stopping web camera: $e');
    }
  }

  // Reset camera state for retrying
  void resetCameraState() {
    stopWebCamera();

    // Force garbage collection of video element
    videoElement.srcObject = null;

    // Re-create the video element instead of reusing it
    videoElement = html.VideoElement()
      ..id = 'webcamVideo'
      ..autoplay = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover';

    // Re-register the view factory with the new element
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
      return videoElement;
    });

    webImageData.value = '';
    if (selectedImagePath.value == 'web_camera_image') {
      selectedImagePath.value = '';
    }
  }

  Future<bool> reinitializeCamera() async {
    // Full cleanup of existing camera resources
    stopWebCamera();

    // Cancel any existing streams
    if (_mediaStream != null) {
      final tracks = _mediaStream!.getTracks();
      for (var track in tracks) {
        track.stop();
      }
      _mediaStream = null;
    }

    // Reset video element completely
    videoElement.srcObject = null;
    videoElement.pause();

    // Clear memory references
    isCameraInitialized.value = false;

    // Create fresh elements to avoid stale references
    videoElement = html.VideoElement()
      ..id = 'webcamVideo-${DateTime.now().millisecondsSinceEpoch}'
      ..autoplay = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover';

    // Update the view ID to force new registration
    viewId = 'webcam-view-${DateTime.now().millisecondsSinceEpoch}';

    // Re-register with new view ID to avoid conflicts
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
      return videoElement;
    });

    // Clear any existing image data
    webImageData.value = '';
    if (selectedImagePath.value == 'web_camera_image') {
      selectedImagePath.value = '';
    }

    // Wait for browser to clean up resources
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // Request camera access with explicit constraints
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 1280},
          'height': {'ideal': 720}
        },
        'audio': false
      });

      if (stream == null) {
        print('Stream is null - camera access failed');
        return false;
      }

      _mediaStream = stream;

      // Ensure video element is properly connected to stream
      videoElement.srcObject = stream;

      // Wait for metadata to be loaded
      try {
        await videoElement.onLoadedMetadata.first
            .timeout(const Duration(seconds: 3), onTimeout: () {
          print('Metadata loading timed out, continuing anyway');
          return html.Event('timeout');
        });
      } catch (e) {
        print('Error waiting for metadata: $e');
      }

      // Explicitly play the video with error handling
      try {
        await videoElement.play();
      } catch (e) {
        print('Error playing video: $e');
        return false;
      }

      isCameraInitialized.value = true;
      return true;
    } catch (e) {
      print('Error initializing camera: $e');
      return false;
    }
  }

  // Capture image - main method for web
  Future<void> captureImage() async {
    await _captureImageWeb();
  }

  // Capture image on web platform
  Future<void> _captureImageWeb() async {
    if (!isCameraInitialized.value) {
      final success = await startWebCamera();
      if (!success) {
        Get.snackbar('Error', 'Gagal memulai kamera. Coba lagi.',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
      return;
    }

    try {
      // Capture from video to canvas
      canvasElement.width = videoElement.videoWidth;
      canvasElement.height = videoElement.videoHeight;
      final context = canvasElement.context2D;
      context.drawImage(videoElement, 0, 0);

      // Convert to base64
      final dataUrl = canvasElement.toDataUrl('image/jpeg');
      webImageData.value = dataUrl;

      // Set path so UI knows image data exists
      selectedImagePath.value = 'web_camera_image';

      // Stop camera after capture
      stopWebCamera();

      Get.snackbar('Sukses', 'Foto berhasil diambil',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil foto: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Capture image on web platform with better UI feedback
  Future<void> captureWebImage() async {
    if (!isCameraInitialized.value) {
      Get.snackbar(
        'Error',
        'Kamera belum siap, coba lagi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Capture from video to canvas
      canvasElement.width = videoElement.videoWidth;
      canvasElement.height = videoElement.videoHeight;
      final context = canvasElement.context2D;
      context.drawImage(videoElement, 0, 0);

      // Convert to base64
      final dataUrl = canvasElement.toDataUrl('image/jpeg');
      webImageData.value = dataUrl;

      // Set path so UI knows image data exists
      selectedImagePath.value = 'web_camera_image';

      // Stop camera after capture
      stopWebCamera();

      // Automatically close the dialog after successful capture
      Get.back();

      Get.snackbar(
        'Sukses',
        'Foto berhasil diambil',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil foto: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Send attendance data
  Future<void> sendAttendance() async {
    // Check if within radius or WFA is allowed
    if (!canSubmitAttendance) {
      Get.dialog(
        AlertDialog(
          title: const Text('Di Luar Area'),
          content: const Text(
              'Anda berada di luar area kantor. Kehadiran tidak dapat dicatat.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // If already loading, don't proceed
    if (isLoading.value) return;

    // If no image yet, this method should not be called directly
    // The UI should check first and open camera instead
    if (selectedImagePath.isEmpty) {
      return;
    }

    // Start loading state
    isLoading.value = true;

    try {
      final token = await getToken();
      if (token == null) {
        throw Exception("Token tidak ditemukan, silakan login kembali.");
      }

      // Prepare data to send
      Map<String, dynamic> formData = {
        'latitude': userCoords.value.latitude.toString(),
        'longitude': userCoords.value.longitude.toString(),
        'is_wfa': isWfa ? '1' : '0',
      };

      // Handle image for web
      if (webImageData.isEmpty) {
        throw Exception("Data gambar tidak tersedia");
      }
      // For web, send base64 image
      formData['photo'] = webImageData.value
          .replaceFirst(RegExp(r'data:image/jpeg;base64,'), '');

      /* 
      // Uncomment when API is ready
      final response = await _getConnect.post(
        BaseUrl.attendance,
        formData,
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode != 200) {
        throw Exception("Gagal mengirim kehadiran: ${response.statusText}");
      }
      */

      // Simulate data sending process for 1.5 seconds
      await Future.delayed(const Duration(milliseconds: 1500));

      // Reset form state after successful submission
      selectedImagePath.value = '';
      webImageData.value = '';

      Get.snackbar(
        'Sukses',
        isWfa
            ? 'Kehadiran berhasil dicatat (WFA Mode)'
            : 'Kehadiran berhasil dicatat',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengirim kehadiran: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    // Reset camera states
    stopWebCamera();
    webImageData.value = '';

    // Reset image selection
    selectedImagePath.value = '';

    // Reset loading state
    isLoading.value = false;
  }

  // Helper method to check if schedule data is loaded
  bool get isScheduleLoaded => schedule.value != null;

  // Helper method to check if schedule data is available
  bool get isScheduleDataAvailable =>
      schedule.value != null && schedule.value!.data != null;

  // Getter for office name
  String get officeName => schedule.value?.data?.office?.name ?? 'Nama Kantor';

  // Getter for shift name
  String get shiftName => schedule.value?.data?.shift?.name ?? 'Shift';

  // Getter for shift time
  String get shiftTime {
    final startTime = schedule.value?.data?.shift?.startTime ?? '00:00:00';
    final endTime = schedule.value?.data?.shift?.endTime ?? '00:00:00';
    return '$startTime - $endTime';
  }

  // Getter for WFA/WFO status
  bool get isWfa => schedule.value?.data?.isWfa == true;

  // Getter for WFA/WFO tag color
  Color get tagColor => isWfa ? Colors.green : Colors.amber;

  // Getter for WFA/WFO tag text
  String get tagText => isWfa ? 'WFA' : 'WFO';
}