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
  static String attendanceHistory = '$base/attendance/history';
  static String attendanceOnTimeCount = '$base/attendance/on-time-count';
  static String attendanceLateCount = '$base/attendance/late-count';
  
  // New attendance history routes
  static String attendanceHistoryByDate = '$base/attendance/history-by-date';
  static String attendanceDetail = '$base/attendance/detail';
  static String attendanceCalendar = '$base/attendance/calendar';
  static String attendanceCalendarHistory = '$base/attendance/calendar-history';
  static String attendanceStatistics = '$base/attendance/statistics';

  // Leave endpoints
  static String leaves = '$base/leaves';
  static String storeLeave = '$base/leaves'; // Will need ID appended: '$base/leaves/$id/status'
  static String pendingLeaves = '$base/leaves/pending';
  static String approvedLeavesCount = '$base/leaves/approved-count';
  static String sickLeaveCount = '$base/leaves/sick-count';
  
  // New leave history routes
  static String leaveHistoryByDate = '$base/leaves/history-by-date';
  static String leaveDetail = '$base/leaves'; // Will need ID appended: '$base/leaves/$id/detail'
  static String leaveCalendar = '$base/leaves/calendar';
}