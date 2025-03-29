import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ujikom/app/data/schedule_respones.dart';
import 'package:ujikom/app/utils/api.dart';

class AttendancesController extends GetxController {
  final schedule = Rxn<ScheduleResponse>();

  // Storage for token
  final box = GetStorage();

  // API Connection
  final _getConnect = GetConnect();

  @override
  void onInit() {
    super.onInit();
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
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
