import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ujikom/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:ujikom/app/modules/dashboard/views/dashboard_view.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ujikom/app/modules/profile/controllers/profile_controller.dart';

class EditProfileView extends GetView<ProfileController> {
  EditProfileView({Key? key}) : super(key: key);

  // Text editing controllers untuk form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Variabel state
  final Rx<String?> selectedGender = Rx<String?>(null);
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final Rx<XFile?> imageFile = Rx<XFile?>(null);
  final Rx<Uint8List?> webImage = Rx<Uint8List?>(null);

  // Format tanggal
  final dateFormat = DateFormat('yyyy-MM-dd'); // Untuk API (English format)

  // Custom function untuk format tanggal Indonesia
  String formatDateIndonesian(DateTime date) {
    final List<String> monthsIndo = [
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

    return '${date.day} ${monthsIndo[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Pastikan controller sudah diinisialisasi
    Get.lazyPut(() => ProfileController());

    // Inisialisasi form dengan data profil saat ini
    _initializeFormData();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF4051B5),
        title: Text(
          'Ubah Profil',
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
      body: Obx(() {
        // Tampilkan indikator loading saat memproses
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bagian Gambar Profil
                Center(
                  child: Stack(
                    children: [
                      Obx(() {
                        if (kIsWeb && webImage.value != null) {
                          // Tampilkan gambar yang dipilih di web
                          return CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            backgroundImage: MemoryImage(webImage.value!),
                          );
                        } else if (!kIsWeb && imageFile.value != null) {
                          // Tampilkan gambar yang dipilih di native
                          return CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            backgroundImage: FileImage(File(imageFile.value!.path)),
                          );
                        } else if (controller.profile.value?.data?.profilePhoto != null) {
                          // Tampilkan foto profil yang ada
                          return CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(
                              controller.profile.value!.data!.profilePhoto!,
                            ),
                          );
                        } else {
                          // Tampilkan ikon default
                          return CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 70,
                              color: const Color(0xFF4051B5),
                            ),
                          );
                        }
                      }),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF4051B5),
                            border: Border.all(width: 2, color: Colors.white),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _pickImageFile,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Pesan error jika ada
                if (controller.errorMessage.value.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.errorMessage.value,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Form Fields
                Text(
                  'Informasi Pribadi',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 15),

                // Nama Lengkap
                _buildTextField(
                  label: 'Nama Lengkap',
                  hintText: 'Masukkan nama lengkap',
                  controller: nameController,
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 15),

                // Email
                _buildTextField(
                  label: 'Email',
                  hintText: 'Masukkan email',
                  controller: emailController,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 15),

                // Jenis Kelamin - Dropdown
                _buildGenderDropdown(),

                const SizedBox(height: 15),

                // Nomor Telepon
                _buildTextField(
                  label: 'Nomor Telepon',
                  hintText: 'Masukkan nomor telepon',
                  controller: phoneController,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 15),

                // Alamat
                _buildTextField(
                  label: 'Alamat',
                  hintText: 'Masukkan alamat',
                  controller: addressController,
                  icon: Icons.location_on_outlined,
                  maxLines: 3,
                ),

                const SizedBox(height: 15),

                // Tanggal Lahir
                _buildDateField(context),

                const SizedBox(height: 30),

                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4051B5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Simpan',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Inisialisasi data form dengan informasi profil saat ini
  void _initializeFormData() {
    // Set nilai awal segera jika data profil sudah tersedia
    if (controller.profile.value != null &&
        controller.profile.value!.data != null) {
      _setFormValues(controller.profile.value!.data!);
    }

    // Kemudian pantau perubahan pada data profil
    ever(controller.profile, (profile) {
      if (profile != null && profile.data != null) {
        _setFormValues(profile.data!);
      }
    });
  }

  // Method helper untuk mengatur nilai form dari data profil
  void _setFormValues(dynamic data) {
    // Set text controllers
    nameController.text = data.name ?? '';
    emailController.text = data.email ?? '';
    phoneController.text = data.phoneNumber ?? '';
    addressController.text = data.address ?? '';

    // Set gender - Konversi dari 'Laki-Laki'/'Perempuan' atau 'male'/'female'
    if (data.gender != null) {
      final lowerGender = data.gender.toLowerCase();
      if (lowerGender == 'male' || lowerGender.contains('laki')) {
        selectedGender.value = 'Laki-Laki';
      } else if (lowerGender == 'female' || lowerGender.contains('perempuan')) {
        selectedGender.value = 'Perempuan';
      } else {
        // Jika nilai gender tidak standar, gunakan null
        selectedGender.value = null;
      }
    }

    // Set tanggal lahir jika tersedia
    if (data.dateOfBirth != null && data.dateOfBirth.toString().isNotEmpty) {
      try {
        final dateStr = data.dateOfBirth.toString();

        try {
          // Format ISO standard: "YYYY-MM-DD" (English format untuk API)
          selectedDate.value = DateFormat('yyyy-MM-dd').parse(dateStr);
        } catch (e1) {
          try {
            // Fallback ke DateTime.parse
            selectedDate.value = DateTime.parse(dateStr);
          } catch (e2) {
            try {
              // Coba format Indonesia: "29 Januari 2007"
              final List<String> monthsIndo = [
                'januari',
                'februari',
                'maret',
                'april',
                'mei',
                'juni',
                'juli',
                'agustus',
                'september',
                'oktober',
                'november',
                'desember'
              ];

              final parts = dateStr.split(' ');
              if (parts.length >= 3) {
                final day = int.parse(parts[0]);
                final year = int.parse(parts[2]);
                int month = 1;

                final monthName = parts[1].toLowerCase();
                final monthIndex = monthsIndo.indexOf(monthName);
                if (monthIndex >= 0) {
                  month = monthIndex + 1;
                }

                selectedDate.value = DateTime(year, month, day);
              } else {
                throw Exception('Format tanggal tidak sesuai');
              }
            } catch (e3) {
              // Gagal parse - biarkan nilai tetap null
            }
          }
        }
      } catch (e) {
        // Error umum - biarkan nilai tetap null
      }
    }
  }

  // Pilih gambar langsung dari galeri (kompatibel dengan web)
  Future<void> _pickImageFile() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        imageFile.value = image;
        
        // Untuk web, baca gambar sebagai bytes untuk preview
        if (kIsWeb) {
          webImage.value = await image.readAsBytes();
        }
      }
    } catch (e) {
      controller.errorMessage.value = 'Gagal memilih gambar: ${e.toString()}';
      print('Error saat memilih gambar: $e');
    }
  }

  // Update profil dengan atau tanpa foto
  Future<void> _updateProfile() async {
    bool success;

    // Validasi form
    if (nameController.text.isEmpty) {
      controller.errorMessage.value = 'Nama lengkap wajib diisi';
      return;
    }

    if (emailController.text.isEmpty) {
      controller.errorMessage.value = 'Email wajib diisi';
      return;
    }

    // Format tanggal untuk API (yyyy-MM-dd)
    String? formattedDate;
    if (selectedDate.value != null) {
      formattedDate = dateFormat.format(selectedDate.value!);
    }

    // Update dengan atau tanpa foto
    if (imageFile.value != null) {
      // Dengan foto
      if (kIsWeb) {
        // Di web, gunakan bytes dari gambar
        final bytes = await imageFile.value!.readAsBytes();
        success = await controller.updateProfileWithPhoto(
          name: nameController.text,
          email: emailController.text,
          gender: selectedGender.value,
          phoneNumber: phoneController.text,
          address: addressController.text,
          dateOfBirth: formattedDate,
          profilePhoto: bytes,
          fileName: imageFile.value!.name,
        );
      } else {
        // Di native, gunakan File
        success = await controller.updateProfileWithPhoto(
          name: nameController.text,
          email: emailController.text,
          gender: selectedGender.value,
          phoneNumber: phoneController.text,
          address: addressController.text,
          dateOfBirth: formattedDate,
          profilePhoto: File(imageFile.value!.path),
        );
      }
    } else {
      // Tanpa foto
      success = await controller.updateProfile(
        name: nameController.text,
        email: emailController.text,
        gender: selectedGender.value,
        phoneNumber: phoneController.text,
        address: addressController.text,
        dateOfBirth: formattedDate,
      );
    }

    if (success) {
      _showSuccessDialog(Get.context!);
    }
  }

  // Method helper untuk membangun text fields
  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, color: const Color(0xFF4051B5)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
      ],
    );
  }

  // Method helper untuk membangun dropdown jenis kelamin
  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Kelamin',
          style: GoogleFonts.poppins(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: Obx(() => DropdownButton<String>(
                  value: selectedGender.value,
                  hint: Text('Pilih jenis kelamin'),
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  style: GoogleFonts.poppins(color: Colors.black),
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'Laki-Laki',
                      child: Row(
                        children: [
                          Icon(Icons.people_outline, color: Color(0xFF4051B5)),
                          SizedBox(width: 12),
                          Text('Laki-Laki'),
                        ],
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Perempuan',
                      child: Row(
                        children: [
                          Icon(Icons.people_outline, color: Color(0xFF4051B5)),
                          SizedBox(width: 12),
                          Text('Perempuan'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      // Pastikan nilai yang dipilih sama persis dengan yang ada di items
                      if (newValue == 'Laki-Laki' || newValue == 'Perempuan') {
                        selectedGender.value = newValue;
                      }
                    }
                  },
                )),
          ),
        ),
      ],
    );
  }

  // Method helper untuk membangun field tanggal
  Widget _buildDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal Lahir',
          style: GoogleFonts.poppins(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate.value ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF4051B5),
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (picked != null && picked != selectedDate.value) {
              selectedDate.value = picked;
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    color: const Color(0xFF4051B5)),
                const SizedBox(width: 12),
                Obx(() => Text(
                      selectedDate.value != null
                          ? formatDateIndonesian(selectedDate.value!)
                          : 'Pilih tanggal lahir',
                      style: GoogleFonts.poppins(),
                    )),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Tampilkan dialog sukses
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
              Text(
                'Profil Berhasil Diperbarui',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                controller.successMessage.value,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Mengatur index tab Profile sebelum navigasi
                    final dashboardController = Get.find<DashboardController>();
                    dashboardController.selectedIndex.value =
                        2; // Mengatur tab Profile

                    // Menavigasi ke DashboardView dan menghapus halaman sebelumnya
                    Get.off(() => const DashboardView());
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
                  child: Text(
                    'Kembali ke Profile',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}