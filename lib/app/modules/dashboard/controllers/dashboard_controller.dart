import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:ujikom/app/data/get_leave_response.dart';
import 'package:ujikom/app/data/schedule_respones.dart';
import 'package:ujikom/app/modules/dashboard/views/index_view.dart';
import 'package:ujikom/app/modules/dashboard/views/profile_view.dart';
import 'package:ujikom/app/utils/api.dart';

class DashboardController extends GetxController {
  // State Management with Rx
  final selectedIndex = 0.obs;
  final approvedLeaveCount = 0.obs;
  final approvedSickCount = 0.obs;
  final schedule = Rxn<ScheduleResponse>();
  final get_leave = Rxn<get_leave_respones>();
  final lastLeaveDate = ''.obs;
  
  // Storage for token
  final box = GetStorage();
  
  // API Connection
  final _getConnect = GetConnect();
  
  // Pages used in bottom navigation
  final List<Widget> pages = [
    IndexView(),
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
    fetchSchedule();
    fetchLeave();
    fetchApprovedLeaveCount();
    fetchApprovedSickCount();
  }

  // Get token from storage
  Future<String?> getToken() async {
    return await box.read('token');
  }

  // Format category with icon
  Widget formatCategoryWithIcon(String category) {
    final icon = categoryIcons[category] ?? Icons.event_note;
    return Row(
      children: [
        Icon(
          icon,
          color: Color(0xFF4051B5),
        ),
        SizedBox(width: 8),
        Text(
          _getCategoryName(category),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  // Change bottom navigation page index
  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  // Logout function
  void logout() {
    GetStorage().erase();
    Get.offAllNamed('/login');
  }

  // API Calls
  //----------------------------------------

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

  // Fetch leave data from API
  Future<void> fetchLeave() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception("Token tidak ditemukan, silakan login kembali.");
      }

      final response = await _getConnect.get(
        BaseUrl.leave,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        get_leave.value = get_leave_respones.fromJson(response.body);
        _setLastLeaveDate();
      } else {
        throw Exception("Gagal mengambil data cuti: ${response.statusText}");
      }
    } catch (e) {
      print("Error saat mengambil data cuti: $e");
    }
  }

  // Fetch approved leave count from API
  Future<void> fetchApprovedLeaveCount() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception("Token tidak ditemukan, silakan login kembali.");
      }

      final response = await _getConnect.get(
        BaseUrl.approvedLeaveCount,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var data = response.body;
        approvedLeaveCount.value = data['count'];
      } else {
        throw Exception("Gagal mengambil data cuti: ${response.statusText}");
      }
    } catch (e) {
      print("Error saat mengambil data cuti: $e");
    }
  }

  // Fetch approved sick count from API
  Future<void> fetchApprovedSickCount() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception("Token tidak ditemukan, silakan login kembali.");
      }

      final response = await _getConnect.get(
        BaseUrl.approvedSickCount,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var data = response.body;
        approvedSickCount.value = data['count'];
      } else {
        throw Exception("Gagal mengambil data cuti: ${response.statusText}");
      }
    } catch (e) {
      print("Error saat mengambil data cuti: $e");
    }
  }

  // Helper methods
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
        final start = DateFormat('d MMM y').format(DateTime.parse(lastLeave.startDate!));
        final end = DateFormat('d MMM y').format(DateTime.parse(lastLeave.endDate!));

        // Combine into one string
        lastLeaveDate.value = '$start - $end';
      }
    }
  }
}