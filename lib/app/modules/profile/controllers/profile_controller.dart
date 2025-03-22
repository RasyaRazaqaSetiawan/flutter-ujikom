import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ujikom/app/data/profile_response.dart';
import 'package:ujikom/app/utils/api.dart';

class ProfileController extends GetxController {
  final box = GetStorage();
  final _getConnect = GetConnect();

  // Profile data as an observable
  var profile =
      Rx<ProfileResponse?>(null); // Add this line to hold the profile data

  Future<String?> getToken() async {
    return await box.read('token');
  }

  Future<int?> getUserId() async {
    return await box.read('user_id');
  }

  // Call this to fetch profile data
  Future<void> fetchProfile() async {
    try {
      String? token = await getToken();
      int? id = await getUserId();

      if (token == null) {
        throw Exception("Token tidak ditemukan, silakan login ulang.");
      }
      if (id == null) {
        throw Exception("ID pengguna tidak ditemukan, silakan login ulang.");
      }

      final response = await _getConnect.get(
        "${BaseUrl.base}/profile", // Ganti dengan endpoint profile yang sesuai
        headers: {'Authorization': "Bearer $token"},
        contentType: "application/json",
      );

      if (response.statusCode == 200) {
        profile.value =
            ProfileResponse.fromJson(response.body); // Save data to profile Rx
      } else {
        throw Exception("Gagal mengambil profil: ${response.statusText}");
      }
    } catch (e) {
      print("Error saat mengambil profil: $e");
      profile.value = null; // Reset to null if error occurs
    }
  }

  void logout() {
    box.erase(); // Hapus semua data sesi
    Get.offAllNamed('/login');
  }
}
