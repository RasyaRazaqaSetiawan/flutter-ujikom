import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';

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

  @override
  void onInit() {
    super.onInit();
    generateDisplayDates();
  }

  // Fungsi untuk menghasilkan tanggal yang akan ditampilkan
  void generateDisplayDates() {
    DateTime firstDayOfMonth =
        DateTime(focusedDate.value.year, focusedDate.value.month, 1);

    // Mendapatkan tanggal pertama yang ditampilkan (bisa dari bulan sebelumnya)
    // Senin = 1, Minggu = 7 dalam sistem Dart
    int firstDayWeekday = firstDayOfMonth.weekday;

    // Menyesuaikan untuk memulai dari Minggu (diubah ke 0-6 di mana Minggu=0)
    int offset = firstDayWeekday == 7 ? 0 : firstDayWeekday;

    DateTime startDate = firstDayOfMonth.subtract(Duration(days: offset));

    // Menghasilkan 42 tanggal (6 minggu)
    List<DateTime> dates = [];
    for (int i = 0; i < 42; i++) {
      dates.add(startDate.add(Duration(days: i)));
    }

    displayedDates.assignAll(dates); // Use assignAll instead of value =

    // Menetapkan indeks dari selectedDate dalam displayedDates
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

    // Temukan indeks tanggal yang dipilih dan perbarui
    for (int i = 0; i < displayedDates.length; i++) {
      if (isSameDay(displayedDates[i], date)) {
        selectedDateIndex.value = i;
        break;
      }
    }

    update(); // Tambahkan ini untuk memaksa pembaruan UI
    print("Tanggal terpilih: ${date.day}/${date.month}/${date.year}");
  }

  // Fungsi untuk mendapatkan nama bulan dan tahun yang ditampilkan
  String getMonthYearText() {
    return DateFormat('MMMM yyyy', 'id_ID').format(focusedDate.value);
  }

  // Fungsi untuk berpindah ke bulan sebelumnya
  void previousMonth() {
    DateTime newDate = DateTime(
      focusedDate.value.year,
      focusedDate.value.month - 1,
      1,
    );
    focusedDate.value = newDate;
    generateDisplayDates();
  }

  // Fungsi untuk berpindah ke bulan berikutnya
  void nextMonth() {
    DateTime newDate = DateTime(
      focusedDate.value.year,
      focusedDate.value.month + 1,
      1,
    );
    focusedDate.value = newDate;
    generateDisplayDates();
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
}
