import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:ujikom/app/data/get_attendance_response.dart';
import 'package:ujikom/app/data/get_leave_response.dart';
import 'package:ujikom/app/data/profile_response.dart';
import 'package:ujikom/app/data/schedule_respones.dart';
import 'package:ujikom/app/modules/dashboard/views/history_view.dart';
import 'package:ujikom/app/modules/dashboard/views/index_view.dart';
import 'package:ujikom/app/modules/dashboard/views/profile_view.dart';
import 'package:ujikom/app/utils/api.dart';

class DashboardController extends GetxController {
  // State Management with Rx
  final selectedIndex = 0.obs;
  final approvedLeaveCount = 0.obs;
  final attendanceCount = 0.obs;
  final attendanceLateCount = 0.obs;
  final approvedSickCount = 0.obs;
  final schedule = Rxn<ScheduleResponse>();
  final get_leave = Rxn<get_leave_respones>();
  final get_attendance = Rxn<GetAttendanceResponse>();
  final profile = Rxn<ProfileResponse>(); // Added missing profile variable
  final lastLeaveDate = ''.obs;
  
  // Loading states
  final isLoading = true.obs;
  final isRefreshing = false.obs;

  // Storage for token and user data
  final box = GetStorage();

  // API Connection - with timeout
  final _getConnect = GetConnect(timeout: const Duration(seconds: 10));

  // Pages used in bottom navigation
  final List<Widget> pages = [
    IndexView(),
    HistoryView(),
    ProfileView(),
  ];

  // Category to icon mapping
  final Map<String, IconData> categoryIcons = {
    'acara_keluarga': Icons.family_restroom,
    'liburan': Icons.beach_access,
    'hamil': Icons.pregnant_woman,
    'sakit': Icons.medical_services,
  };

  @override
  void onInit() {
    super.onInit();
    // Fetch initial data using parallel requests
    loadDashboardData();
  }

  // Load all dashboard data in parallel
  Future<void> loadDashboardData() async {
    isLoading.value = true;
    
    try {
      // Get token once for all requests
      final token = await getToken();
      if (token == null) {
        Get.offAllNamed('/login');
        return;
      }
      
      // Run API calls in parallel
      await Future.wait([
        fetchProfile(), // Added missing profile fetch
        fetchSchedule(token),
        fetchAttendanceData(token),
        fetchLeaveData(token),
      ]);
    } catch (e) {
      handleError('Gagal memuat data', e);
    } finally {
      isLoading.value = false;
    }
  }
  
  // Refresh all data
  Future<void> refreshData() async {
    isRefreshing.value = true;
    await loadDashboardData();
    isRefreshing.value = false;
  }

  // Fetch attendance related data
  Future<void> fetchAttendanceData(String token) async {
    try {
      await Future.wait([
        fetchAttendance(token),
        fetchAttendanceCount(token),
        fetchLateCount(token),
      ]);
    } catch (e) {
      handleError('Gagal memuat data kehadiran', e);
    }
  }
  
  // Fetch leave related data
  Future<void> fetchLeaveData(String token) async {
    try {
      await Future.wait([
        fetchLeave(token),
        fetchApprovedLeaveCount(token),
        fetchApprovedSickCount(token),
      ]);
    } catch (e) {
      handleError('Gagal memuat data cuti', e);
    }
  }

  // NAVIGATION & UI METHODS
  //----------------------------------------

  // Change bottom navigation page index
  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  // Logout function
  void logout() {
    try {
      box.erase();
      Get.offAllNamed('/login');
    } catch (e) {
      handleError('Gagal logout', e);
    }
  }

  // FORMAT & DISPLAY METHODS
  //----------------------------------------

