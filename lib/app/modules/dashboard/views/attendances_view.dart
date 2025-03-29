import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:ujikom/app/modules/attendances/controllers/attendances_controller.dart';
import 'dart:math' show cos, pow;

class AttendancesView extends GetView<AttendancesController> {
  const AttendancesView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered in GetX dependency management
    final controller = Get.put(AttendancesController());

    // Create a map controller to track zoom changes
    final mapController = MapController();

    // Fixed radius in meters for the circle
    const double radiusInMeters = 100.0;

    // Coordinates for Bandung, Indonesia (marker location - user location)
    // final LatLng userCoords = LatLng(-6.995927, 107.593684);
    final LatLng userCoords = LatLng(-6.967105, 107.592861);

    // Different coordinates for the circle (Gedung Sate, Bandung - office location)
    final LatLng officeCoords = LatLng(-6.967105, 107.592861);

    // Create Rx variables
    final RxDouble currentZoom = 15.0.obs;
    final RxBool showOfficeLocation =
        true.obs; // Controls which location to focus on

    // Function to move map to a location
    void moveToLocation(LatLng location, double zoom) {
      mapController.move(location, zoom);
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
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
      ),
      body: Obx(() {
        // Check if schedule data is loaded
        if (controller.schedule.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final scheduleData = controller.schedule.value!.data;
        if (scheduleData == null) {
          return const Center(child: Text('No schedule data available'));
        }

        // Get office name or use default if null
        final String officeName = scheduleData.office?.name ?? 'Nama Kantor';

        // Get shift details or use defaults if null
        final String shiftName = scheduleData.shift?.name ?? 'Shift';
        final String shiftTime =
            '${scheduleData.shift?.startTime ?? '00:00:00'} - ${scheduleData.shift?.endTime ?? '00:00:00'}';

        // Check if WFA (Work From Anywhere) is enabled
        final bool isWfa = scheduleData.isWfa == 1;

        // Set tag color and text based on work location type
        final Color tagColor = isWfa ? Colors.green : Colors.amber;
        final String tagText = isWfa ? 'WFA' : 'WFO';

        return Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter:
                        showOfficeLocation.value ? officeCoords : userCoords,
                    initialZoom: showOfficeLocation.value ? 15.0 : 17.0,
                    maxZoom: 18.0,
                    minZoom: 10.0,
                    onMapReady: () {
                      // Initialize the zoom value
                      currentZoom.value = mapController.camera.zoom;
                    },
                    onMapEvent: (event) {
                      // Update zoom value when map moves
                      if (event is MapEventMove) {
                        currentZoom.value = event.camera.zoom;
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                      tileProvider: CancellableNetworkTileProvider(),
                    ),
                    // Dynamic circle layer at office coordinates - only show when viewing office
                    if (showOfficeLocation.value)
                      Obx(() {
                        // Calculate how many pixels represent our radius in meters at the current zoom level
                        final metersPerPixel = 156543.03392 *
                            cos(officeCoords.latitude * pi / 180) /
                            pow(2, currentZoom.value);
                        final radiusInPixels = radiusInMeters / metersPerPixel;

                        return CircleLayer(
                          circles: [
                            CircleMarker(
                              point: officeCoords,
                              radius: radiusInPixels,
                              color: Colors.blue.withOpacity(0.2),
                              borderColor: Colors.blue.withOpacity(0.7),
                              borderStrokeWidth: 2,
                            ),
                          ],
                        );
                      }),
                    MarkerLayer(
                      markers: [
                        // User marker - always show
                        Marker(
                          point: userCoords,
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
                          point: officeCoords,
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
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
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
                            subtitle: officeName,
                            tagColor: tagColor,
                            tagText: tagText,
                          ),
                        ),
                        // Button to toggle between office and user location
                        Obx(() => ElevatedButton(
                              onPressed: () {
                                showOfficeLocation.value =
                                    !showOfficeLocation.value;
                                moveToLocation(
                                    showOfficeLocation.value
                                        ? officeCoords
                                        : userCoords,
                                    showOfficeLocation.value ? 15.0 : 17.0);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4051B5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                              ),
                              child: Text(
                                showOfficeLocation.value
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
                      title: shiftName,
                      subtitle: shiftTime,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ZoomTapAnimation(
                onTap: () {
                  // Here you can add the logic to record attendance
                  Get.snackbar(
                    'Sukses',
                    'Kehadiran berhasil dicatat',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
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
                      const Icon(FontAwesomeIcons.fingerprint,
                          color: Colors.white),
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
            ),
            const SizedBox(height: 20),
          ],
        );
      }),
    );
  }

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
