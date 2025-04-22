import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ujikom/app/data/profile_response.dart';
import 'package:ujikom/app/data/update_profile_response.dart';
import 'package:ujikom/app/utils/api.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ujikom/app/utils/event_bus.dart';

class ProfileController extends GetxController {
  final box = GetStorage();
  final _getConnect = GetConnect();

  // Data profil sebagai observable
  var profile = Rx<ProfileResponse?>(null);

  // Status update profile
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  Future<String?> getToken() async {
    return await box.read('token');
  }

  Future<int?> getUserId() async {
    return await box.read('user_id');
  }

  // Panggil ini untuk mengambil data profil
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
        BaseUrl.profile, // Menggunakan endpoint dari BaseUrl
        headers: {'Authorization': "Bearer $token"},
        contentType: "application/json",
      );

      if (response.statusCode == 200) {
        profile.value = ProfileResponse.fromJson(response.body);
      } else {
        throw Exception("Gagal mengambil profil: ${response.statusText}");
      }
    } catch (e) {
      print("Error saat mengambil profil: $e");
      profile.value = null; // Reset ke null jika terjadi error
    }
  }

  // Method untuk update profile tanpa foto
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? gender,
    String? phoneNumber,
    String? address,
    String? dateOfBirth,
    bool refreshAfterUpdate = true,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      String? token = await getToken();

      if (token == null) {
        errorMessage.value = "Token tidak ditemukan, silakan login ulang.";
        isLoading.value = false;
        return false;
      }

      // Siapkan data untuk diupdate
      final Map<String, String> data = {};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (gender != null) {
        // Gunakan nilai gender langsung dalam bahasa Indonesia
        // Standarisasi penulisan (jika diperlukan)
        final lowerGender = gender.toLowerCase();
        if (lowerGender == 'laki-laki' ||
            lowerGender == 'laki laki' ||
            lowerGender == 'laki') {
          data['gender'] = 'Laki-Laki';
        } else if (lowerGender == 'perempuan') {
          data['gender'] = 'Perempuan';
        } else if (lowerGender == 'male') {
          data['gender'] = 'Laki-Laki';
        } else if (lowerGender == 'female') {
          data['gender'] = 'Perempuan';
        } else {
          // Default jika tidak dikenali
          data['gender'] = 'Laki-Laki';
        }
      }
      if (phoneNumber != null) data['phone_number'] = phoneNumber;
      if (address != null) data['address'] = address;
      if (dateOfBirth != null) data['date_of_birth'] = dateOfBirth;

      // Debug info
      print('Mengirim data ke server: $data');

      final response = await _getConnect.post(
        BaseUrl.updateProfile,
        data,
        headers: {'Authorization': "Bearer $token"},
        contentType: "application/json",
      );

      // Debug info
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final updateProfileResponse =
            UpdateProfileResponse.fromJson(response.body);
        successMessage.value =
            updateProfileResponse.message ?? "Profil berhasil diperbarui";
        if (refreshAfterUpdate) {
          await fetchProfile(); // Refresh data profil setelah update
          EventBus.profileUpdated.toggle(); // Notifies other controllers
        }
        isLoading.value = false;
        return true;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          errorMessage.value =
              errorData['message'] ?? "Gagal memperbarui profil";
        } catch (_) {
          errorMessage.value =
              "Gagal memperbarui profil: ${response.statusText}";
        }
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      print('Error pada update profile: $e');
      errorMessage.value = "Error: $e";
      isLoading.value = false;
      return false;
    }
  }

  // Method untuk update profile dengan foto (cross-platform support)
  Future<bool> updateProfileWithPhoto({
    String? name,
    String? email,
    String? gender,
    String? phoneNumber,
    String? address,
    String? dateOfBirth,
    dynamic profilePhoto, // Bisa File di native atau Uint8List di web
    String? fileName,
    bool refreshAfterUpdate = true,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      String? token = await getToken();

      if (token == null) {
        errorMessage.value = "Token tidak ditemukan, silakan login ulang.";
        isLoading.value = false;
        return false;
      }

      if (kIsWeb) {
        // Gunakan pendekatan berbasis Web dengan FormData dari GetConnect
        final formData = FormData({
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (gender != null) 'gender': _standardizeGender(gender),
          if (phoneNumber != null) 'phone_number': phoneNumber,
          if (address != null) 'address': address,
          if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        });

        // Tambahkan file foto jika ada
        if (profilePhoto != null) {
          if (profilePhoto is Uint8List) {
            // Jika data berupa byte array (Uint8List)
            final mime = "image/jpeg"; // Default MIME type
            formData.files.add(
              MapEntry(
                'profile_photo',
                MultipartFile(
                  profilePhoto,
                  filename: fileName ?? 'profile_photo.jpg',
                  contentType: mime,
                ),
              ),
            );
          } else if (profilePhoto is File) {
            // Handle jika tetap File (seharusnya tidak terjadi di web)
            formData.files.add(
              MapEntry(
                'profile_photo',
                MultipartFile(profilePhoto.readAsBytesSync(),
                    filename: fileName ?? 'profile_photo.jpg',
                    contentType: "image/jpeg"),
              ),
            );
          } else {
            throw Exception("Format foto tidak didukung");
          }
        }

        // Kirim request dengan FormData
        final response = await _getConnect.post(
          BaseUrl.updateProfile,
          formData,
          headers: {'Authorization': "Bearer $token"},
          contentType: "multipart/form-data",
        );

        // Proses response
        return _processUpdateResponse(response, refreshAfterUpdate);
      } else {
        // Pendekatan Native dengan http.MultipartRequest
        var request =
            http.MultipartRequest('POST', Uri.parse(BaseUrl.updateProfile));

        // Tambahkan Authorization header
        request.headers['Authorization'] = "Bearer $token";

        // Tambahkan fields
        if (name != null) request.fields['name'] = name;
        if (email != null) request.fields['email'] = email;
        if (gender != null)
          request.fields['gender'] = _standardizeGender(gender);
        if (phoneNumber != null) request.fields['phone_number'] = phoneNumber;
        if (address != null) request.fields['address'] = address;
        if (dateOfBirth != null) request.fields['date_of_birth'] = dateOfBirth;

        // Tambahkan file foto profil jika ada
        if (profilePhoto != null && profilePhoto is File) {
          request.files.add(await http.MultipartFile.fromPath(
              'profile_photo', profilePhoto.path));
        }

        // Kirim request
        var streamResponse = await request.send();
        var response = await http.Response.fromStream(streamResponse);

        // Proses hasil
        if (response.statusCode == 200) {
          final updateProfileResponse =
              UpdateProfileResponse.fromJson(jsonDecode(response.body));
          successMessage.value =
              updateProfileResponse.message ?? "Profil berhasil diperbarui";
          if (refreshAfterUpdate) {
            await fetchProfile(); // Refresh data profil setelah update
          }
          isLoading.value = false;
          return true;
        } else {
          try {
            final errorData = jsonDecode(response.body);
            errorMessage.value =
                errorData['message'] ?? "Gagal memperbarui profil";
          } catch (_) {
            errorMessage.value =
                "Gagal memperbarui profil: ${response.reasonPhrase}";
          }
          isLoading.value = false;
          return false;
        }
      }
    } catch (e) {
      print('Error pada update profile dengan foto: $e');
      errorMessage.value = "Error: $e";
      isLoading.value = false;
      return false;
    }
  }

  // Helper method untuk memproses respons update profile dari GetConnect
  Future<bool> _processUpdateResponse(
      Response response, bool refreshAfterUpdate) async {
    // Debug info
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final updateProfileResponse =
          UpdateProfileResponse.fromJson(response.body);
      successMessage.value =
          updateProfileResponse.message ?? "Profil berhasil diperbarui";
      if (refreshAfterUpdate) {
        await fetchProfile(); // Refresh data profil setelah update
        EventBus.profileUpdated.toggle(); // Mengubah nilai untuk memicu event
      }
      isLoading.value = false;
      return true;
    } else {
      try {
        final errorData =
            response.body is String ? jsonDecode(response.body) : response.body;
        errorMessage.value = errorData['message'] ?? "Gagal memperbarui profil";
      } catch (_) {
        errorMessage.value = "Gagal memperbarui profil: ${response.statusText}";
      }
      isLoading.value = false;
      return false;
    }
  }

  // Helper method untuk standarisasi gender
  String _standardizeGender(String gender) {
    final lowerGender = gender.toLowerCase();
    if (lowerGender == 'laki-laki' ||
        lowerGender == 'laki laki' ||
        lowerGender == 'laki' ||
        lowerGender == 'male') {
      return 'Laki-Laki';
    } else if (lowerGender == 'perempuan' || lowerGender == 'female') {
      return 'Perempuan';
    } else {
      // Default jika tidak dikenali
      return 'Laki-Laki';
    }
  }

  void logout() {
    box.erase(); // Hapus semua data sesi
    Get.offAllNamed('/login');
  }

  @override
  void onInit() {
    super.onInit();
    fetchProfile(); // Ambil data profil saat controller diinisialisasi
  }
}
