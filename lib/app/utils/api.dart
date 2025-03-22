class BaseUrl {
  static String base = 'http://127.0.0.1:8000/api';

  static String login = '$base/login';
  static String logout = '$base/logout';
  static String profile = '$base/profile';
  
  // Tambahkan endpoint untuk absensi
  static String attendanceToday = '$base/get-attendance-today';
  static String attendanceByMonthAndYear = '$base/attendance'; // Tambah parameter nanti di request
  static String storeAttendance = '$base/attendance/store';

  // Endpoint untuk jadwal kerja
  static String schedule = '$base/get-schedule';
}
