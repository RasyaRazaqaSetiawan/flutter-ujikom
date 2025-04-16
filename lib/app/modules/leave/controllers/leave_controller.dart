import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:ujikom/app/data/get_leave_response.dart';
import 'package:ujikom/app/data/store_leave_response.dart';
import 'package:ujikom/app/utils/api.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LeaveController extends GetxController {
  var get_leave = Rxn<get_leave_respones>(); // Menyimpan data pengajuan cuti
  var lastLeaveDate = ''.obs; // Menyimpan tanggal cuti terakhir
  var leaveResponse = Rxn<StoreLeaveResponse>();
  var scheduleOffice = Rx<String>('');
  var selectedCategory = 'Pilih Kategori'.obs;
  var startDate = 'Pilih Tanggal Mulai'.obs;
  var endDate = 'Pilih Tanggal Akhir'.obs;
  var reason = ''.obs;
  var selectedImage = ''.obs; // For path reference (mobile)
  var webImage = Rxn<Uint8List>(); // For web image data
  var webImageName = ''.obs; // For web image name
  var webImageType = ''.obs; // For web image MIME type
  var leaveDuration = 0.obs;
  var isFormValid = false.obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = 'Terjadi kesalahan saat memproses pengajuan cuti.'.obs;

  final box = GetStorage();
  final _getConnect = GetConnect();

  @override
  void onInit() {
    super.onInit();
    ever(selectedCategory, (_) => validateForm());
    ever(startDate, (_) => validateForm());
    ever(endDate, (_) => validateForm());
    ever(reason, (_) => validateForm());

    fetchScheduleOffice();
  }

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
        return category;
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

  Future<void> fetchScheduleOffice() async {
    try {
      final token = await getToken();
      if (token == null) {
        Get.snackbar('Error', 'Token tidak ditemukan. Harap login kembali.');
        return;
      }

      final response = await _getConnect.get(
        BaseUrl.schedule,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = response.body;
        if (userData != null && userData['data'] != null) {
          scheduleOffice.value = userData['data']['office'] != null
              ? userData['data']['office']['name'] ?? 'Tidak Ada Kantor'
              : 'Tidak Ada Kantor';
        } else {
          scheduleOffice.value = 'Tidak Ada Kantor';
        }
      } else {
        scheduleOffice.value = 'Tidak Ada Kantor';
      }
    } catch (e) {
      scheduleOffice.value = 'Tidak Ada Kantor';
    }
  }

  Future<String?> getToken() async {
    return await box.read('token');
  }

  void validateForm() {
    isFormValid.value = selectedCategory.value != 'Pilih Kategori' &&
        startDate.value != 'Pilih Tanggal Mulai' &&
        endDate.value != 'Pilih Tanggal Akhir' &&
        reason.value.isNotEmpty;
  }

  void calculateDuration() {
    if (startDate.value != 'Pilih Tanggal Mulai' &&
        endDate.value != 'Pilih Tanggal Akhir') {
      try {
        DateTime start = DateFormat('d MMM y').parse(startDate.value);
        DateTime end = DateFormat('d MMM y').parse(endDate.value);

        if (end.isBefore(start)) {
          Get.snackbar(
              'Error', 'Tanggal selesai tidak boleh sebelum tanggal mulai');
          endDate.value = startDate.value;
          leaveDuration.value = 1;
        } else {
          leaveDuration.value = end.difference(start).inDays + 1;
        }
      } catch (e) {
        leaveDuration.value = 0;
      }
    }
  }

  // Updated image picker function to handle both web and mobile
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();

    if (kIsWeb) {
      // Web approach
      try {
        final XFile? image =
            await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          // Read image as bytes
          final bytes = await image.readAsBytes();
          webImage.value = bytes;
          webImageName.value = image.name;
          webImageType.value = image.mimeType ?? 'image/jpeg';
          selectedImage.value = image.name; // For UI display
        }
      } catch (e) {
        Get.snackbar('Error', 'Gagal memilih gambar: ${e.toString()}');
      }
    } else {
      // Mobile approach
      try {
        final XFile? image =
            await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          selectedImage.value = image.path;
        }
      } catch (e) {
        Get.snackbar('Error', 'Gagal memilih gambar: ${e.toString()}');
      }
    }
  }

  Future<void> storeLeave({
    required String categoriesLeave,
    required String startDate,
    required String endDate,
    required String reason,
    required String scheduleOffice,
    String? attachment,
  }) async {
    try {
      isLoading.value = true;
      hasError.value = false; // Reset error state
      errorMessage.value =
          'Terjadi kesalahan saat memproses pengajuan cuti.'; // Reset error message

      // Input validation
      if (categoriesLeave == 'Pilih Kategori') {
        errorMessage.value = 'Silakan pilih kategori cuti';
        hasError.value = true;
        isLoading.value = false;
        return;
      }

      if (startDate == 'Pilih Tanggal Mulai' ||
          endDate == 'Pilih Tanggal Akhir') {
        errorMessage.value = 'Silakan pilih tanggal mulai dan selesai';
        hasError.value = true;
        isLoading.value = false;
        return;
      }

      if (reason.isEmpty) {
        errorMessage.value = 'Silakan isi alasan cuti';
        hasError.value = true;
        isLoading.value = false;
        return;
      }

      final token = await getToken();
      if (token == null) {
        errorMessage.value = "Token tidak ditemukan. Harap login kembali.";
        hasError.value = true;
        isLoading.value = false;
        return;
      }

      // Format dates
      DateTime parsedStartDate = DateFormat('d MMM y').parse(startDate);
      DateTime parsedEndDate = DateFormat('d MMM y').parse(endDate);
      String formattedStartDate =
          DateFormat('yyyy-MM-dd').format(parsedStartDate);
      String formattedEndDate = DateFormat('yyyy-MM-dd').format(parsedEndDate);

      // Different approach based on platform
      if (kIsWeb) {
        // Web implementation using regular http for multipart
        await _storeLeaveWeb(
          token: token,
          categoriesLeave: categoriesLeave,
          formattedStartDate: formattedStartDate,
          formattedEndDate: formattedEndDate,
          reason: reason,
          scheduleOffice: scheduleOffice,
        );
      } else {
        // Mobile implementation
        await _storeLeaveMobile(
          token: token,
          categoriesLeave: categoriesLeave,
          formattedStartDate: formattedStartDate,
          formattedEndDate: formattedEndDate,
          reason: reason,
          scheduleOffice: scheduleOffice,
        );
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: ${e.toString()}';
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  // Web implementation for store leave
  Future<void> _storeLeaveWeb({
    required String token,
    required String categoriesLeave,
    required String formattedStartDate,
    required String formattedEndDate,
    required String reason,
    required String scheduleOffice,
  }) async {
    var uri = Uri.parse(BaseUrl.storeLeave);

    // For web, we'll manually build the multipart request
    var request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['categories_leave'] = categoriesLeave;
    request.fields['start_date'] = formattedStartDate;
    request.fields['end_date'] = formattedEndDate;
    request.fields['reason'] = reason;
    request.fields['schedule_office'] = scheduleOffice;

    // Add image if available
    if (webImage.value != null) {
      final multipartFile = http.MultipartFile.fromBytes(
        'attachment',
        webImage.value!,
        filename: webImageName.value,
        contentType: MediaType.parse(webImageType.value),
      );
      request.files.add(multipartFile);
    }

    // Send the request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      resetForm();
      hasError.value = false;
    } else {
      // Parse error message from response
      try {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['message'] != null) {
          errorMessage.value = jsonResponse['message'];
        } else if (jsonResponse['errors'] != null) {
          // Handle validation errors
          final errors = jsonResponse['errors'] as Map<String, dynamic>;
          final firstError = errors.entries.first.value;
          if (firstError is List && firstError.isNotEmpty) {
            errorMessage.value = firstError.first.toString();
          } else {
            errorMessage.value = 'Terdapat kesalahan pada form yang diisi.';
          }
        } else {
          errorMessage.value =
              'Gagal mengirim permintaan cuti. Kode: ${response.statusCode}';
        }
      } catch (e) {
        errorMessage.value = 'Gagal mengirim permintaan cuti: ${response.body}';
      }
      hasError.value = true;
    }
  }

  // Mobile implementation for store leave
  Future<void> _storeLeaveMobile({
    required String token,
    required String categoriesLeave,
    required String formattedStartDate,
    required String formattedEndDate,
    required String reason,
    required String scheduleOffice,
  }) async {
    var uri = Uri.parse(BaseUrl.storeLeave);
    var request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['categories_leave'] = categoriesLeave;
    request.fields['start_date'] = formattedStartDate;
    request.fields['end_date'] = formattedEndDate;
    request.fields['reason'] = reason;
    request.fields['schedule_office'] = scheduleOffice;

    // Add image if available
    if (selectedImage.value.isNotEmpty) {
      var file = await http.MultipartFile.fromPath(
        'attachment',
        selectedImage.value,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(file);
    }

    // Send the request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Get.snackbar('Sukses', 'Permintaan cuti berhasil disimpan');
      resetForm();
    } else {
      Get.snackbar('Error', 'Gagal mengirim permintaan cuti: ${response.body}');
    }
  }

  void resetForm() {
    selectedCategory.value = 'Pilih Kategori';
    startDate.value = 'Pilih Tanggal Mulai';
    endDate.value = 'Pilih Tanggal Akhir';
    reason.value = '';
    selectedImage.value = '';
    webImage.value = null;
    webImageName.value = '';
    webImageType.value = '';
    leaveDuration.value = 0;
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
