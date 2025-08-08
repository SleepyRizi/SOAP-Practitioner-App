// ignore_for_file: use_key_in_widget_constructors
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Constants/app_colors.dart';
import '../../../Routes/app_pages.dart';
import '../../../Utils/PrimaryButton.dart';


class PasswordUpdateSuccessView extends StatefulWidget {
  const PasswordUpdateSuccessView({super.key});

  @override
  State<PasswordUpdateSuccessView> createState() =>
      _PasswordUpdateSuccessViewState();
}

class _PasswordUpdateSuccessViewState
    extends State<PasswordUpdateSuccessView> {
  @override
  void initState() {
    super.initState();
    // auto-navigate to Home after 2.5 s
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) Get.offAllNamed(Routes.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    final w       = MediaQuery.of(context).size.width;
    final isWide  = w > 700;
    final cardW   = math.min(w * 0.9, 560.0);
    final heading = isWide ? 32.0 : 28.0;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Center(
        child: Container(
          width: cardW,
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 32 : 24,
            vertical: isWide ? 40 : 32,
          ),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/complete_mask.png',
                width: isWide ? cardW * 0.35 : cardW * 0.45,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 28),
              Text(
                'Account created\nSuccessfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: heading,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 36),
              PrimaryButton(
                label: 'Go to Home',
                onTap: () => Get.offAllNamed(Routes.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
