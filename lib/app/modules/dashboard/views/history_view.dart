import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ujikom/app/modules/history/controllers/history_controller.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize date formatting for Indonesia locale
    initializeDateFormatting('id_ID', null);
    Get.put(HistoryController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'History',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo[600],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              _showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.refreshData(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCalendarHeader(context),
                const SizedBox(height: 16),
                _buildDateSelection(context),
                const SizedBox(height: 24),
                _buildTabs(),
                const SizedBox(height: 16),
                Obx(() => controller.selectedTabIndex.value == 0
                    ? _buildAttendanceHistory()
                    : _buildLeaveHistory()),
                // Spacer for bottom padding
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.indigo[600],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() => GestureDetector(
                onTap: () {
                  _showMonthYearPicker(context);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        controller.getMonthYearText(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDateSelection(BuildContext context) {
    final daysOfWeek = ['M', 'S', 'S', 'R', 'K', 'J', 'S'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pilih Tanggal',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Row(
                  children: [
                    // Previous month button
                    InkWell(
                      onTap: () => controller.previousMonth(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chevron_left,
                          color: Colors.grey[700],
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Next month button
                    InkWell(
                      onTap: () => controller.nextMonth(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          color: Colors.grey[700],
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Days of week row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: daysOfWeek.map((day) {
                return SizedBox(
                  width: 30,
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Date grid with specific ID for targeted updates
          GetBuilder<HistoryController>(
            id: 'calendar-grid',
            builder: (ctrl) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemCount: ctrl.displayedDates.length,
                itemBuilder: (context, index) {
                  final date = ctrl.displayedDates[index];
                  final isSelected =
                      ctrl.isSameDay(date, ctrl.selectedDate.value);
                  final isCurrentMonth = ctrl.isInCurrentMonth(date);
                  final isToday = ctrl.isSameDay(date, DateTime.now());

                  // Mendapatkan status warna untuk tanggal ini
                  final statusColor = isCurrentMonth
                      ? ctrl.getStatusColorForDate(date)
                      : Colors.transparent;

                  // Tentukan warna background berdasarkan status dan prioritas tampilan
                  Color backgroundColor;
                  if (isSelected) {
                    backgroundColor = Colors.indigo[600]!;
                  } else if (statusColor != Colors.transparent) {
                    backgroundColor = statusColor;
                  } else {
                    backgroundColor = Colors.transparent;
                  }

                  // Tentukan warna teks berdasarkan background
                  Color textColor;
                  if (isSelected || statusColor != Colors.transparent) {
                    textColor = Colors.white;
                  } else if (!isCurrentMonth) {
                    textColor = Colors.grey[400]!;
                  } else if (isToday) {
                    textColor = Colors.indigo;
                  } else {
                    textColor = Colors.grey[800]!;
                  }

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap:
                          isCurrentMonth ? () => ctrl.selectDate(date) : null,
                      borderRadius: BorderRadius.circular(50),
                      splashColor: Colors.indigo.withOpacity(0.3),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          shape: BoxShape.circle,
                          boxShadow:
                              isSelected || statusColor != Colors.transparent
                                  ? [
                                      BoxShadow(
                                        color: (isSelected
                                                ? Colors.indigo
                                                : statusColor)
                                            .withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      )
                                    ]
                                  : null,
                        ),
                        child: Center(
                          child: Text(
                            date.day.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: (isSelected ||
                                      isToday ||
                                      statusColor != Colors.transparent)
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Tambahkan widget ini di bawah kalender dalam _buildDateSelection
  Widget _buildColorLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem('Tepat Waktu', Colors.green),
          const SizedBox(width: 16),
          _buildLegendItem('Terlambat', Colors.orange),
          const SizedBox(width: 16),
          _buildLegendItem('Cuti', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Build tabs for switching between attendance and leave history
  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Obx(() => Row(
              children: [
                _buildTabButton(
                  title: 'Kehadiran',
                  icon: Icons.calendar_today_outlined,
                  isSelected: controller.selectedTabIndex.value == 0,
                  onTap: () => controller.changeTab(0),
                ),
                _buildTabButton(
                  title: 'Cuti',
                  icon: Icons.beach_access_outlined,
                  isSelected: controller.selectedTabIndex.value == 1,
                  onTap: () => controller.changeTab(1),
                ),
              ],
            )),
      ),
    );
  }

  // Individual tab button
  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.indigo[600] : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build attendance history section
  Widget _buildAttendanceHistory() {
    return GetBuilder<HistoryController>(
      id: 'attendance-data',
      builder: (ctrl) {
        if (ctrl.isLoadingAttendance.value) {
          return _buildLoadingState("Memuat data kehadiran...");
        }

        if (ctrl.hasAttendanceError.value) {
          return _buildErrorState(
            ctrl.attendanceErrorMsg.value,
            onRetry: () => ctrl.fetchAttendanceData(),
          );
        }

        if (ctrl.filteredAttendance.isEmpty) {
          return _buildEmptyState(
              "Tidak ada data kehadiran pada tanggal tersebut");
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Detail Kehadiran',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Dynamically show check-in/check-out cards
            ...ctrl.filteredAttendance.map((attendance) {
              // Check if there's check-in data
              if (attendance.jamMasuk != null &&
                  attendance.jamMasuk!.isNotEmpty &&
                  attendance.jamMasuk != "-") {
                return Column(
                  children: [
                    _buildAttendanceCard(
                      title: 'Absensi Datang',
                      time: attendance.jamMasuk ?? '-',
                      date: _formatDate(attendance.tanggal),
                      location: attendance.kantor ?? 'Tidak tercatat',
                      status: attendance.statusMasuk ?? 'Tidak diketahui',
                      latitude: attendance.latitude.toString(),
                      longitude: attendance.longitude.toString(),
                      isEntry: true,
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }
              return const SizedBox.shrink();
            }).toList(),

            // Check-out cards
            ...ctrl.filteredAttendance.map((attendance) {
              // Check if there's check-out data
              if (attendance.jamPulang != null &&
                  attendance.jamPulang!.isNotEmpty &&
                  attendance.jamPulang != "-") {
                return Column(
                  children: [
                    _buildAttendanceCard(
                      title: 'Absensi Pulang',
                      time: attendance.jamPulang ?? '-',
                      date: _formatDate(attendance.tanggal),
                      location: attendance.kantor ?? 'Tidak tercatat',
                      status: attendance.statusPulang ?? 'Tidak diketahui',
                      latitude: attendance.checkoutLatitude.toString(),
                      longitude: attendance.checkoutLongitude.toString(),
                      isEntry: false,
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }
              return const SizedBox.shrink();
            }).toList(),
          ],
        );
      },
    );
  }

  // Helper to format dates consistently
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  // Build leave history section
  Widget _buildLeaveHistory() {
    return GetBuilder<HistoryController>(
      id: 'leave-data',
      builder: (ctrl) {
        if (ctrl.isLoadingLeave.value) {
          return _buildLoadingState("Memuat data cuti...");
        }

        if (ctrl.hasLeaveError.value) {
          return _buildErrorState(
            ctrl.leaveErrorMsg.value,
            onRetry: () => ctrl.fetchLeaveData(),
          );
        }

        if (ctrl.filteredLeaves.isEmpty) {
          return _buildEmptyState("Tidak ada data cuti pada tanggal tersebut");
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Detail Cuti',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Leave cards
            ...ctrl.filteredLeaves
                .map((leave) => Column(
                      children: [
                        _buildLeaveCard(leave),
                        const SizedBox(height: 16),
                      ],
                    ))
                .toList(),
          ],
        );
      },
    );
  }

  // Build leave card
  Widget _buildLeaveCard(leave) {
    final statusColor = controller.getLeaveStatusColor(leave.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.event_note_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      controller.formatLeaveCategory(leave.categoriesLeave),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    leave.status ?? 'Unknown',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Information Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Date range
                _buildInfoRow(
                  Icons.date_range_rounded,
                  "${_formatDate(leave.startDate)} - ${_formatDate(leave.endDate)}",
                  statusColor,
                ),
                const SizedBox(height: 12),

                // Duration
                _buildInfoRow(
                  Icons.timer_outlined,
                  "${leave.days} hari",
                  statusColor,
                ),
                const SizedBox(height: 12),

                // Office
                _buildInfoRow(
                  Icons.business_outlined,
                  leave.scheduleOffice ?? "Tidak tercatat",
                  statusColor,
                ),
                const SizedBox(height: 16),

                // Reason section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Alasan:",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        leave.reason ?? "Tidak ada alasan",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build attendance card
  Widget _buildAttendanceCard({
    required String title,
    required String time,
    required String date,
    required String location,
    required String status,
    required String latitude,
    required String longitude,
    required bool isEntry, // true for check-in, false for check-out
  }) {
    final Color cardColor = isEntry
        ? Colors.blue
        : Colors.red; // Blue for check-in, red for check-out
    final Color cardLightColor = cardColor.withOpacity(0.1);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isEntry ? Icons.login_rounded : Icons.logout_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Information Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Date
                _buildInfoRow(
                  Icons.calendar_today_rounded,
                  date,
                  cardColor,
                ),
                const SizedBox(height: 12),

                // Location
                _buildInfoRow(
                  Icons.business,
                  location,
                  cardColor,
                ),
                const SizedBox(height: 12),

                // Status
                _buildInfoRow(
                  Icons.check_circle_outline,
                  status,
                  cardColor,
                ),

                const SizedBox(height: 16),

                // Coordinate Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardLightColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Latitude',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            latitude,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Longitude',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            longitude,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Loading state widget
  Widget _buildLoadingState(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Error state widget
  Widget _buildErrorState(String errorMessage,
      {required VoidCallback onRetry}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red[400],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Terjadi Kesalahan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            color: Colors.grey[400],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Data',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: iconColor,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  // FIXED: This method now correctly handles GetX reactivity for month/year selection
  void _showMonthYearPicker(BuildContext context) {
    final years = List.generate(5, (index) => DateTime.now().year + index - 2);
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    // Inisialisasi nilai temporer di controller
    controller.initTempDate();

    // Tambahkan ID unik untuk dialog
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: GetBuilder<HistoryController>(
          id: 'month-year-picker',
          builder: (ctrl) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pilih Bulan & Tahun',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 20),

                // Year selection dengan GetBuilder
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: DropdownButton<int>(
                    value: ctrl.tempYear.value,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
                    items: years.map((year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(
                          year.toString(),
                          style: GoogleFonts.poppins(
                            color: Colors.grey[800],
                            fontSize: 15,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ctrl.updateTempYear(value);
                        // Update UI segera
                        ctrl.update(['month-year-picker']);
                      }
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Month grid dengan GetBuilder
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    // Month index is 0-based in array but 1-based in DateTime
                    final monthNumber = index + 1;
                    final isSelected = monthNumber == ctrl.tempMonth.value;

                    return InkWell(
                      onTap: () {
                        ctrl.updateTempMonth(monthNumber);
                        // Update UI segera
                        ctrl.update(['month-year-picker']);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.indigo[600]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          months[index],
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.grey[800],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Apply button
                ElevatedButton(
                  onPressed: () {
                    // Apply the selected month and year
                    ctrl.setMonthYear(
                        ctrl.tempMonth.value, ctrl.tempYear.value);
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[600],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Selesai',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Konfirmasi Logout',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah Anda yakin ingin keluar?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back(); // Close the dialog
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Implementasi logout
                        controller.logout();
                        Get.back(); // Tutup dialog setelah logout
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Ya, Keluar',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
