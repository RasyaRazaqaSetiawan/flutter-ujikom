import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ujikom/app/data/profile_response.dart';
import 'package:ujikom/app/utils/api.dart';

class ProfileController extends GetxController {
  final box = GetStorage();
  final _getConnect = GetConnect();

  Future<String?> getToken() async {
    return await box.read('auth_token');
  }

  Future<int?> getUserId() async {
    return await box.read('user_id');
  }

  Future<ProfileResponse?> getProfile() async {
    try {
      String? token = await getToken();
      int? id = await getUserId(); // Ambil ID dari storage

      print("Debug: Token -> $token");
      print("Debug: User ID -> $id");

      if (token == null) {
        throw Exception("Token tidak ditemukan, silakan login ulang.");
      }
      if (id == null) {
        throw Exception("ID pengguna tidak ditemukan, silakan login ulang.");
      }

      final response = await _getConnect.get(
        "${BaseUrl.profile}/$id", // Gunakan ID dari storage
        headers: {'Authorization': "Bearer $token"},
        contentType: "application/json",
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return ProfileResponse.fromJson(response.body);
      } else if (response.statusCode == 401) {
        logout();
        throw Exception("Sesi berakhir, silakan login kembali.");
      } else {
        throw Exception("Gagal mengambil profil: ${response.statusText}");
      }
    } catch (e) {
      print("Error saat mengambil profil: $e");
      return null;
    }
  }

  void logout() {
    box.erase(); // Hapus semua data sesi
    Get.offAllNamed('/login');
  }
}
