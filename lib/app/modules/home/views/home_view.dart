import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:lottie/lottie.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    HomeController controller = Get.put(HomeController());
    return Scaffold(
      /// The line `backgroundColor: HexColor('#feeee')` in the code snippet is setting the background
      /// color of the Scaffold widget to a color represented by the hexadecimal value `#feeee`.
      /// The line `backgroundColor: HexColor('#feeee')` in the code snippet is setting the background
      /// color of the Scaffold widget to a color represented by the hexadecimal value `#feeee`. This
      /// means that the background color of the screen will be a light shade represented by the
      /// hexadecimal color code `#feeee`.
      backgroundColor: HexColor('#ecf3fc'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Lottie.network(
            //   'https://gist.githubusercontent.com/olipiskandar/2095343e6b34255dcfb042166c4a3283/raw/d76e1121a2124640481edcf6e7712130304d6236/praujikom_kucing.json',
            //   fit: BoxFit.cover,
            // ),
                Image.asset(
                'assets/images/Logo.png', // Ganti dengan lokasi gambar logo
                width: 300,
                height: 300,
                fit: BoxFit.contain,
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}
