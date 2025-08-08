// lib/Views/Auth/Otp/otp_view.dart
// ignore_for_file: use_key_in_widget_constructors
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../constants/app_colors.dart';
import '../../../Utils/PrimaryButton.dart';
import 'otp_controller.dart';

class OtpView extends GetView<OtpController> {
  static const int codeLength = 5;

  @override
  Widget build(BuildContext context) {
    final ctrls =
    List<TextEditingController>.generate(codeLength, (_) => TextEditingController());
    final nodes = List<FocusNode>.generate(codeLength, (_) => FocusNode());

    void hop(String v, int i) {
      if (v.isNotEmpty && i < codeLength - 1) {
        nodes[i + 1].requestFocus();
      } else if (v.isEmpty && i > 0) {
        nodes[i - 1].requestFocus();
      }
    }

    String combined() => ctrls.map((c) => c.text).join();

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (ctx, c) {
            final w = c.maxWidth;
            final isWide = w > 700;

            final cardW   = math.min(w * 0.9, 560.0);
            final heading = isWide ? 32.0 : 28.0;

            return Center(
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
                    /* Heading */
                    Text('Please check your email',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: heading,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 8),
                    Text(
                      'We’ve sent a one-time confirmation code to\n${controller.email}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isWide ? 18 : 16,
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 32),

                    /* OTP boxes */
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        codeLength,
                            (i) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6), // tighter gap
                          child: SizedBox(
                            width: 56,  // slightly wider
                            height: 60,
                            child: TextField(
                              controller: ctrls[i],
                              focusNode: nodes[i],
                              maxLength: 1,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                // white fill ⇒ no fillColor
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                  const BorderSide(color: AppColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: AppColors.otpBoxFocused, width: 2),
                                ),
                              ),
                              onChanged: (v) => hop(v, i),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /* Timer / resend */
                    Obx(() {
                      final secs = controller.timerC.timeLeft.value;
                      final canResend = secs == 0;
                      return GestureDetector(
                        onTap: canResend ? controller.resend : null,
                        child: Text(
                          canResend
                              ? 'Send again'
                              : 'Send again 00:${secs.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w400,
                            color: canResend
                                ? AppColors.primary
                                : const Color(0xFF696969),
                            decoration: canResend
                                ? TextDecoration.underline
                                : TextDecoration.none,
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 32),

                    /* VERIFY */
                    PrimaryButton(
                      label: 'Verify',
                      onTap: () {
                        final code = combined();
                        if (code.length != codeLength) {
                          Get.snackbar('Invalid', 'Enter the full code');
                          return;
                        }
                        controller.codeC.text = code;
                        controller.verify();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
