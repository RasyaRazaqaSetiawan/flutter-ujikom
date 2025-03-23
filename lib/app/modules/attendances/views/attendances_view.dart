import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/attendances_controller.dart';

class AttendancesView extends GetView<AttendancesController> {
  const AttendancesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AttendancesView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AttendancesView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
