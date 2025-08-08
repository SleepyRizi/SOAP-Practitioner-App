import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';
import '../../../Services/auth_service.dart';

class LoginController extends GetxController {
  final formKey   = GlobalKey<FormState>();
  final emailC    = TextEditingController();
  final passwordC = TextEditingController();

  final RxBool hidePass = true.obs;

  void toggleHide() => hidePass.toggle();

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;
    try {
      await Get.find<AuthService>()
          .login(emailC.text.trim(), passwordC.text.trim());
      Get.offAllNamed(Routes.home);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void toSignup() => Get.toNamed(Routes.signup);
  void toForgot() => Get.toNamed(Routes.forgot);
}
