// lib/Views/Auth/ForgotPassword/forgot_password_view.dart
// ignore_for_file: use_key_in_widget_constructors
//
// FORGOT-PASSWORD  –  matches Figma rectangle-192 card

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/app_colors.dart';
import '../../../Utils/InputField.dart';
import '../../../Utils/PrimaryButton.dart';
import '../../../Utils/validators.dart';
import 'forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: LayoutBuilder(builder: (ctx, cons) {
          final w         = cons.maxWidth;
          final isWide    = w > 700;
          final cardW     = math.min(w * 0.9, 572.0);   // ≤ 572 px
          final innerPad  = isWide ? 32.0 : 24.0;

          return Center(
            child: Container(
              width: cardW,
              padding: EdgeInsets.all(innerPad),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 18,
                    offset: Offset(0, 4),
                    color: Colors.black12,
                  ),
                ],
              ),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /* ───── Heading ───── */
                    Center(
                      child: Text(
                        'Forgot password',
                        style: TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: isWide ? 32 : 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    /* ───── Helper line ───── */
                    const Text(
                      'Enter the e-mail linked to your account and we’ll send you an OTP.',
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w300,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    /* ───── Email ───── */
                    InputField(
                      hint: 'E-mail',
                      controller: controller.emailC,
                      validator: Validators.email,
                      textInputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 36),

                    /* ───── Request OTP ───── */
                    PrimaryButton(
                      label: 'Request OTP',
                      onTap: controller.requestOtp,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
