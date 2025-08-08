// lib/Views/Auth/Password/password_view.dart
// ignore_for_file: use_key_in_widget_constructors
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Utils/InputField.dart';
import '../../../constants/app_colors.dart';
import '../../../Utils/PrimaryButton.dart';
import '../../../Utils/validators.dart';
import 'password_controller.dart';

class PasswordView extends GetView<PasswordController> {
  const PasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final title = controller.isReset ? 'Reset password' : 'Create password';
    final btn   = controller.isReset ? 'Reset password' : 'Sign Up';

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            final w = constraints.maxWidth;
            final isWide = w > 700;

            // Card width: 90 % of screen, capped
            final cardWidth = math.min(w * 0.9, 560.0);
            final innerPad  = isWide ? 32.0 : 24.0;
            final headingSz = isWide ? 32.0 : 28.0;

            return Center(
              child: Container(
                width: cardWidth,
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
                child: SingleChildScrollView(
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        /* ── Heading ── */
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Cormorant Garamond',
                            fontSize: headingSz,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 32),

                        /* ── Password ── */
                        Obx(() => InputField(
                          hint: 'Password',
                          controller: controller.passC,
                          validator: Validators.password,
                          obscure: controller.hide1.value,
                          suffix: IconButton(
                            icon: Icon(controller.hide1.value
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: controller.toggle1,
                          ),
                        )),
                        const SizedBox(height: 20),

                        /* ── Confirm ── */
                        Obx(() => InputField(
                          hint: 'Confirm password',
                          controller: controller.confirmC,
                          validator: Validators.password,
                          obscure: controller.hide2.value,
                          suffix: IconButton(
                            icon: Icon(controller.hide2.value
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: controller.toggle2,
                          ),
                        )),
                        const SizedBox(height: 36),

                        /* ── SAVE button ── */
                        PrimaryButton(
                          label: btn,
                          onTap: controller.save,
                        ),
                        const SizedBox(height: 12),

                        if (!controller.isReset)
                          const Text(
                            'By continuing you agree to our Terms & Conditions',
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
