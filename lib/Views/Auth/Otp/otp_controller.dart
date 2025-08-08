import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Services/auth_service.dart';
import '../../../Utils/otp_timer.dart';
import '../../../routes/app_pages.dart';

class OtpController extends GetxController {
  final email   = Get.arguments['email'] as String;
  final name    = Get.arguments['name'] as String?; // only in sign‑up
  final flow    = Get.arguments['flow'] as String;  // 'signup' | 'reset'
  final codeC   = TextEditingController();
  late final OtpTimerController timerC;

  @override
  void onInit() {
    timerC = OtpTimerController(60);
    super.onInit();
  }

  Future<void> verify() async {
    final auth = Get.find<AuthService>();
    final ok = flow == 'signup'
        ? await auth.verifySignupOtp(email, codeC.text)
        : await auth.verifyResetOtp(email, codeC.text);

    if (!ok) {
      Get.snackbar('Oops', 'Invalid or expired OTP');
      return;
    }
    if (flow == 'signup') {
      Get.toNamed(Routes.pickPassword,
          arguments: {'email': email, 'name': name});
    } else {
      Get.toNamed(Routes.pickPassword,
          arguments: {'email': email, 'reset': true});
    }
  }

  Future<void> resend() async {
    await (flow == 'signup'
        ? Get.find<AuthService>().sendSignupOtp(email)
        : Get.find<AuthService>().sendResetOtp(email));
    timerC = OtpTimerController(60);
  }
}
