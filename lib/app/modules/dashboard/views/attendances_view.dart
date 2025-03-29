import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:ujikom/app/modules/attendances/controllers/attendances_controller.dart';

class AttendancesView extends GetView<AttendancesController> {
  const AttendancesView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered in GetX dependency management
    Get.put(AttendancesController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: Obx(() {
        // Check if schedule data is loaded
        if (!controller.isScheduleLoaded) {
          return Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: const Center(
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
            ),
          );
        }

        if (!controller.isScheduleDataAvailable) {
          return const Center(child: Text('No schedule data available'));
        }

        return Column(
          children: [
            Expanded(child: _buildMap()),
            const SizedBox(height: 16),
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildAttendanceButton(),
            const SizedBox(height: 20),
          ],
        );
      }),
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
        onPressed: () => Get.back(),
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
              ? controller.officeCoords
              : controller.userCoords,
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
            point: controller.officeCoords,
            radius: radiusInPixels,
            color: Colors.blue.withOpacity(0.2),
            borderColor: Colors.blue.withOpacity(0.7),
            borderStrokeWidth: 2,
          ),
        ],
      );
    });
  }

  // Build Marker Layer
  Widget _buildMarkerLayer() {
    return MarkerLayer(
      markers: [
        // User marker - always show
        Marker(
          point: controller.userCoords,
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
          point: controller.officeCoords,
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
    );
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
                  child: _buildInfoRow(
                    icon: Icons.business,
                    title: 'Kantor',
                    subtitle: controller.officeName,
                    tagColor: controller.tagColor,
                    tagText: controller.tagText,
                  ),
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
            _buildInfoRow(
              icon: Icons.access_time,
              title: controller.shiftName,
              subtitle: controller.shiftTime,
            ),
          ],
        ),
      ),
    );
  }

  // Build Attendance Button
  Widget _buildAttendanceButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ZoomTapAnimation(
        onTap: controller.sendAttendance,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A55A2), Color(0xFF7895CB)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A55A2).withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(FontAwesomeIcons.fingerprint, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Kirim Kehadiran',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
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
