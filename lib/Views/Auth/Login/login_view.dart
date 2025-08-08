// lib/Views/Auth/Login/login_view.dart
// ignore_for_file: use_key_in_widget_constructors
//
// LOGIN  –  updated link positions / colors

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/app_colors.dart';
import '../../../Utils/InputField.dart';
import '../../../Utils/PrimaryButton.dart';
import '../../../Utils/validators.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: LayoutBuilder(builder: (ctx, cons) {
          final w       = cons.maxWidth;
          final isWide  = w > 700;
          final cardW   = math.min(w * 0.9, 560.0);
          final pad     = isWide ? 32.0 : 24.0;

          /* shared link style – black text, subtle ripple */
          final linkStyle = TextButton.styleFrom(
            foregroundColor: Colors.black,
            textStyle: const TextStyle(
              fontFamily: 'Avenir',
              fontWeight: FontWeight.w400,
            ),
            overlayColor: Colors.grey.withOpacity(.15),
          );

          return Center(
            child: Container(
              width: cardW,
              padding: EdgeInsets.all(pad),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 18,
                    offset: Offset(0, 4),
                    color: Colors.black12,
                  )
                ],
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      /* ───── Logo ───── */
                      Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: isWide ? cardW * 0.35 : cardW * 0.45,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 28),

                      /* ───── Heading ───── */
                      Center(
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontFamily: 'Cormorant Garamond',
                            fontSize: isWide ? 34 : 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      /* ───── Email ───── */
                      InputField(
                        hint: 'Email',
                        controller: controller.emailC,
                        validator: Validators.email,
                        textInputType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),

                      /* ───── Password ───── */
                      Obx(() => InputField(
                        hint: 'Password',
                        controller: controller.passwordC,
                        validator: Validators.password,
                        obscure: controller.hidePass.value,
                        suffix: IconButton(
                          icon: Icon(controller.hidePass.value
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: controller.toggleHide,
                        ),
                      )),
                      const SizedBox(height: 8),

                      /* ───── Forgot password (left-aligned) ───── */
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          style: linkStyle,
                          onPressed: controller.toForgot,
                          child: const Text('Forgot password?'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      /* ───── Sign-up (center) ───── */
                      Center(
                        child: TextButton(
                          style: linkStyle,
                          onPressed: controller.toSignup,
                          child:
                          const Text("Don't have an account?  Sign-up"),
                        ),
                      ),
                      const SizedBox(height: 24),

                      /* ───── LOGIN button ───── */
                      PrimaryButton(
                        label: 'Login',
                        onTap: controller.login,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
