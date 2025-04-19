import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' show cos, pow;
import 'package:ujikom/app/data/schedule_respones.dart';
import 'package:ujikom/app/data/store_attendance_response.dart';
import 'package:ujikom/app/utils/api.dart';

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

class AttendancesController extends GetxController {
  // Core variables
  final schedule = Rxn<ScheduleResponse>();
  final box = GetStorage();
  final _getConnect = GetConnect();
  final mapController = MapController();
  final RxInt radiusInMeters = 100.obs;

  // Location variables
  StreamSubscription<Position>? _positionStream;
  final locationStatus = ''.obs;
  final RxDouble currentZoom = 15.0.obs;
  final RxBool showOfficeLocation = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isWithinRadius = false.obs;
  final Rx<LatLng> userCoords = LatLng(-6.995927, 107.593684).obs;
  final Rx<LatLng> officeCoords = LatLng(-6.967105, 107.592861).obs;

  // Camera variables
  final RxBool isCameraInitialized = false.obs;
  final RxString webImageData = ''.obs;
  final RxString selectedImagePath = ''.obs;
  late html.VideoElement videoElement;
  late html.CanvasElement canvasElement;
  String viewId = 'webcam-view';
  html.MediaStream? _mediaStream;

  @override
  void onInit() {
    super.onInit();
    requestPermissions();
    fetchSchedule();
    _initializeWebCamera();
  }

  @override
  void onClose() {
    _positionStream?.cancel();
    stopWebCamera();
    super.onClose();
  }

  // LOCATION METHODS
  Future<void> requestPermissions() async {
    await Permission.location.request();
    _startLocationTracking();
  }

  void _startLocationTracking() async {
    // Check if location services are enabled
    if (!await Geolocator.isLocationServiceEnabled()) {
      locationStatus.value =
          'Layanan lokasi dinonaktifkan. Silakan aktifkan GPS di perangkat Anda.';
      return;
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
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

    locationStatus.value = '';

    // Get current position
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _updateUserLocation(position);
    } catch (e) {
      locationStatus.value = 'Gagal mendapatkan lokasi: $e';
    }

    // Start position stream
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(
      _updateUserLocation,
      onError: (e) => locationStatus.value = 'Error dari layanan lokasi: $e',
    );
  }

  void _updateUserLocation(Position position) {
    userCoords.value = LatLng(position.latitude, position.longitude);

    // Update map if showing user location
    if (!showOfficeLocation.value) {
      mapController.move(userCoords.value, currentZoom.value);
    }

    _calculateDistanceFromOffice();
  }

  void _calculateDistanceFromOffice() {
    final distance = Geolocator.distanceBetween(
      userCoords.value.latitude,
      userCoords.value.longitude,
      officeCoords.value.latitude,
      officeCoords.value.longitude,
    );

    isWithinRadius.value = distance <= radiusInMeters.value;
  }

  // MAP METHODS
  void moveToLocation(LatLng location, double zoom) {
    mapController.move(location, zoom);
    currentZoom.value = zoom;
  }

  void toggleLocationView() {
    showOfficeLocation.value = !showOfficeLocation.value;
    moveToLocation(
        showOfficeLocation.value ? officeCoords.value : userCoords.value,
        showOfficeLocation.value ? 15.0 : 17.0);
  }

  double calculateRadiusInPixels() {
    final metersPerPixel = 156543.03392 *
        cos(officeCoords.value.latitude * pi / 180) /
        pow(2, currentZoom.value);
    return radiusInMeters.value / metersPerPixel;
  }

  // API METHODS
  Future<String?> getToken() async => await box.read('token');

