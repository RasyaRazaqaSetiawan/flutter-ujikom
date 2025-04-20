import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ujikom/app/data/get_attendance_response.dart';
import 'package:ujikom/app/data/get_leave_response.dart' as leave_model;
import 'package:ujikom/app/utils/api.dart';
import 'package:flutter/material.dart';

class HistoryController extends GetxController {
  // Untuk memilih tanggal
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  // Untuk menampilkan bulan dan tahun saat ini
  final Rx<DateTime> focusedDate = DateTime.now().obs;
  // Untuk tanggal yang ditampilkan dalam grid
  final RxList<DateTime> displayedDates = <DateTime>[].obs;
  // Untuk status login
  final RxBool isLoggedIn = true.obs;
  // Untuk indeks tanggal yang dipilih
  final RxInt selectedDateIndex = RxInt(-1);

  // API connector
  final _getConnect = GetConnect();
  final box = GetStorage();

  // Tab selection
  final RxInt selectedTabIndex = 0.obs;

  // Attendance data
  final Rxn<GetAttendanceResponse> attendanceData =
      Rxn<GetAttendanceResponse>();
  final RxBool isLoadingAttendance = false.obs;
  final RxBool hasAttendanceError = false.obs;
  final RxString attendanceErrorMsg = ''.obs;

  // Leave data
  final Rxn<leave_model.get_leave_respones> leaveData =
      Rxn<leave_model.get_leave_respones>();
  final RxBool isLoadingLeave = false.obs;
  final RxBool hasLeaveError = false.obs;
  final RxString leaveErrorMsg = ''.obs;

  // Filtered data for display
  final RxList<BulanIni> filteredAttendance = <BulanIni>[].obs;
  final RxList<leave_model.Data> filteredLeaves = <leave_model.Data>[].obs;
  final RxInt tempYear = DateTime.now().year.obs;
  final RxInt tempMonth = DateTime.now().month.obs;

  @override
  void onInit() {
    super.onInit();
    generateDisplayDates();
    // Setup listener for date changes to update filtered data
    ever(selectedDate, (_) => filterDataBySelectedDate());
    // Initial data fetch
    fetchAttendanceData();
    fetchLeaveData();
  }

  // Di HistoryController, tambahkan fungsi ini untuk memastikan pembaruan yang segera
  void updateCalendarImmediately() {
    // Force generate ulang tanggal
    generateDisplayDates();

    // Perbarui UI dengan segera
    update(['calendar-grid']);

    // Debug log untuk tracking
    print("Calendar updated for: ${focusedDate.value.toString()}");
  }

  // Fungsi untuk menghasilkan tanggal yang akan ditampilkan
  void generateDisplayDates() {
    DateTime firstDayOfMonth =
        DateTime(focusedDate.value.year, focusedDate.value.month, 1);

    // Mendapatkan tanggal pertama yang ditampilkan (bisa dari bulan sebelumnya)
    // Konversi ke format yang konsisten (0-6 dengan 0=Minggu, 1=Senin, dst)
    int firstDayWeekday = firstDayOfMonth.weekday % 7;
    // Jika hari Minggu (yang harusnya 0), weekday Dart akan mengembalikan 7
    if (firstDayOfMonth.weekday == 7) firstDayWeekday = 0;

    // Hitung offset berdasarkan apakah minggu dimulai dari Senin atau Minggu
    // Jika minggu dimulai dari Minggu (seperti di screenshot)
    int offset = firstDayWeekday;

    // Jika minggu dimulai dari Senin (sesuai dengan kode asli)
    // int offset = firstDayMonth.weekday - 1;

    DateTime startDate = firstDayOfMonth.subtract(Duration(days: offset));

    // Menghasilkan 42 tanggal (6 minggu)
    List<DateTime> dates = [];
    for (int i = 0; i < 42; i++) {
      dates.add(startDate.add(Duration(days: i)));
    }

    displayedDates.assignAll(dates);
    updateSelectedDateIndex();
  }

  // Memperbarui indeks dari tanggal yang dipilih
  void updateSelectedDateIndex() {
    final selected = selectedDate.value;
    for (int i = 0; i < displayedDates.length; i++) {
      if (isSameDay(displayedDates[i], selected)) {
        selectedDateIndex.value = i;
        print("Selected index updated to: $i");
        return;
      }
    }
    selectedDateIndex.value = -1;
    print("No matching date found, reset to -1");
  }

  // Fungsi untuk memeriksa apakah dua tanggal adalah hari yang sama
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Fungsi untuk memilih tanggal
  void selectDate(DateTime date) {
    selectedDate.value = date;
    filterDataBySelectedDate();

    // Update specific UI components with targeted IDs
    update(['calendar-grid', 'attendance-data', 'leave-data']);
    print("Selected date: ${date.day}/${date.month}/${date.year}");
  }

  // Fungsi untuk mendapatkan nama bulan dan tahun yang ditampilkan
  String getMonthYearText() {
    return DateFormat('MMMM yyyy', 'id_ID').format(focusedDate.value);
  }

  // Fungsi untuk berpindah ke bulan sebelumnya
  void previousMonth() {
    focusedDate.value = DateTime(
      focusedDate.value.year,
      focusedDate.value.month - 1,
      1,
    );
    generateDisplayDates();

    // Update calendar grid immediately
    update(['calendar-grid']);
  }

