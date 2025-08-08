import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../Utils/InputField.dart';
import '../../../Utils/PrimaryButton.dart';
import '../../../Utils/validators.dart';
import '../../../constants/app_colors.dart';
import 'signup_controller.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  /* ✦ same decoration your InputField uses internally ✦ */
  InputDecoration _field(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Color(0xFFE0E0E0)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            final w      = constraints.maxWidth;
            final isWide = w > 700;

            final double cardW   = math.min(w * 0.9, 560.0);
            final double innerPd = isWide ? 32 : 24;

            return Center(
              child: Container(
                width: cardW,
                padding: EdgeInsets.all(innerPd),
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
                        // logo
                        Image.asset(
                          'assets/images/logo.png',
                          width: isWide ? cardW * 0.35 : cardW * 0.45,
                        ),
                        const SizedBox(height: 28),

                        // heading
                        Text(
                          'Sign Up',
                          style: TextStyle(
                            fontFamily: 'Cormorant Garamond',
                            fontSize: isWide ? 34 : 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // name
                        InputField(
                          hint      : 'Name',
                          controller: controller.nameC,
                          validator : Validators.notEmpty,
                        ),
                        const SizedBox(height: 20),

                        // email
                        InputField(
                          hint          : 'Email',
                          controller    : controller.emailC,
                          validator     : Validators.email,
                          textInputType : TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),

                        // date-of-birth picker (reference implementation)
                        GestureDetector(
                          onTap: () => _showDobPicker(context),
                          child: AbsorbPointer(
                            child: Obx(
                                  () => TextFormField(
                                decoration: _field(
                                  controller.dob.value == null
                                      ? 'Select Date of Birth'
                                      : DateFormat('EEE d MMM, yyyy')
                                      .format(controller.dob.value!),
                                ).copyWith(
                                  hintStyle:
                                  const TextStyle(color: Colors.black),
                                ),
                                validator: (_) => controller.dob.value == null
                                    ? 'Required'
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // next
                        PrimaryButton(
                          label : 'Next',
                          onTap : controller.next,
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

  /* ─────────────────────────────────────────────────────────────── */

  void _showDobPicker(BuildContext context) {
    final c   = controller;
    DateTime tmp = c.dob.value ?? DateTime(1990, 1, 1);

    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final scrW = MediaQuery.of(ctx).size.width;
        final width = (scrW * 0.82).clamp(0.0, 675.0) as double; // cast-to-double

        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: width,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FCFF),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Date of Birth',
                    style: TextStyle(
                      fontFamily : 'Avenir',
                      fontSize   : 20,
                      fontWeight : FontWeight.w500,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: MediaQuery.of(ctx).size.height * 0.40,
                    width: MediaQuery.of(ctx).size.height * 0.30,
                    child: CupertinoDatePicker(
                      mode            : CupertinoDatePickerMode.date,
                      maximumDate     : DateTime.now(),
                      minimumDate     : DateTime(1900),
                      initialDateTime : tmp,
                      onDateTimeChanged: (d) => tmp = d,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label : 'Select',
                      onTap : () {
                        c.dob.value = tmp;
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