  Future<void> fetchSchedule() async {
    try {
      final token = await getToken();
      if (token == null)
        throw Exception("Token tidak ditemukan, silakan login kembali.");

      final response = await _getConnect.get(
        BaseUrl.attendanceSchedule,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        schedule.value = ScheduleResponse.fromJson(response.body);

        // Update office coordinates and radius if available
        if (schedule.value?.data?.office?.latitude != null &&
            schedule.value?.data?.office?.longitude != null) {
          final officeLat = schedule.value!.data!.office!.latitude;
          final officeLng = schedule.value!.data!.office!.longitude;

          if (officeLat != null && officeLng != null) {
            officeCoords.value = LatLng(officeLat, officeLng);

            // Update radius if available
            if (schedule.value?.data?.office?.radius != null) {
              radiusInMeters.value = schedule.value!.data!.office!.radius!;
            }

            _calculateDistanceFromOffice();
          }
        }
      } else {
        throw Exception("Gagal mengambil jadwal: ${response.statusText}");
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data jadwal: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // CAMERA METHODS
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

  void _initializeWebCamera() {
    videoElement = html.VideoElement()
      ..id = 'webcamVideo'
      ..autoplay = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover';

    canvasElement = html.CanvasElement(width: 640, height: 480);

    ui_web.platformViewRegistry
        .registerViewFactory(viewId, (int viewId) => videoElement);
  }

  Future<bool> requestCameraPermission() async {
    try {
      final stream = await html.window.navigator.mediaDevices
          ?.getUserMedia({'video': true, 'audio': false});

      if (stream != null) {
        final tracks = stream.getTracks();
        for (var track in tracks) {
          track.stop();
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> startWebCamera() async {
    stopWebCamera();
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 1280},
          'height': {'ideal': 720}
        },
        'audio': false
      });

      if (stream != null) {
        _mediaStream = stream;
        videoElement.srcObject = stream;

        try {
          await videoElement.onLoadedMetadata.first
              .timeout(const Duration(seconds: 3), onTimeout: () {
            return html.Event('timeout');
          });
        } catch (e) {}

        try {
          await videoElement.play();
        } catch (e) {}

        isCameraInitialized.value = true;
        return true;
      } else {
        Get.snackbar('Error', 'Tidak dapat mengakses kamera',
            backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal akses kamera: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
      isCameraInitialized.value = false;
      return false;
    }
  }

  void stopWebCamera() {
    try {
      if (_mediaStream != null) {
        final tracks = _mediaStream!.getTracks();
        for (var track in tracks) {
          track.stop();
        }
        _mediaStream = null;
      }

      videoElement.srcObject = null;
      videoElement.pause();
      isCameraInitialized.value = false;
    } catch (e) {}
  }

  Future<bool> reinitializeCamera() async {
    stopWebCamera();

    // Reset video element completely
    videoElement.srcObject = null;
    videoElement.pause();
    isCameraInitialized.value = false;

    // Create fresh elements
    videoElement = html.VideoElement()
      ..id = 'webcamVideo-${DateTime.now().millisecondsSinceEpoch}'
      ..autoplay = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover';

    // Update view ID
    viewId = 'webcam-view-${DateTime.now().millisecondsSinceEpoch}';
    ui_web.platformViewRegistry
        .registerViewFactory(viewId, (int viewId) => videoElement);

    // Clear image data
    webImageData.value = '';
    if (selectedImagePath.value == 'web_camera_image') {
      selectedImagePath.value = '';
    }

    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 1280},
          'height': {'ideal': 720}
        },
        'audio': false
      });

      if (stream == null) return false;

      _mediaStream = stream;
      videoElement.srcObject = stream;

      try {
        await videoElement.onLoadedMetadata.first
            .timeout(const Duration(seconds: 3), onTimeout: () {
          return html.Event('timeout');
        });
      } catch (e) {}

      try {
        await videoElement.play();
      } catch (e) {
        return false;
      }

      isCameraInitialized.value = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Main capture method that redirects to web implementation
  Future<void> captureImage() async {
    await _captureImageWeb();
  }

  // Web-specific capture implementation
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
      webImageData.value = canvasElement.toDataUrl('image/jpeg');
      selectedImagePath.value = 'web_camera_image';

      // Stop camera and close dialog
      stopWebCamera();
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

  // Send attendance data to API
  Future<void> sendAttendance({bool isCheckout = false}) async {
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

    // If already loading or no image, don't proceed
    if (isLoading.value || selectedImagePath.isEmpty) return;

    // Start loading state
    isLoading.value = true;

    try {
      final token = await getToken();
      if (token == null) {
        throw Exception("Token tidak ditemukan, silakan login kembali.");
      }

      // For Web platform, we need to convert base64 to MultipartFile
      if (webImageData.isEmpty) {
        throw Exception("Data gambar tidak tersedia");
      }

      // Extract base64 data without header
      final base64Image = webImageData.value
          .replaceFirst(RegExp(r'data:image/jpeg;base64,'), '');

      // Create form data for multipart request
      final FormData formData = FormData({
        // Send coordinates directly as numbers, not as strings
        'latitude': userCoords.value.latitude,
        'longitude': userCoords.value.longitude,
        'is_wfa': isWfa ? '1' : '0',
        // Convert base64 to MultipartFile for photo
        'photo': MultipartFile(
          base64Decode(base64Image),
          filename: 'camera_photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: 'image/jpeg',
        ),
      });

      // Add checkout flag if it's checkout attendance
      if (isCheckout) {
        formData.fields.add(MapEntry('is_checkout', '1'));
      }

      // Print debugging info
      print('Sending attendance data to: ${BaseUrl.storeAttendance}');
      print(
          'Request data includes photo with size: ${base64Image.length * 3 ~/ 4} bytes');

      // Send data to backend API as multipart form
      final response = await _getConnect.post(
        BaseUrl.storeAttendance,
        formData,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      // Print response info
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse response
        final storeResponse = StoreAttendanceResponse.fromJson(response.body);

        // Reset form state after successful submission
        selectedImagePath.value = '';
        webImageData.value = '';

        // Show success message based on check-in or check-out
        final attendanceType =
            storeResponse.data?.tipe ?? (isCheckout ? 'pulang' : 'masuk');
        Get.snackbar(
          'Sukses',
          attendanceType == 'pulang'
              ? 'Kehadiran pulang berhasil dicatat'
              : 'Kehadiran masuk berhasil dicatat',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      } else {
        throw Exception(
            "Gagal mengirim data: ${response.statusText} - ${response.body}");
      }
    } catch (e) {
      // Print error info
      print('Error sending attendance: $e');

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
    stopWebCamera();
    webImageData.value = '';
    selectedImagePath.value = '';
    isLoading.value = false;
  }

  // HELPER GETTERS
  bool get canSubmitAttendance => isWithinRadius.value || isWfa;
  bool get isScheduleLoaded => schedule.value != null;
  bool get isScheduleDataAvailable =>
      schedule.value != null && schedule.value!.data != null;
  String get officeName => schedule.value?.data?.office?.name ?? 'Nama Kantor';
  String get shiftName => schedule.value?.data?.shift?.name ?? 'Shift';
  String get shiftTime {
    final startTime = schedule.value?.data?.shift?.startTime ?? '00:00:00';
    final endTime = schedule.value?.data?.shift?.endTime ?? '00:00:00';
    return '$startTime - $endTime';
  }

  bool get isWfa => schedule.value?.data?.isWfa == true;
  Color get tagColor => isWfa ? Colors.green : Colors.amber;
  String get tagText => isWfa ? 'WFA' : 'WFO';
}
