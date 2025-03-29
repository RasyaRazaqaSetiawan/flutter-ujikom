import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' show cos, pow;
import 'package:ujikom/app/data/schedule_respones.dart';
import 'package:ujikom/app/utils/api.dart';

class AttendancesController extends GetxController {
  final schedule = Rxn<ScheduleResponse>();

  // Storage for token
  final box = GetStorage();

  // API Connection
  final _getConnect = GetConnect();

  // Map controller to track zoom changes
  final mapController = MapController();

  // Fixed radius in meters for the circle
  final double radiusInMeters = 100.0;

  // Rx variables untuk reactive state
  final RxDouble currentZoom = 15.0.obs;
  final RxBool showOfficeLocation = true.obs;

  // Coordinates
  late final LatLng userCoords;
  late final LatLng officeCoords;

  @override
  void onInit() {
    super.onInit();

    // Initialize coordinates
    userCoords = LatLng(-6.995927, 107.593684); // User location
    officeCoords =
        LatLng(-6.967105, 107.592861); // Office location (Gedung Sate, Bandung)

    // Fetch schedule data when controller is initialized
    fetchSchedule();
  }

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

  // Method untuk memindahkan peta ke lokasi tertentu
  void moveToLocation(LatLng location, double zoom) {
    mapController.move(location, zoom);
  }

  // Method untuk toggle lokasi yang ditampilkan (kantor atau user)
  void toggleLocationView() {
    showOfficeLocation.value = !showOfficeLocation.value;
    moveToLocation(showOfficeLocation.value ? officeCoords : userCoords,
        showOfficeLocation.value ? 15.0 : 17.0);
  }

  // Method untuk menghitung radius dalam pixel berdasarkan zoom level
  double calculateRadiusInPixels() {
    final metersPerPixel = 156543.03392 *
        cos(officeCoords.latitude * pi / 180) /
        pow(2, currentZoom.value);
    return radiusInMeters / metersPerPixel;
  }

  // Method untuk mengirim kehadiran
  void sendAttendance() {
    // Implementasi pengiriman data kehadiran ke API
    Get.snackbar(
      'Sukses',
      'Kehadiran berhasil dicatat',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );

    // Di sini nantinya akan ada kode untuk mengirim data ke API
    // contoh:
    // final response = await _getConnect.post(
    //   BaseUrl.attendance,
    //   {'location': userCoords.toString()},
    //   headers: {'Authorization': 'Bearer $token'},
    // );
  }

  // Helper method untuk mengecek jika data jadwal sudah dimuat
  bool get isScheduleLoaded => schedule.value != null;

  // Helper method untuk mengecek jika data jadwal tersedia
  bool get isScheduleDataAvailable =>
      schedule.value != null && schedule.value!.data != null;

  // Getter untuk nama kantor
  String get officeName => schedule.value?.data?.office?.name ?? 'Nama Kantor';

  // Getter untuk nama shift
  String get shiftName => schedule.value?.data?.shift?.name ?? 'Shift';

  // Getter untuk waktu shift
  String get shiftTime {
    final startTime = schedule.value?.data?.shift?.startTime ?? '00:00:00';
    final endTime = schedule.value?.data?.shift?.endTime ?? '00:00:00';
    return '$startTime - $endTime';
  }

  // Getter untuk status WFA/WFO
  bool get isWfa => schedule.value?.data?.isWfa == 1;

  // Getter untuk warna tag WFA/WFO
  Color get tagColor => isWfa ? Colors.green : Colors.amber;

  // Getter untuk teks tag WFA/WFO
  String get tagText => isWfa ? 'WFA' : 'WFO';

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
