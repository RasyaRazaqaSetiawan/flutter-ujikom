import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ujikom/app/data/get_attendance_response.dart';
import 'package:ujikom/app/data/get_leave_response.dart' as leave_model;
import 'package:ujikom/app/utils/api.dart';

enum AttendanceStatus { none, onTime, late, leave }

class HistoryController extends GetxController {
  // Calendar state
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<DateTime> focusedDate = DateTime.now().obs;
  final RxList<DateTime> displayedDates = <DateTime>[].obs;
  final RxInt selectedDateIndex = RxInt(-1);
  final RxInt tempYear = DateTime.now().year.obs;
  final RxInt tempMonth = DateTime.now().month.obs;

  // UI state
  final RxBool isLoggedIn = true.obs;
  final RxInt selectedTabIndex = 0.obs;

  // API state
  final _getConnect = GetConnect();
  final box = GetStorage();

  // Attendance data
  final Rxn<GetAttendanceResponse> attendanceData =
      Rxn<GetAttendanceResponse>();
  final RxBool isLoadingAttendance = false.obs;
  final RxBool hasAttendanceError = false.obs;
  final RxString attendanceErrorMsg = ''.obs;
  final RxList<BulanIni> filteredAttendance = <BulanIni>[].obs;

  // Leave data
  final Rxn<leave_model.get_leave_respones> leaveData =
      Rxn<leave_model.get_leave_respones>();
  final RxBool isLoadingLeave = false.obs;
  final RxBool hasLeaveError = false.obs;
  final RxString leaveErrorMsg = ''.obs;
  final RxList<leave_model.Data> filteredLeaves = <leave_model.Data>[].obs;

  // Named update IDs for targeted updates
  static const String calendarGridId = 'calendar-grid';
  static const String attendanceDataId = 'attendance-data';
  static const String leaveDataId = 'leave-data';
  static const String monthYearPickerId = 'month-year-picker';

  @override
  void onInit() {
    super.onInit();
    generateDisplayDates();
    ever(selectedDate, (_) => filterDataBySelectedDate());
    fetchData();
  }

  // Combined fetch method for better error handling
  Future<void> fetchData() async {
    // Validate token once for all API calls
    final token = await getToken();
    if (token == null) {
      _handleAuthError();
      return;
    }

    // Parallel API calls for better performance
    await Future.wait([fetchAttendanceData(token), fetchLeaveData(token)]);
  }

  void _handleAuthError() {
    final errorMsg = "Token tidak ditemukan, silakan login kembali.";
    hasAttendanceError.value = true;
    hasLeaveError.value = true;
    attendanceErrorMsg.value = errorMsg;
    leaveErrorMsg.value = errorMsg;

    // Show auth error once
    Get.snackbar(
      'Error Autentikasi',
      errorMsg,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );

    // Redirect to login after short delay
    Future.delayed(const Duration(seconds: 1), () {
      logout();
    });
  }

  // Calendar methods
  void generateDisplayDates() {
    final firstDayOfMonth =
        DateTime(focusedDate.value.year, focusedDate.value.month, 1);

    // Get weekday with correct formatting (0=Sunday, 6=Saturday)
    int firstDayWeekday = firstDayOfMonth.weekday % 7;

    // Calculate start date
    final startDate = firstDayOfMonth.subtract(Duration(days: firstDayWeekday));

    // Generate 42 dates (6 weeks) for consistent calendar size
    final dates =
        List.generate(42, (index) => startDate.add(Duration(days: index)));

    displayedDates.assignAll(dates);
    updateSelectedDateIndex();
  }

  void updateSelectedDateIndex() {
    final selected = selectedDate.value;

    for (int i = 0; i < displayedDates.length; i++) {
      if (isSameDay(displayedDates[i], selected)) {
        selectedDateIndex.value = i;
        return;
      }
    }

    selectedDateIndex.value = -1;
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    filterDataBySelectedDate();
    update([calendarGridId, attendanceDataId, leaveDataId]);
  }

