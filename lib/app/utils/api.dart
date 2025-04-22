class BaseUrl {
  static String base = 'http://127.0.0.1:8000/api';

  // Auth endpoints
  static String login = '$base/login';
  static String logout = '$base/logout';
  static String profile = '$base/profile';
  static String updateProfile = '$base/profile/update';

  // Attendance endpoints
  static String attendanceToday = '$base/attendance/today';
  static String attendanceSchedule = '$base/attendance/schedule';
  static String storeAttendance = '$base/attendance';
  static String attendanceOnTimeCount = '$base/attendance/on-time-count';
  static String attendanceLateCount = '$base/attendance/late-count';

  // Leave endpoints
  static String leaves = '$base/leaves';
  static String storeLeave = '$base/leaves';
  static String pendingLeaves = '$base/leaves/pending';
  static String approvedLeavesCount = '$base/leaves/approved-count';
  static String sickLeaveCount = '$base/leaves/sick-count';

  // Calendar endpoints
  static String holidays = '$base/holidays';
}