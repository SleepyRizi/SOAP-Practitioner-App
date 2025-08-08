// lib/Views/Auth/ResetSuccess/reset_success_view.dart
// ignore_for_file: use_key_in_widget_constructors
//
// PASSWORD-RESET SUCCESS POP-UP  – matches Figma rectangle-192

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../../constants/app_colors.dart';
import '../../../Utils/PrimaryButton.dart';

class ResetSuccessView extends StatelessWidget {
  const ResetSuccessView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: LayoutBuilder(builder: (ctx, cons) {
          final w        = cons.maxWidth;
          final h        = cons.maxHeight;
          final cardW    = math.min(w * 0.9, 572.0);   // <= 572 px
          final cardH    = math.min(h * 0.75, 522.0);  // <= 522 px
          final innerPad = w > 700 ? 32.0 : 24.0;

          return Center(
            child: Container(
              width: cardW,
              height: cardH,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /* ── success illustration ── */
                  Image.asset(
                    'assets/images/complete_mask.png',
                    width: cardW * 0.38,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),

                  /* ── headline ── */
                  const Text(
                    'Password reset!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  /* ── helper line ── */
                  const Text(
                    'Your password was updated successfully.\n'
                        'You can now log in with it.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Avenir',
                      fontWeight: FontWeight.w300,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const Spacer(),

                  /* ── button ── */
                  PrimaryButton(
                    label: 'Back to login',
                    onTap: () => Get.offAllNamed(Routes.login),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
