import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});
  @override
  Widget build(BuildContext context) {
    DashboardController controller = Get.put(DashboardController());
    return Obx(
      () => Scaffold(
        body: Navigator(
          key: Get.nestedKey(1),
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (_) => controller.pages[controller.selectedIndex.value],
            );
          },
        ),
        bottomNavigationBar: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home,
                label: 'Home',
                controller: controller,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.person,
                label: 'Profile',
                controller: controller,
              ),
              // Contoh menambah item navigasi ketiga:
              // _buildNavItem(
              //   index: 2, // Pastikan index bertambah secara berurutan
              //   icon: Icons.notifications, // Pilih icon yang sesuai
              //   label: 'Notifikasi', // Label yang akan ditampilkan
              //   controller: controller,
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required DashboardController controller,
  }) {
    final isSelected = controller.selectedIndex.value == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          controller.changeIndex(index);
          Get.nestedKey(1)!.currentState!.pushReplacement(
                MaterialPageRoute(
                  builder: (_) => controller.pages[index],
                ),
              );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF4F4FCB) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF4F4FCB) : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}