  String getMonthYearText() {
    return DateFormat('MMMM yyyy', 'id_ID').format(focusedDate.value);
  }

  void previousMonth() {
    final newDate = DateTime(
      focusedDate.value.year,
      focusedDate.value.month - 1,
      1,
    );
    _updateFocusedDate(newDate);
  }

  void nextMonth() {
    final newDate = DateTime(
      focusedDate.value.year,
      focusedDate.value.month + 1,
      1,
    );
    _updateFocusedDate(newDate);
  }

  void setFocusedMonth(int month) {
    final newDate = DateTime(focusedDate.value.year, month, 1);
    _updateFocusedDate(newDate);
  }

  void setFocusedYear(int year) {
    final newDate = DateTime(year, focusedDate.value.month, 1);
    _updateFocusedDate(newDate);
  }

  void setMonthYear(int month, int year) {
    final newDate = DateTime(year, month, 1);
    _updateFocusedDate(newDate);
  }

  void _updateFocusedDate(DateTime newDate) {
    focusedDate.value = newDate;
    generateDisplayDates();
    update([calendarGridId]);
  }

  void updateCalendarImmediately() {
    generateDisplayDates();
    update([calendarGridId]);
  }

  void initTempDate() {
    tempYear.value = focusedDate.value.year;
    tempMonth.value = focusedDate.value.month;
  }

  void updateTempYear(int year) {
    tempYear.value = year;
    update([monthYearPickerId]);
  }

  void updateTempMonth(int month) {
    tempMonth.value = month;
    update([monthYearPickerId]);
  }

  bool isInCurrentMonth(DateTime date) {
    return date.month == focusedDate.value.month;
  }

  // Authentication methods
  Future<String?> getToken() async => box.read<String>('token');

  void logout() {
    box.erase();
    Get.offAllNamed('/login');
  }

  // Data fetching methods
  Future<void> fetchAttendanceData([String? token]) async {
    try {
      isLoadingAttendance.value = true;
      hasAttendanceError.value = false;
      attendanceErrorMsg.value = '';

      final authToken = token ?? await getToken();
      if (authToken == null) return;

      final response = await _getConnect.get(
        BaseUrl.attendanceToday,
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        attendanceData.value = GetAttendanceResponse.fromJson(response.body);
        filterDataBySelectedDate();
      } else {
        _handleApiError(
            isAttendance: true,
            statusCode: response.statusCode,
            statusText: response.statusText);
      }
    } catch (e) {
      _handleException(isAttendance: true, error: e);
    } finally {
      isLoadingAttendance.value = false;
    }
  }

  Future<void> fetchLeaveData([String? token]) async {
    try {
      isLoadingLeave.value = true;
      hasLeaveError.value = false;
      leaveErrorMsg.value = '';

      final authToken = token ?? await getToken();
      if (authToken == null) return;

      final response = await _getConnect.get(
        BaseUrl.leaves,
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        leaveData.value =
            leave_model.get_leave_respones.fromJson(response.body);
        filterDataBySelectedDate();
      } else {
        _handleApiError(
            isAttendance: false,
            statusCode: response.statusCode,
            statusText: response.statusText);
      }
    } catch (e) {
      _handleException(isAttendance: false, error: e);
    } finally {
      isLoadingLeave.value = false;
    }
  }

  void _handleApiError(
      {required bool isAttendance, int? statusCode, String? statusText}) {
    final errorMsg =
        "Gagal mengambil data ${isAttendance ? 'kehadiran' : 'cuti'}: ${statusText ?? 'Error $statusCode'}";

    if (isAttendance) {
      hasAttendanceError.value = true;
      attendanceErrorMsg.value = errorMsg;
    } else {
      hasLeaveError.value = true;
      leaveErrorMsg.value = errorMsg;
    }

    // Log error
    debugPrint(errorMsg);
  }

  void _handleException({required bool isAttendance, dynamic error}) {
    final errorMsg = "Error: $error";

    if (isAttendance) {
      hasAttendanceError.value = true;
      attendanceErrorMsg.value = errorMsg;
    } else {
      hasLeaveError.value = true;
      leaveErrorMsg.value = errorMsg;
    }

    // Log error
    debugPrint(
        "Error fetching ${isAttendance ? 'attendance' : 'leave'} data: $error");
  }

