import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';
import '../../../Services/auth_service.dart';


class ForgotPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailC  = TextEditingController();

  Future<void> requestOtp() async {
    if (!formKey.currentState!.validate()) return;
    await Get.find<AuthService>().sendResetOtp(emailC.text.trim());
    Get.toNamed(Routes.otp, arguments: {
      'email': emailC.text.trim(),
      'flow' : 'reset'
    });
  }
}
