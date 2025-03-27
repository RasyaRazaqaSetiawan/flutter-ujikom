import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ujikom/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:ujikom/app/modules/dashboard/views/attendances_view.dart';
import 'package:ujikom/app/modules/dashboard/views/leave_detail_view.dart';
import 'package:ujikom/app/modules/dashboard/views/leave_view.dart';

class IndexView extends GetView<DashboardController> {
  const IndexView({super.key});

  @override
  Widget build(BuildContext context) {
    // DashboardController controller = Get.put(DashboardController());
    // final DashboardController controller = Get.find();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Obx(() {
          final name =
              controller.schedule.value?.data?.employeeName ?? 'Pengguna';
          return Text(
            'Selamat Datang, $name',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          );
        }),
        backgroundColor: Colors.indigo[600],
        elevation: 0,
        actions: [
          // IconButton(
          //   icon: const Icon(
          //     Icons.notifications_outlined,
          //     color: Colors.white, // Set the icon color to white
          //   ),
          //   onPressed: () {
          //     // Add notifications logic if needed
          //   },
          // ),
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white, // Set the icon color to white
            ),
            onPressed: () {
              _showLogoutConfirmationDialog();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 16),
            _buildAttendanceCard(),
            const SizedBox(height: 20),
            _buildLeaveRequestCard(),
            const SizedBox(height: 20),
            _buildStatisticsSection(),
            const SizedBox(height: 20),
            _buildLeaveHistorySection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[600]!, Colors.indigo[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 32,
                color: Colors.indigo,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Menampilkan Nama Karyawan
                Obx(() {
                  final employeeName =
                      controller.schedule.value?.data?.employeeName ??
                          'Nama Tidak Tersedia';
                  return Text(
                    employeeName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),

                const SizedBox(height: 4),

                // 🔹 Menampilkan Shift dengan Detail Waktu (Shift: 09:00 - 16:00)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Obx(() {
                    final shiftName =
                        controller.schedule.value?.data?.shift?.name ??
                            'Shift Tidak Tersedia';
                    final startTime =
                        controller.schedule.value?.data?.shift?.startTime ??
                            '00:00';
                    final endTime =
                        controller.schedule.value?.data?.shift?.endTime ??
                            '00:00';
                    return Text(
                      '$shiftName (${DateFormat('HH:mm').format(DateTime.parse('2022-01-01 $startTime'))} - ${DateFormat('HH:mm').format(DateTime.parse('2022-01-01 $endTime'))})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 4),

                // 🔹 Menampilkan Kantor
                Obx(() {
                  final officeName =
                      controller.schedule.value?.data?.office?.name ??
                          'Kantor Tidak Tersedia';
                  return Text(
                    'Kantor: $officeName',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard() {
    String currentDate =
        DateFormat('EEE, dd MMM yyyy', 'id_ID').format(DateTime.now());
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kehadiran Hari Ini',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      currentDate,
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() {
                    final isWfa = controller.schedule.value?.data?.isWfa;

                    if (isWfa == 1) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'WFA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    } else if (isWfa == 0) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber[600],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'WFO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox(); // Tidak tampil jika null
                    }
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Obx(() {
                final startTime =
                    controller.get_attendance.value?.data?.hariIni?.startTime;
                final startTimeText = startTime != null && startTime.isNotEmpty
                    ? startTime
                    : '--:--';

                return _buildTimeInfo(
                    'Datang', startTimeText, Icons.login_rounded, Colors.blue);
              }),
              Container(
                height: 40,
                width: 1,
                color: Colors.grey[200],
              ),
              Obx(() {
                final endTime =
                    controller.get_attendance.value?.data?.hariIni?.endTime;
                final endTimeText =
                    endTime != null && endTime.isNotEmpty ? endTime : '--:--';

                return _buildTimeInfo(
                    'Pulang', endTimeText, Icons.logout_rounded, Colors.orange);
              }),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            final hasStartTime =
                controller.get_attendance.value?.data?.hariIni?.startTime !=
                        null &&
                    controller.get_attendance.value!.data!.hariIni!.startTime!
                        .isNotEmpty;
            final hasEndTime =
                controller.get_attendance.value?.data?.hariIni?.endTime !=
                        null &&
                    controller.get_attendance.value!.data!.hariIni!.endTime!
                        .isNotEmpty;

            return ElevatedButton.icon(
              onPressed: () {
                // Untuk semua kasus, navigasi ke AttendancesView
                Get.to(() => const AttendancesView());
              },
              icon: hasEndTime
                  ? const Icon(Icons.check_circle_outline)
                  : Icon(hasStartTime ? Icons.logout : Icons.fingerprint),
              label: Text(hasEndTime
                  ? 'Kehadiran Selesai'
                  : (hasStartTime ? 'Pulang' : 'Buat Kehadiran')),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasEndTime
                    ? Colors.green[600]
                    : (hasStartTime ? Colors.orange[600] : Colors.indigo[600]),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLeaveRequestCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pengajuan Cuti',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              // Container(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              //   decoration: BoxDecoration(
              //     color: Colors.purple[50],
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   child: Row(
              //     children: [
              //       Icon(
              //         Icons.calendar_today_rounded,
              //         size: 12,
              //         color: Colors.purple[700],
              //       ),
              //       const SizedBox(width: 4),
              //       Text(
              //         'Sisa Cuti: 12',
              //         style: TextStyle(
              //           color: Colors.purple[700],
              //           fontSize: 12,
              //           fontWeight: FontWeight.w500,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 16),

          // Informasi kapan cuti terakhir
          Obx(() {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.indigo[400],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      controller.lastLeaveDate.value.isNotEmpty
                          ? 'Cuti terakhir Anda pada ${controller.lastLeaveDate.value}'
                          : 'Belum ada cuti yang disetujui',
                      style: TextStyle(
                        color: Colors.indigo[700],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // _showLeaveRequestDialog();
              Get.to(() => const LeaveView());
            },
            icon: const Icon(Icons.event_available_rounded),
            label: const Text('Ajukan Cuti'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[600],
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveHistorySection() {
    return Obx(() {
      // Cek apakah data leave sudah tersedia
      if (controller.get_leave.value == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final leaveHistory = controller.get_leave.value?.data ?? [];

      // Cek jika data cuti kosong
      if (leaveHistory.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Riwayat Cuti',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 30),
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
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tidak ada data cuti',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }

      // Batasi hanya 3 data yang ditampilkan
      final limitedLeaveHistory = leaveHistory.take(3).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Riwayat Cuti',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.to(() => const LeaveDetailView());
                  },
                  child: Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.indigo[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: limitedLeaveHistory.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey[200],
                ),
                itemBuilder: (context, index) {
                  final leave = limitedLeaveHistory[index];
                  final category =
                      leave.categoriesLeave ?? 'Cuti Tidak Diketahui';

                  // Menentukan warna status berdasarkan status cuti
                  Color statusColor;
                  String statusText;

                  switch (leave.status) {
                    case 'approved':
                      statusColor = Colors.green;
                      statusText = 'Disetujui';
                      break;
                    case 'rejected':
                      statusColor = Colors.red;
                      statusText = 'Ditolak';
                      break;
                    case 'pending':
                    default:
                      statusColor = Colors.amber;
                      statusText = 'Pending';
                      break;
                  }

                  // Mengambil ikon kategori dari controller
                  final IconData categoryIcon =
                      controller.categoryIcons[category] ?? Icons.event_note;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Icon(
                      categoryIcon,
                      color: Color(0xFF4051B5),
                      size: 24,
                    ),
                    title: Text(
                      controller.formatCategory(category),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${leave.formattedDates ?? 'Tanggal Tidak Tersedia'} (${leave.days ?? 0} hari)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTimeInfo(String label, String time, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              time,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Statistik Bulan Ini',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildStatisticCard(
                  'Hadir', '0', Icons.check_circle_outline, Colors.green),
              _buildStatisticCard(
                  'Terlambat', '0', Icons.access_time, Colors.orange),
              Obx(() {
                return _buildStatisticCard(
                    'Izin/Cuti',
                    '${controller.approvedLeaveCount.value}', // Menggunakan Obx agar count bisa ter-update
                    Icons.event_note,
                    Colors.blue);
              }),
              Obx(() {
                return _buildStatisticCard(
                    'Sakit',
                    '${controller.approvedSickCount.value}',
                    Icons.healing,
                    Colors.red[400]!);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12, bottom: 4, left: 4),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menampilkan dialog info ketika absensi sudah selesai
  void showAttendanceCompletedInfo() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue[600]),
            SizedBox(width: 10),
            Text('Informasi Kehadiran'),
          ],
        ),
        content: Text(
          'Absensi hari ini sudah selesai. Anda dapat melakukan absensi kembali pada hari kerja berikutnya.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Mengerti', style: TextStyle(color: Colors.blue[700])),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      barrierDismissible: true,
    );
  }

  void _showLogoutConfirmationDialog() {
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
              const Text(
                'Konfirmasi Logout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Apakah Anda yakin ingin keluar?',
                textAlign: TextAlign.center,
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
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.logout();
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
                      child: const Text('Ya, Keluar'),
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
