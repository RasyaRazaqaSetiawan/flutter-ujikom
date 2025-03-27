class BaseUrl {
  static String base = 'http://127.0.0.1:8000/api';

  static String login = '$base/login';
  static String logout = '$base/logout';
  static String profile = '$base/profile';
  
  // endpoint untuk absensi
  static String attendanceToday = '$base/get-attendance-today';
  static String attendanceHistory = '$base/get-attendance-history';
  static String storeAttendance = '$base/attendance/store';

  // Endpoint untuk jadwal kerja
  static String schedule = '$base/get-schedule';

  // Endpoint untuk pengajuan cuti
  static String leave = '$base/get-leave';
  static String storeLeave = '$base/leave';
  static String approvedLeaveCount = '$base/approved-leave-count';
  static String approvedSickCount = '$base/approved-sick-count';
}
