import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Services/auth_service.dart';
import '../../../routes/app_pages.dart';

class SignupController extends GetxController {
  /* ─────────────── Form state ─────────────── */

  final formKey = GlobalKey<FormState>();

  final nameC  = TextEditingController();
  final emailC = TextEditingController();

  /// Selected date of birth (bound by the view).
  final Rx<DateTime?> dob = Rx<DateTime?>(null);

  /* ─────────────── Actions ─────────────── */

  Future<void> next() async {
    // Validate name, email, and DOB (the latter via separate check).
    if (!formKey.currentState!.validate()) return;
    if (dob.value == null) {
      Get.snackbar('Oops', 'Please select your date of birth');
      return;
    }

    // Send OTP …
    await Get.find<AuthService>().sendSignupOtp(emailC.text.trim());

    // … then navigate to the OTP screen with all required data.
    Get.toNamed(
      Routes.otp,
      arguments: {
        'email' : emailC.text.trim(),
        'name'  : nameC.text.trim(),
        'dob'   : dob.value,        // pass along for later steps
        'flow'  : 'signup',
      },
    );
  }
}
