// lib/Views/Success/success_view.dart
// ignore_for_file: use_key_in_widget_constructors
//
// “Form submitted” success popup

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Utils/PrimaryButton.dart';
import '../../Routes/app_pages.dart';
import '../../constants/app_colors.dart';

class SuccessView extends StatelessWidget {
  const SuccessView();

  @override
  Widget build(BuildContext context) {
    final vw    = MediaQuery.of(context).size.width;
    final vh    = MediaQuery.of(context).size.height;
    final cardW = (vw * 0.9).clamp(0.0, 572.0);   // 90 % width, max 572 px
    final cardH = (vh * 0.7).clamp(420.0, 650.0); // ~70 % height, min 420

    return Scaffold(
      backgroundColor: const Color(0xFFFAFDFF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              width: cardW,
              height: cardH,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /* ────── success graphic ────── */
                  Image.asset(
                    'assets/images/complete_mask.png',
                    width: 222,
                    height: 222,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 30),

                  /* ────── headline ────── */
                  const Text(
                    'Form submitted successfully!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 40),

                  /* ────── action button ────── */
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: 'Back to Home',
                      onTap: () => Get.offAllNamed(Routes.home),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