  // Format category with icon
  Widget formatCategoryWithIcon(String category) {
    final icon = categoryIcons[category] ?? Icons.event_note;
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF4051B5),
        ),
        const SizedBox(width: 8),
        Text(
          _getCategoryName(category),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // Get readable category name
  String _getCategoryName(String category) {
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

  // Format category for display
  String formatCategory(String category) {
    return _getCategoryName(category);
  }

  // AUTH & TOKEN METHODS
  //----------------------------------------

  // Get token from storage
  Future<String?> getToken() async {
    try {
      final token = box.read('token');
      if (token == null) {
        Get.snackbar(
          'Sesi Berakhir',
          'Silakan login kembali',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
      return token;
    } catch (e) {
      handleError('Gagal mendapatkan token', e);
      return null;
    }
  }

  // Get user ID from storage
  Future<int?> getUserId() async {
    try {
      return box.read('user_id');
    } catch (e) {
      handleError('Gagal mendapatkan ID pengguna', e);
      return null;
    }
  }

  // API CALLS
  //----------------------------------------

  // Fetch profile data
  Future<void> fetchProfile() async {
    try {
      String? token = await getToken();
      if (token == null) return;

      final response = await _getConnect.get(
        BaseUrl.profile,
        headers: {'Authorization': "Bearer $token"},
        contentType: "application/json",
      );

      if (response.statusCode == 200) {
        profile.value = ProfileResponse.fromJson(response.body);
      } else if (response.statusCode == 401) {
        logout();
      } else {
        throw Exception("Gagal mengambil profil: ${response.statusText}");
      }
    } catch (e) {
      handleError("Gagal memuat profil", e);
    }
  }

  // Fetch schedule data from API
  Future<void> fetchSchedule([String? providedToken]) async {
    try {
      final token = providedToken ?? await getToken();
      if (token == null) return;

      final response = await _getConnect.get(
        BaseUrl.schedule,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        schedule.value = ScheduleResponse.fromJson(response.body);
      } else if (response.statusCode == 401) {
        logout();
      } else {
        throw Exception("Gagal mengambil jadwal: ${response.statusText}");
      }
    } catch (e) {
      handleError("Gagal memuat jadwal", e);
    }
  }

  // Fetch attendance data from API
  Future<void> fetchAttendance([String? providedToken]) async {
    try {
      final token = providedToken ?? await getToken();
      if (token == null) return;

      final response = await _getConnect.get(
        BaseUrl.attendanceToday,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        get_attendance.value = GetAttendanceResponse.fromJson(response.body);
      } else if (response.statusCode == 401) {
        logout();
      } else {
        throw Exception("Gagal mengambil data kehadiran: ${response.statusText}");
      }
    } catch (e) {
      handleError("Gagal memuat data kehadiran", e);
    }
  }

  // Fetch leave data from API
  Future<void> fetchLeave([String? providedToken]) async {
    try {
      final token = providedToken ?? await getToken();
      if (token == null) return;

      final response = await _getConnect.get(
        BaseUrl.leave,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        get_leave.value = get_leave_respones.fromJson(response.body);
        _setLastLeaveDate();
      } else if (response.statusCode == 401) {
        logout();
      } else {
        throw Exception("Gagal mengambil data cuti: ${response.statusText}");
      }
    } catch (e) {
      handleError("Gagal memuat data cuti", e);
    }
  }

  // Fetch approved Attendance count from API
  Future<void> fetchAttendanceCount([String? providedToken]) async {
    try {
      final token = providedToken ?? await getToken();
      if (token == null) return;

      final response = await _getConnect.get(
        BaseUrl.attendanceCount,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var data = response.body;
        attendanceCount.value = data['count'] ?? 0;
      } else if (response.statusCode == 401) {
        logout();
      } else {
        throw Exception("Gagal mengambil data absen: ${response.statusText}");
      }
    } catch (e) {
      handleError("Gagal memuat jumlah kehadiran", e);
    }
  }

  // Fetch late count from API
  Future<void> fetchLateCount([String? providedToken]) async {
    try {
      final token = providedToken ?? await getToken();
      if (token == null) return;

      final response = await _getConnect.get(
        BaseUrl.attendanceLateCount,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var data = response.body;
        attendanceLateCount.value = data['count'] ?? 0;
      } else if (response.statusCode == 401) {
        logout();
      } else {
        throw Exception("Gagal mengambil data telat: ${response.statusText}");
      }
    } catch (e) {
      handleError("Gagal memuat jumlah keterlambatan", e);
    }
  }

  // Fetch approved leave count from API
  Future<void> fetchApprovedLeaveCount([String? providedToken]) async {
    try {
      final token = providedToken ?? await getToken();
      if (token == null) return;

      final response = await _getConnect.get(
        BaseUrl.approvedLeaveCount,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var data = response.body;
        approvedLeaveCount.value = data['count'] ?? 0;
      } else if (response.statusCode == 401) {
        logout();
      } else {
        throw Exception("Gagal mengambil data cuti: ${response.statusText}");
      }
    } catch (e) {
      handleError("Gagal memuat jumlah cuti disetujui", e);
    }
  }

  // Fetch approved sick count from API
  Future<void> fetchApprovedSickCount([String? providedToken]) async {
    try {
      final token = providedToken ?? await getToken();
      if (token == null) return;

      final response = await _getConnect.get(
        BaseUrl.approvedSickCount,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var data = response.body;
        approvedSickCount.value = data['count'] ?? 0;
      } else if (response.statusCode == 401) {
        logout();
      } else {
        throw Exception("Gagal mengambil data cuti sakit: ${response.statusText}");
      }
    } catch (e) {
      handleError("Gagal memuat jumlah cuti sakit disetujui", e);
    }
  }

  // ATTENDANCE METHODS
  //----------------------------------------

  // Process attendance (clock in or out)
  Future<void> storeAttendance(String type) async {
    try {
      final token = await getToken();
      if (token == null) return;

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response = await _getConnect.post(
        BaseUrl.storeAttendance,
        {
          'type': type, // 'in' untuk absen masuk, 'out' untuk absen pulang
        },
        headers: {'Authorization': 'Bearer $token'},
      );

      Get.back(); // Close loading dialog

      if (response.statusCode == 200) {
        await fetchAttendance(); // Refresh data kehadiran
        final message = type == 'in'
            ? 'Absen masuk berhasil dicatat'
            : 'Absen pulang berhasil dicatat';
        
        showSuccessMessage('Berhasil', message);
      } else if (response.statusCode == 401) {
        logout();
      } else {
        final errorMessage =
            type == 'in' ? 'Gagal absen masuk' : 'Gagal absen pulang';
        throw Exception("$errorMessage: ${response.statusText}");
      }
    } catch (e) {
      final errorTitle =
          type == 'in' ? 'Gagal Absen Masuk' : 'Gagal Absen Pulang';
      handleError(errorTitle, e);
    }
  }

  // Helper method for clock in
  Future<void> clockIn() async {
    await storeAttendance('in');
  }

  // Helper method for clock out
  Future<void> clockOut() async {
    await storeAttendance('out');
  }

  // ERROR HANDLING & UI NOTIFICATIONS
  //----------------------------------------
  
  // Display error message
  void handleError(String title, dynamic error) {
    print("$title: $error");
    Get.snackbar(
      title,
      'Error: $error',
      backgroundColor: Colors.red[600],
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  // Display success message
  void showSuccessMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.green[600],
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // HELPER METHODS
  //----------------------------------------

  // Set the last leave date
  void _setLastLeaveDate() {
    if (get_leave.value != null && get_leave.value!.data != null) {
      // Get approved leaves
      var approvedLeaves = get_leave.value!.data!
          .where((leave) => leave.status == 'approved')
          .toList();

      if (approvedLeaves.isNotEmpty) {
        // Sort by start date (newest first)
        approvedLeaves.sort((a, b) => b.startDate!.compareTo(a.startDate!));
        var lastLeave = approvedLeaves.first;

        // Format start and end dates
        final start =
            DateFormat('d MMM y').format(DateTime.parse(lastLeave.startDate!));
        final end =
            DateFormat('d MMM y').format(DateTime.parse(lastLeave.endDate!));

        // Combine into one string
        lastLeaveDate.value = '$start - $end';
      }
    }
  }
}