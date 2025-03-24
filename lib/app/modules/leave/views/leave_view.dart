import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/leave_controller.dart';

class LeaveView extends GetView<LeaveController> {
  const LeaveView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LeaveView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'LeaveView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
