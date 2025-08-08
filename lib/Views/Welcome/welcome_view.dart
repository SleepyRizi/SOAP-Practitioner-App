import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Utils/PrimaryButton.dart';     // adjust path if different
import '../../constants/app_colors.dart';
import 'welcome_controller.dart';

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final isWide = w > 700;

            // Responsive sizes
            final double logoSize   = math.min(isWide ? w * 0.22 : w * 0.45, 320);
            final double headingSz  = isWide ? 48 : 36;
            final double subSz      = isWide ? 20 : 16;
            final double boxWidth   = math.min(w * 0.85, 520);

            return Container(
              width: w,
              height: h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondary,
                    Color(0xFFE3F0F4),
                  ],
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: boxWidth),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ─── Logo ───
                        Image.asset(
                          'assets/images/logo.png',
                          width: logoSize,
                          height: logoSize,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(height: 32),

                        // ─── Heading ───
                        Text(
                          'Welcome to\nBalance & Awareness',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: headingSz,
                            fontFamily: 'Cormorant Garamond',
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.4,
                            height: 1.1,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ─── Sub-heading ───
                        Text(
                          'Your spiritual journey begins here!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: subSz,
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.2,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // ─── Buttons ───
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            label: 'Create a new account',
                            onTap: controller.toSignup,
                          ),
                        ),
                        // const SizedBox(height: 16),
                        // PrimaryButton(
                        //   label: 'Continue with Google',
                        //   outlined: true,
                        //   iconAsset: 'assets/images/devicon_google.png',
                        //   onTap: () => Get.snackbar(
                        //     'Notice',
                        //     'Google sign-in pending integration',
                        //   ),
                        // ),

                        const SizedBox(height: 32),

                        // ─── Login shortcut ───
                        GestureDetector(
                          onTap: controller.toLogin,
                          child: Text(
                            'I already have an account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: subSz,
                              fontFamily: 'Avenir',
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration
                                  .none, // underline removed
                            ),
                          ),
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
