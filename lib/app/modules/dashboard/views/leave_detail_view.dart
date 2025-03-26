import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ujikom/app/modules/leave/controllers/leave_controller.dart';
import 'package:ujikom/app/data/get_leave_response.dart';

class LeaveDetailView extends GetView<LeaveController> {
  const LeaveDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller and fetch data immediately
    final controller = Get.put(LeaveController());
    // Fetch leave data when the view is first built
    controller.fetchLeave();
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF4051B5),
        title: Text(
          'Riwayat Cuti',
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
        // Checking if loading is true and displaying a loading indicator
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        // Display the leave history content after fetching
        return LeaveHistoryContent(leaveController: controller);
      }),
    );
  }
}

class LeaveHistoryContent extends StatelessWidget {
  final LeaveController leaveController;

  const LeaveHistoryContent({super.key, required this.leaveController});

  @override
  Widget build(BuildContext context) {
    // List of categories to filter by
    final filterOptions = [
      'Semua',
      'Sakit',
      'Acara Keluarga',
      'Liburan',
      'Hamil'
    ];

    // Observables for filter and pagination
    final selectedFilter = 'Semua'.obs;
    final currentPage = 0.obs;
    final itemsPerPage = 6;

    // Function to format date from string to readable format
    String formatDate(String? dateString) {
      if (dateString == null) return '';
      try {
        final date = DateTime.parse(dateString);
        return DateFormat('dd MMM yyyy').format(date);
      } catch (e) {
        return '';
      }
    }

    // Function to calculate the number of days between two dates
    int calculateDays(String? startDate, String? endDate) {
      if (startDate == null || endDate == null) return 0;
      try {
        final start = DateTime.parse(startDate);
        final end = DateTime.parse(endDate);
        return end.difference(start).inDays + 1;
      } catch (e) {
        return 0;
      }
    }

    // Function to map API status to display status
    String getDisplayStatus(String? apiStatus) {
      if (apiStatus == null) return 'Pending';
      switch (apiStatus.toLowerCase()) {
        case 'approved':
          return 'Disetujui';
        case 'rejected':
          return 'Ditolak';
        default:
          return 'Pending';
      }
    }

    // Function to filter leave items based on selected filter
    List<Data> getFilteredLeaveItems() {
      if (leaveController.get_leave.value == null ||
          leaveController.get_leave.value!.data == null) {
        return [];
      }

      final allLeaves = leaveController.get_leave.value!.data!;

      if (selectedFilter.value == 'Semua') {
        return allLeaves;
      } else {
        String apiCategory;
        switch (selectedFilter.value) {
          case 'Sakit':
            apiCategory = 'sakit';
            break;
          case 'Acara Keluarga':
            apiCategory = 'acara_keluarga';
            break;
          case 'Liburan':
            apiCategory = 'liburan';
            break;
          case 'Hamil':
            apiCategory = 'hamil';
            break;
          default:
            apiCategory = selectedFilter.value.toLowerCase();
        }

        return allLeaves
            .where((leave) =>
                leave.categoriesLeave?.toLowerCase() ==
                apiCategory.toLowerCase())
            .toList();
      }
    }

    // Function to get paginated leave items
    List<Data> getPaginatedData() {
      final filteredData = getFilteredLeaveItems();
      final totalPages = (filteredData.length / itemsPerPage).ceil();

      if (currentPage.value >= totalPages && totalPages > 0) {
        currentPage.value = totalPages - 1;
      }

      final startIndex = currentPage.value * itemsPerPage;
      final endIndex = startIndex + itemsPerPage > filteredData.length
          ? filteredData.length
          : startIndex + itemsPerPage;

      if (startIndex < filteredData.length) {
        return filteredData.sublist(startIndex, endIndex);
      } else {
        return [];
      }
    }

    // Function to calculate total pages
    int getTotalPages() {
      final filteredData = getFilteredLeaveItems();
      return (filteredData.length / itemsPerPage).ceil();
    }

    // Function to go to the next page
    void nextPage() {
      if (currentPage.value < getTotalPages() - 1) {
        currentPage.value++;
      }
    }

    // Function to go to the previous page
    void previousPage() {
      if (currentPage.value > 0) {
        currentPage.value--;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter option UI
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Text(
                  'Filter',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Obx(() => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedFilter.value,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Color(0xFF4051B5)),
                        dropdownColor: Colors.white,
                        items: filterOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            selectedFilter.value = newValue;
                            currentPage.value = 0; // Reset to first page when filtering
                          }
                        },
                      ),
                    )),
                  ),
                ),
              ],
            ),
          ),

          // Leave list and empty states
          Obx(() {
            if (leaveController.get_leave.value == null ||
                leaveController.get_leave.value!.data == null ||
                leaveController.get_leave.value!.data!.isEmpty) {
              return const Expanded(
                child: Center(
                  child: Text(
                    'Tidak ada data riwayat cuti',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            } else {
              final paginatedData = getPaginatedData();
              
              if (paginatedData.isEmpty) {
                return Expanded(
                  child: Center(
                    child: Text(
                      'Tidak ada data untuk kategori "${selectedFilter.value}"',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              }
              
              // Leave history list
              return Expanded(
                child: ListView.builder(
                  itemCount: paginatedData.length,
                  itemBuilder: (context, index) {
                    final leave = paginatedData[index];
                    return LeaveHistoryCard(leaveData: leave);
                  },
                ),
              );
            }
          }),

          // Pagination controls
          Obx(() {
            final filteredItems = getFilteredLeaveItems();
            final totalPages = getTotalPages();
            
            if (filteredItems.isEmpty) {
              return const SizedBox.shrink();
            }

            return Container(
              margin: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: currentPage.value > 0
                          ? const Color(0xFF4051B5)
                          : Colors.grey.shade400,
                    ),
                    onPressed: previousPage,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4051B5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${currentPage.value + 1} / ${totalPages > 0 ? totalPages : 1}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: currentPage.value < totalPages - 1
                          ? const Color(0xFF4051B5)
                          : Colors.grey.shade400,
                    ),
                    onPressed: nextPage,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class LeaveHistoryCard extends StatelessWidget {
  final Data leaveData;

  const LeaveHistoryCard({super.key, required this.leaveData});

  String formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return '';
    }
  }

  // Calculate the date range string
  String get formattedDates {
    final startFormatted = formatDate(leaveData.startDate);
    final endFormatted = formatDate(leaveData.endDate);
    return '$startFormatted - $endFormatted';
  }

  // Calculate the number of days
  int get days {
    if (leaveData.startDate == null || leaveData.endDate == null) return 0;
    try {
      final start = DateTime.parse(leaveData.startDate!);
      final end = DateTime.parse(leaveData.endDate!);
      return end.difference(start).inDays + 1;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String displayStatus;

    if (leaveData.status == 'approved') {
      statusColor = Colors.green;
      displayStatus = 'Disetujui';
    } else if (leaveData.status == 'rejected') {
      statusColor = Colors.red;
      displayStatus = 'Ditolak';
    } else {
      statusColor = Colors.orange;
      displayStatus = 'Pending';
    }
    
    IconData typeIcon;
    String displayType = '';

    switch (leaveData.categoriesLeave) {
      case 'sakit':
        typeIcon = Icons.medical_services;
        displayType = 'Sakit';
        break;
      case 'acara_keluarga':
        typeIcon = Icons.family_restroom;
        displayType = 'Acara Keluarga';
        break;
      case 'liburan':
        typeIcon = Icons.beach_access;
        displayType = 'Liburan';
        break;
      case 'hamil':
        typeIcon = Icons.pregnant_woman;
        displayType = 'Hamil';
        break;
      default:
        typeIcon = Icons.event_note;
        displayType = leaveData.categoriesLeave ?? 'Lainnya';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4051B5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                typeIcon,
                color: const Color(0xFF4051B5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayType,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$formattedDates ($days hari)',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                displayStatus,
                style: GoogleFonts.poppins(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}