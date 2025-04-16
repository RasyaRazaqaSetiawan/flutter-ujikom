import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ujikom/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:ujikom/app/modules/dashboard/views/dashboard_view.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ujikom/app/modules/attendances/controllers/attendances_controller.dart';

class AttendancesView extends GetView<AttendancesController> {
  const AttendancesView({super.key});

  @override
  Widget build(BuildContext context) {
    // Use lazyPut to register controller only if it's not already registered
    Get.lazyPut(() => AttendancesController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: Obx(() {
        // Check if location permission has been denied
        if (controller.locationStatus.isNotEmpty) {
          return _buildLocationErrorWidget();
        }

        // Check if schedule data is loaded
        if (!controller.isScheduleLoaded) {
          return _buildLoadingWidget();
        }

        if (!controller.isScheduleDataAvailable) {
          return const Center(child: Text('No schedule data available'));
        }

        return Column(
          children: [
            Expanded(child: _buildMap()),
            const SizedBox(height: 16),
            _buildInfoCard(),
            _buildImagePreview(context),
            const SizedBox(height: 16),
            _buildAttendanceButton(context), // Pass context here
            const SizedBox(height: 20),
          ],
        );
      }),
    );
  }

  // Fixed _buildImagePreview for handling both web and mobile
  Widget _buildImagePreview(BuildContext context) {
    return Obx(() {
      if (controller.selectedImagePath.isEmpty) {
        // Return an empty container or a minimal placeholder instead of the text instructions
        return const SizedBox
            .shrink(); // This will completely remove the section
      }

      // Keep the rest of the method as is (for when an image is selected)
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Foto Kehadiran',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // For web, show the camera dialog again
                      if (kIsWeb) {
                        _showWebCameraDialog(context);
                      } else {
                        // For mobile, just call captureImage
                        controller.captureImage();
                      }
                    },
                    icon: const Icon(Icons.camera_alt, size: 16),
                    label: Text(
                      'Ambil Ulang',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF4051B5),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: kIsWeb
                    ? controller.selectedImagePath.value == 'web_camera_image'
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                controller.webImageData.value,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 40,
                              ),
                            ),
                          )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(controller.selectedImagePath.value),
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Web camera dialog implementation with improved black screen handling
  void _showWebCameraDialog(BuildContext context) {
    if (kIsWeb) {
      // Completely reset camera state before showing dialog
      controller.resetCameraState();

      // Wait for resources to be released
      Future.delayed(const Duration(milliseconds: 300), () {
        // Show dialog with loading state
        Get.dialog(
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ambil Foto Kehadiran',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pastikan wajah terlihat jelas pada kamera',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Use Future.delayed to ensure DOM is ready before camera init
                  FutureBuilder(
                    future: Future.delayed(
                      const Duration(milliseconds: 500),
                      () => controller.reinitializeCamera(),
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingCameraView();
                      } else {
                        return _buildInitializedCameraView();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
      });
    }
  }

  Widget _buildLoadingCameraView() {
    return Column(
      children: [
        Container(
          height: 350,
          width: 350,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Menginisialisasi kamera...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            controller.stopWebCamera();
            Get.back();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.black87,
          ),
          child: const Text('Batal'),
        ),
      ],
    );
  }

  Widget _buildInitializedCameraView() {
    return Obx(() => Column(
          children: [
            Container(
              height: 350,
              width: 350,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: controller.isCameraInitialized.value
                    ? HtmlElementView(viewType: controller.viewId)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Tidak dapat mengakses kamera',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              controller.reinitializeCamera();
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    controller.stopWebCamera();
                    Get.back();
                  },
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Batal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: controller.isCameraInitialized.value
                      ? () {
                          controller.captureWebImage();
                          Get.back();
                        }
                      : null,
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Ambil Foto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4051B5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  // Build Location Error Widget
  Widget _buildLocationErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Akses Lokasi Dibutuhkan',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.locationStatus.value,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4051B5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => controller.requestPermissions(),
              child: Text(
                'Izinkan Akses Lokasi',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build Loading Widget
  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.indigo,
          ),
          SizedBox(height: 16),
          Text(
            "Memuat data...",
            style: TextStyle(
              color: Colors.indigo,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Build App Bar
  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF4051B5),
      title: Text(
        'Buat Kehadiran',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          // Go back to DashboardView when back button is pressed
          Get.offAll(() => const DashboardView());

          // Ensure we're on the previous tab - can be adjusted based on your navigation flow
          Future.delayed(const Duration(milliseconds: 10), () {
            if (Get.isRegistered<DashboardController>()) {
              final dashboardController = Get.find<DashboardController>();
              dashboardController
                  .changeIndex(0); // Or whatever tab you want to return to
            }
          });
        },
      ),
    );
  }

  // Build Map Widget
  Widget _buildMap() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: FlutterMap(
        mapController: controller.mapController,
        options: MapOptions(
          initialCenter: controller.showOfficeLocation.value
              ? controller.officeCoords.value
              : controller.userCoords.value,
          initialZoom: controller.showOfficeLocation.value ? 15.0 : 17.0,
          maxZoom: 18.0,
          minZoom: 10.0,
          onMapReady: () {
            // Initialize the zoom value
            controller.currentZoom.value = controller.mapController.camera.zoom;
          },
          onMapEvent: (event) {
            // Update zoom value when map moves
            if (event is MapEventMove) {
              controller.currentZoom.value = event.camera.zoom;
            }
          },
        ),
        children: [
          _buildTileLayer(),
          _buildCircleLayer(),
          _buildMarkerLayer(),
        ],
      ),
    );
  }

  // Build Tile Layer
  Widget _buildTileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.app',
      tileProvider: CancellableNetworkTileProvider(),
    );
  }

  // Build Circle Layer
  Widget _buildCircleLayer() {
    // Dynamic circle layer at office coordinates - only show when viewing office
    if (!controller.showOfficeLocation.value) return const SizedBox.shrink();

    return Obx(() {
      final radiusInPixels = controller.calculateRadiusInPixels();

      return CircleLayer(
        circles: [
          CircleMarker(
            point: controller.officeCoords.value,
            radius: radiusInPixels,
            color: Colors.red.withOpacity(0.2),
            borderColor: Colors.red.withOpacity(0.7),
            borderStrokeWidth: 2,
          ),
        ],
      );
    });
  }

  // Build Marker Layer
  Widget _buildMarkerLayer() {
    return Obx(() => MarkerLayer(
          markers: [
            // User marker - always show
            Marker(
              point: controller.userCoords.value,
              width: 40,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.location_on,
                    color: Colors.blue,
                    size: 30,
                  ),
                ),
              ),
            ),
            // Office marker - always show
            Marker(
              point: controller.officeCoords.value,
              width: 40,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.business,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  // Build Info Card
  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Obx(() => _buildInfoRow(
                        icon: Icons.business,
                        title: 'Kantor',
                        subtitle: controller.officeName,
                        tagColor: controller.isWithinRadius.value
                            ? Colors.green
                            : (controller.isWfa ? Colors.amber : Colors.red),
                        tagText: controller.isWithinRadius.value
                            ? 'Di Dalam Area'
                            : (controller.isWfa
                                ? 'Di Luar Area (WFA)'
                                : 'Di Luar Area'),
                      )),
                ),
                // Button to toggle between office and user location
                Obx(() => ElevatedButton(
                      onPressed: controller.toggleLocationView,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4051B5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                      child: Text(
                        controller.showOfficeLocation.value
                            ? 'Lihat Lokasi Saya'
                            : 'Lihat Lokasi Kantor',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    )),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildInfoRow(
                    icon: Icons.access_time,
                    title: controller.shiftName,
                    subtitle: controller.shiftTime,
                  ),
                ),
                // WFA/WFO indicator
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: controller.tagColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        controller.tagText,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build Attendance Button with improved handling
  Widget _buildAttendanceButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Obx(() => ZoomTapAnimation(
            onTap: controller.isLoading.value
                ? null
                : () {
                    // Check if photo exists first
                    if (controller.selectedImagePath.isEmpty) {
                      // If no image yet, show camera
                      if (kIsWeb) {
                        _showWebCameraDialog(context);
                      } else {
                        controller.captureImage();
                      }
                    } else {
                      // If image exists, proceed with sending attendance
                      controller.sendAttendance().then((_) {
                        // Navigate to DashboardView and ensure we're on the home tab
                        Get.offAll(() => const DashboardView());

                        // Make sure we're on the home tab (index 0)
                        // We use a small delay to ensure the DashboardController is available
                        Future.delayed(const Duration(milliseconds: 10), () {
                          if (Get.isRegistered<DashboardController>()) {
                            final dashboardController =
                                Get.find<DashboardController>();
                            dashboardController
                                .changeIndex(0); // Switch to home tab

                            // Also ensure the nested navigator shows the home page
                            if (Get.nestedKey(1)?.currentState != null) {
                              Get.nestedKey(1)!.currentState!.pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          dashboardController.pages[0],
                                    ),
                                  );
                            }
                          }
                        });
                      });
                    }
                  },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    // Change button color based on whether attendance can be submitted
                    controller.canSubmitAttendance
                        ? const Color(0xFF4A55A2)
                        : Colors.grey,
                    controller.canSubmitAttendance
                        ? const Color(0xFF7895CB)
                        : Colors.grey.shade400
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (controller.canSubmitAttendance
                            ? const Color(0xFF4A55A2)
                            : Colors.grey)
                        .withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  controller.isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ))
                      : Icon(
                          controller.selectedImagePath.isEmpty
                              ? Icons.camera_alt // Show camera icon if no image
                              : FontAwesomeIcons.fingerprint,
                          color: controller.canSubmitAttendance
                              ? Colors.white
                              : Colors.white.withOpacity(0.7),
                        ),
                  const SizedBox(width: 12),
                  Text(
                    controller.isLoading.value
                        ? 'Memproses...'
                        : (controller.selectedImagePath.isEmpty
                            ? 'Ambil Foto Kehadiran' // Change text if no image
                            : (controller.canSubmitAttendance
                                ? 'Kirim Kehadiran'
                                : 'Tidak Dapat Mengirim')),
                    style: GoogleFonts.poppins(
                      color: controller.canSubmitAttendance
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  // Helper Widget for Info Rows
  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? tagColor,
    String? tagText,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4A55A2),
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                if (tagColor != null && tagText != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: tagColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tagText,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }
}
