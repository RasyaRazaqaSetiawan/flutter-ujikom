import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:ujikom/app/data/get_leave_response.dart';
import 'package:ujikom/app/data/schedule_respones.dart';
import 'package:ujikom/app/modules/dashboard/views/index_view.dart';
import 'package:ujikom/app/modules/dashboard/views/profile_view.dart';
import 'package:ujikom/app/utils/api.dart';

class DashboardController extends GetxController {
  // State Management dengan Rx
  var selectedIndex =
      0.obs; // Menyimpan indeks yang dipilih di bottom navigation
  var approvedLeaveCount = 0.obs; // Menyimpan jumlah cuti yang disetujui
  var schedule = Rxn<ScheduleResponse>(); // Menyimpan data jadwal
  var get_leave = Rxn<get_leave_respones>(); // Menyimpan data pengajuan cuti
  var lastLeaveDate = ''.obs; // Menyimpan tanggal cuti terakhir

  // Storage untuk mengambil token
  final box = GetStorage();

  // Koneksi API
  final _getConnect = GetConnect();

  // Fungsi untuk mendapatkan token dari storage
  Future<String?> getToken() async {
    return await box.read('token');
  }

  // Ambil data jadwal dari API
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
    }
  }

// Fungsi untuk mengatur tanggal cuti terakhir
  void _setLastLeaveDate() {
    if (get_leave.value != null && get_leave.value!.data != null) {
      // Ambil data cuti yang disetujui
      var approvedLeaves = get_leave.value!.data!
          .where((leave) => leave.status == 'approved')
          .toList();

      if (approvedLeaves.isNotEmpty) {
        // Urutkan berdasarkan startDate
        approvedLeaves.sort((a, b) => b.startDate!.compareTo(a.startDate!));
        var lastLeave = approvedLeaves.first;

        // Format tanggal mulai dan akhir
        final start =
            DateFormat('d MMM y').format(DateTime.parse(lastLeave.startDate!));
        final end =
            DateFormat('d MMM y').format(DateTime.parse(lastLeave.endDate!));

        // Gabungkan keduanya jadi satu string
        lastLeaveDate.value = '$start - $end';
      }
    }
  }

// Fungsi untuk mengambil count cuti yang disetujui dari API Laravel
  Future<void> fetchApprovedLeaveCount() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception("Token tidak ditemukan, silakan login kembali.");
      }

      final response = await _getConnect.get(
        BaseUrl
            .approvedLeaveCount, // Panggil API baru yang menampilkan count cuti yang disetujui
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var data = response.body;
        // print("Response Data: $data"); // Debugging log
        approvedLeaveCount.value =
            data['count']; // Ambil jumlah yang sudah dihitung di backend
        // print(
        //     "Approved Leave Count: ${approvedLeaveCount.value}"); // Verifikasi nilai
      } else {
        throw Exception("Gagal mengambil data cuti: ${response.statusText}");
      }
    } catch (e) {
      print("Error saat mengambil data cuti: $e");
    }
  }

  // Fungsi untuk memformat kategori cuti
  String formatCategory(String category) {
    switch (category) {
      case 'acara_keluarga':
        return 'Acara Keluarga';
      case 'liburan':
        return 'Liburan';
      case 'hamil':
        return 'Hamil';
      case 'sakit':
        return 'Sakit';
      default:
        return category; // Jika kategori tidak ada dalam switch, tampilkan nilai asli
    }
  }

  // Fungsi untuk mengambil data pengajuan cuti (leave)
  Future<void> fetchLeave() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception("Token tidak ditemukan, silakan login kembali.");
      }

      final response = await _getConnect.get(
        BaseUrl.leave, // Pastikan endpoint yang benar
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        get_leave.value = get_leave_respones.fromJson(response.body);
        _setLastLeaveDate(); // Ensure this function is called after data is loaded
      } else {
        throw Exception("Gagal mengambil data cuti: ${response.statusText}");
      }
    } catch (e) {
      print("Error saat mengambil data cuti: $e");
    }
  }

  // Fungsi untuk mengubah indeks halaman
  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  // Daftar halaman yang digunakan di bottom navigation
  final List<Widget> pages = [
    IndexView(),
    ProfileView(),
  ];

  @override
  void onInit() {
    super.onInit();
    fetchSchedule(); // Ambil data jadwal saat controller diinisialisasi
    fetchLeave(); // Ambil data cuti saat controller diinisialisasi
    fetchApprovedLeaveCount(); // Ambil data cuti yang disetujui saat controller diinisialisasi
  }

  // Fungsi untuk logout
  void logout() {
    GetStorage().erase(); // Hapus data storage
    Get.offAllNamed('/login'); // Navigasi ke halaman login
  }
}
