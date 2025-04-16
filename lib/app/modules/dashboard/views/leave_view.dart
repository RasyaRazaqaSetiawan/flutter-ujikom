import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ujikom/app/modules/dashboard/views/dashboard_view.dart';
import 'package:ujikom/app/modules/leave/controllers/leave_controller.dart';

class LeaveView extends GetView<LeaveController> {
  const LeaveView({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan controller sudah diinisialisasi
    Get.put(LeaveController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF4051B5),
        title: Text(
          'Pengajuan Cuti',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Leave type selection
                    const Text(
                      'Jenis Cuti',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: Obx(() => DropdownButton<String>(
                              value: controller.selectedCategory.value,
                              isExpanded: true,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              borderRadius: BorderRadius.circular(10),
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Color(0xFF4051B5)),
                              dropdownColor: Colors.white,
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 15),
                              items: [
                                'Pilih Kategori',
                                'acara_keluarga',
                                'liburan',
                                'hamil',
                                'sakit'
                              ].map((String type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(controller.formatCategory(type)),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  controller.selectedCategory.value = newValue;
                                }
                              },
                            )),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ScheduleOffice field (disabled, read-only)
                    const Text(
                      'Kantor',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(() {
                      String kantor = controller.scheduleOffice.value.isEmpty ||
                              controller.scheduleOffice.value ==
                                  'Tidak Ada Kantor'
                          ? 'Tidak Ada Kantor'
                          : controller.scheduleOffice.value;

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                          color: Colors.grey.shade200,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.business,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              kantor,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // Date selection for Start and End Date
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tanggal Mulai',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildDatePicker(
                                context,
                                controller.startDate,
                                (date) {
                                  controller.startDate.value = date;
                                  controller.calculateDuration();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tanggal Selesai',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildDatePicker(
                                context,
                                controller.endDate,
                                (date) {
                                  controller.endDate.value = date;
                                  controller.calculateDuration();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Duration info
                    Obx(() => Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Color(0xFF4051B5),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Durasi cuti: ${controller.leaveDuration.value} hari',
                                style: const TextStyle(
                                  color: Color(0xFF4051B5),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )),

                    const SizedBox(height: 20),

                    // Reason text field
                    const Text(
                      'Alasan Cuti',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      onChanged: (value) {
                        controller.reason.value = value;
                      },
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Tuliskan alasan cuti Anda disini...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF4051B5)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Image attachment
                    const Text(
                      'Lampiran',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          // Image placeholder or preview - dimodifikasi untuk web dan mobile
                          Obx(() {
                            bool hasImage = false;

                            if (kIsWeb) {
                              hasImage = controller.webImage.value != null;
                            } else {
                              hasImage =
                                  controller.selectedImage.value.isNotEmpty;
                            }

                            return Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                              ),
                              child: !hasImage
                                  ? Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.image_outlined,
                                            size: 60,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Belum ada gambar',
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : _buildImagePreview(),
                            );
                          }),

                          // Upload button
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Center(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  controller.pickImage();
                                },
                                icon: const Icon(Icons.file_upload_outlined),
                                label: const Text("Pilih Gambar"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4051B5),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

// Submit button
                    Obx(() => SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: controller.isFormValid.value
                                ? () {
                                    controller
                                        .storeLeave(
                                      categoriesLeave:
                                          controller.selectedCategory.value,
                                      startDate: controller.startDate.value,
                                      endDate: controller.endDate.value,
                                      reason: controller.reason.value,
                                      scheduleOffice:
                                          controller.scheduleOffice.value,
                                    )
                                        .then((_) {
                                      // Tampilkan dialog sukses jika tidak ada error
                                      if (!controller.isLoading.value &&
                                          !controller.hasError.value) {
                                        _showSuccessDialog(context);
                                      } else if (controller.hasError.value) {
                                        // Tampilkan dialog error jika ada error
                                        _showErrorDialog(context,
                                            controller.errorMessage.value);
                                      }
                                    }).catchError((error) {
                                      // Handle any unexpected errors
                                      _showErrorDialog(context,
                                          'Terjadi kesalahan: ${error.toString()}');
                                    });
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9C27B0),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              disabledBackgroundColor: Colors.grey.shade400,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send),
                                SizedBox(width: 10),
                                Text(
                                  'Ajukan Cuti',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            )),
    );
  }

  // Widget khusus untuk menampilkan preview gambar berdasarkan platform
  Widget _buildImagePreview() {
    if (kIsWeb) {
      // Tampilkan preview gambar untuk web
      if (controller.webImage.value != null) {
        return Image.memory(
          controller.webImage.value!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text('Gambar tidak dapat ditampilkan',
                  style: TextStyle(color: Colors.red)),
            );
          },
        );
      }
    } else {
      // Tampilkan preview gambar untuk mobile
      if (controller.selectedImage.value.isNotEmpty) {
        return Image.asset(
          controller.selectedImage.value,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text('Gambar tidak dapat ditampilkan',
                  style: TextStyle(color: Colors.red)),
            );
          },
        );
      }
    }
    return const SizedBox(); // Fallback jika tidak ada gambar
  }

  Widget _buildDatePicker(BuildContext context, Rx<String> currentDate,
      Function(String) onDateSelected) {
    return InkWell(
      onTap: () async {
        DateTime? initialDate;
        try {
          if (currentDate.value != 'Pilih Tanggal Mulai' &&
              currentDate.value != 'Pilih Tanggal Akhir') {
            initialDate = DateFormat('d MMM y').parse(currentDate.value);
          } else {
            initialDate = DateTime.now();
          }
        } catch (e) {
          initialDate = DateTime.now();
        }

        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2101),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF4051B5),
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF4051B5),
                  ),
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          String formattedDate = DateFormat('d MMM y').format(picked);
          onDateSelected(formattedDate);
        }
      },
      child: Obx(() => Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Text(
                  currentDate.value,
                  style: TextStyle(
                    fontSize: 15,
                    color: (currentDate.value == 'Pilih Tanggal Mulai' ||
                            currentDate.value == 'Pilih Tanggal Akhir')
                        ? Colors.grey[600]
                        : Colors.black,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Colors.grey,
                ),
              ],
            ),
          )),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red[600],
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pengajuan Cuti Gagal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.resetForm();
                    Get.offAll(() => const DashboardView());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Kembali'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: Colors.green[600],
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pengajuan Cuti Berhasil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pengajuan cuti Anda telah berhasil diajukan dan sedang menunggu persetujuan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.resetForm();
                    Get.offAll(() => const DashboardView());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Kembali ke Beranda'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