  // Fungsi untuk berpindah ke bulan berikutnya
  void nextMonth() {
    focusedDate.value = DateTime(
      focusedDate.value.year,
      focusedDate.value.month + 1,
      1,
    );
    generateDisplayDates();

    // Update calendar grid immediately
    update(['calendar-grid']);
  }

  // Fungsi baru untuk mengubah bulan saja
  void setFocusedMonth(int month) {
    DateTime newDate = DateTime(focusedDate.value.year, month, 1);
    focusedDate.value = newDate;
    generateDisplayDates();
  }

  // Fungsi baru untuk mengubah tahun saja
  void setFocusedYear(int year) {
    DateTime newDate = DateTime(year, focusedDate.value.month, 1);
    focusedDate.value = newDate;
    generateDisplayDates();
  }

  // Fungsi untuk mengubah bulan dan tahun secara bersamaan
  void setMonthYear(int month, int year) {
    focusedDate.value = DateTime(year, month, 1);
    generateDisplayDates();

    // Update calendar grid immediately
    update(['calendar-grid']);
  }

  void initTempDate() {
    tempYear.value = focusedDate.value.year;
    tempMonth.value = focusedDate.value.month;
  }

  void updateTempYear(int year) {
    tempYear.value = year;
    update(['month-year-picker']);
  }

  void updateTempMonth(int month) {
    tempMonth.value = month;
    update(['month-year-picker']);
  }

  // Logout function
  void logout() {
    GetStorage().erase();
    Get.offAllNamed('/login');
  }

  // Fungsi untuk mengecek apakah tanggal yang ditampilkan merupakan bulan aktif
  bool isInCurrentMonth(DateTime date) {
    return date.month == focusedDate.value.month;
  }

  // Method to get token from storage
  Future<String?> getToken() async => await box.read('token');

  // Fetch attendance data from API
  Future<void> fetchAttendanceData() async {
    try {
      isLoadingAttendance.value = true;
      hasAttendanceError.value = false;
      attendanceErrorMsg.value = '';

      final token = await getToken();
      if (token == null) {
        hasAttendanceError.value = true;
        attendanceErrorMsg.value =
            "Token tidak ditemukan, silakan login kembali.";
        return;
      }

      final response = await _getConnect.get(
        BaseUrl.attendanceToday,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        attendanceData.value = GetAttendanceResponse.fromJson(response.body);
        filterDataBySelectedDate();
      } else {
        hasAttendanceError.value = true;
        attendanceErrorMsg.value =
            "Gagal mengambil data kehadiran: ${response.statusText}";
      }
    } catch (e) {
      hasAttendanceError.value = true;
      attendanceErrorMsg.value = "Error: $e";
      print("Error fetching attendance data: $e");
    } finally {
      isLoadingAttendance.value = false;
    }
  }

  // Fetch leave data from API
  Future<void> fetchLeaveData() async {
    try {
      isLoadingLeave.value = true;
      hasLeaveError.value = false;
      leaveErrorMsg.value = '';

      final token = await getToken();
      if (token == null) {
        hasLeaveError.value = true;
        leaveErrorMsg.value = "Token tidak ditemukan, silakan login kembali.";
        return;
      }

      final response = await _getConnect.get(
        BaseUrl.leaves,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        leaveData.value =
            leave_model.get_leave_respones.fromJson(response.body);
        filterDataBySelectedDate();
      } else {
        hasLeaveError.value = true;
        leaveErrorMsg.value =
            "Gagal mengambil data cuti: ${response.statusText}";
      }
    } catch (e) {
      hasLeaveError.value = true;
      leaveErrorMsg.value = "Error: $e";
      print("Error fetching leave data: $e");
    } finally {
      isLoadingLeave.value = false;
    }
  }

  // Filter data based on the selected date
  void filterDataBySelectedDate() {
    // Format selected date for comparison
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value);

    // Filter attendance data
    if (attendanceData.value?.data?.bulanIni != null) {
      filteredAttendance.assignAll(attendanceData.value!.data!.bulanIni!
          .where((item) => item.tanggal == formattedDate)
          .toList());
    } else {
      filteredAttendance.clear();
    }

    // Filter leave data
    if (leaveData.value?.data != null) {
      filteredLeaves.assignAll(leaveData.value!.data!.where((item) {
        if (item.startDate == null || item.endDate == null) return false;

        try {
          DateTime startDate = DateTime.parse(item.startDate!);
          DateTime endDate = DateTime.parse(item.endDate!);

          return selectedDate.value
                  .isAfter(startDate.subtract(const Duration(days: 1))) &&
              selectedDate.value.isBefore(endDate.add(const Duration(days: 1)));
        } catch (e) {
          return false;
        }
      }).toList());
    } else {
      filteredLeaves.clear();
    }

    // Update UI components that display filtered data
    update(['attendance-data', 'leave-data']);
  }

  // Change the selected tab
  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  // Refresh all data
  Future<void> refreshData() async {
    await fetchAttendanceData();
    await fetchLeaveData();
    Get.snackbar(
      'Data Diperbarui',
      'Riwayat kehadiran dan cuti telah diperbarui',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  // Get color based on attendance status
  Color getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'on time':
      case 'tepat waktu':
        return Colors.green;
      case 'late':
      case 'terlambat':
        return Colors.orange;
      case 'absent':
      case 'tidak hadir':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  // Get color based on leave status
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

  // Format leave category
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
        return category;
    }
  }
}
