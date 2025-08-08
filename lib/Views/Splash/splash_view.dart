import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Constants/app_colors.dart';
import 'splash_controller.dart';


class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            children: [
              // ─────── Logo (center) ───────
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: isLandscape
                        ? constraints.maxWidth * 0.35
                        : constraints.maxWidth * 0.55,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // ─────── Tagline (bottom) ───────
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Text(
                  'Balance & Awareness',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 30,
                    fontFamily: 'Cormorant Garamond',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
