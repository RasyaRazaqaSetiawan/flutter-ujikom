import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ujikom/app/data/schedule_respones.dart';
import 'package:ujikom/app/modules/dashboard/views/index_view.dart';
import 'package:ujikom/app/modules/dashboard/views/profile_view.dart';
import 'package:ujikom/app/utils/api.dart';

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;
  var schedule = Rxn<ScheduleResponse>(); // Menyimpan response jadwal
  final box = GetStorage();
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
        headers: {
          'Authorization': 'Bearer $token',
        },
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

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  final List<Widget> pages = [
    IndexView(),
    ProfileView(),
  ];

  @override
  void onInit() {
    super.onInit();
    fetchSchedule(); // Ambil data saat controller diinisialisasi
  }

  void logout() {
    GetStorage().erase();
    Get.offAllNamed('/login');
  }
}