  // Data processing methods
  void filterDataBySelectedDate() {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value);

    _filterAttendanceData(formattedDate);
    _filterLeaveData();

    update([attendanceDataId, leaveDataId]);
  }

  void _filterAttendanceData(String formattedDate) {
    if (attendanceData.value?.data?.bulanIni != null) {
      filteredAttendance.assignAll(attendanceData.value!.data!.bulanIni!
          .where((item) => item.tanggal == formattedDate)
          .toList());
    } else {
      filteredAttendance.clear();
    }
  }

  void _filterLeaveData() {
    if (leaveData.value?.data != null) {
      filteredLeaves.assignAll(leaveData.value!.data!.where((item) {
        if (item.startDate == null || item.endDate == null) return false;

        try {
          final startDate = DateTime.parse(item.startDate!);
          final endDate = DateTime.parse(item.endDate!);

          return selectedDate.value
                  .isAfter(startDate.subtract(const Duration(days: 1))) &&
              selectedDate.value.isBefore(endDate.add(const Duration(days: 1)));
        } catch (e) {
          debugPrint("Error parsing leave dates: $e");
          return false;
        }
      }).toList());
    } else {
      filteredLeaves.clear();
    }
  }

  // UI methods
  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  Future<void> refreshData() async {
    await fetchData();

    Get.snackbar(
      'Data Diperbarui',
      'Riwayat kehadiran dan cuti telah diperbarui',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Color getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'tepat waktu':
        return Colors.green;
      case 'terlambat':
        return Colors.orange;
      case 'absent':
      case 'tidak hadir':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  AttendanceStatus getAttendanceStatusForDate(DateTime date) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    // Check attendance status
    if (attendanceData.value?.data?.bulanIni != null) {
      final attendances = attendanceData.value!.data!.bulanIni!
          .where((item) => item.tanggal == formattedDate)
          .toList();

      if (attendances.isNotEmpty) {
        final attendance = attendances.first;

        if (attendance.statusMasuk != null) {
          final status = attendance.statusMasuk!.toLowerCase();
          if (status.contains('tepat waktu')) {
            return AttendanceStatus.onTime;
          } else if (status.contains('terlambat')) {
            return AttendanceStatus.late;
          }
        }
      }
    }

    // Check leave status - MODIFIED to only count approved leaves
    if (leaveData.value?.data != null) {
      final isOnApprovedLeave = leaveData.value!.data!.any((item) {
        if (item.startDate == null || item.endDate == null) return false;

        // Check if the leave is approved
        if (item.status?.toLowerCase() != 'approved') return false;

        try {
          final startDate = DateTime.parse(item.startDate!);
          final endDate = DateTime.parse(item.endDate!);

          return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              date.isBefore(endDate.add(const Duration(days: 1)));
        } catch (e) {
          return false;
        }
      });

      if (isOnApprovedLeave) {
        return AttendanceStatus.leave;
      }
    }

    return AttendanceStatus.none;
  }

  Color getStatusColorForDate(DateTime date) {
    final status = getAttendanceStatusForDate(date);

    switch (status) {
      case AttendanceStatus.onTime:
        return Colors.green;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.leave:
        return Colors.blue;
      case AttendanceStatus.none:
      default:
        return Colors.transparent;
    }
  }

  Color getLeaveStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String formatLeaveCategory(String? category) {
    if (category == null) return 'Tidak Diketahui';

    switch (category.toLowerCase()) {
      case 'acara_keluarga':
        return 'Acara Keluarga';
      case 'liburan':
        return 'Liburan';
      case 'hamil':
        return 'Hamil';
      case 'sakit':
        return 'Sakit';
      default:
        return category.replaceAll('_', ' ').toUpperCase().substring(0, 1) +
            category.replaceAll('_', ' ').substring(1).toLowerCase();
    }
  }
}
