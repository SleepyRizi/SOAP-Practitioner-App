// lib/modules/auth/password/password_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';
import '../../../Models/user_model.dart';
import '../../../Services/auth_service.dart';
import '../../../Services/firestore_service.dart';

class PasswordController extends GetxController {
  // ── Args from previous screen ──
  final String email   = Get.arguments['email'];          // always present
  final bool   isReset = (Get.arguments['reset'] ?? false);
  final String? name   = Get.arguments['name'];           // sign‑up only

  // ── Form state ──
  final formKey  = GlobalKey<FormState>();
  final passC    = TextEditingController();
  final confirmC = TextEditingController();
  final hide1    = true.obs;
  final hide2    = true.obs;

  void toggle1() => hide1.toggle();
  void toggle2() => hide2.toggle();

  // ── Main action ──
  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    if (passC.text != confirmC.text) {
      Get.snackbar('Oops', 'Passwords do not match');
      return;
    }

    final auth = Get.find<AuthService>();

    if (isReset) {
      // ───────────── PASSWORD‑RESET MODE ─────────────
      await auth.resetPasswordOnServer(
        email: email,
        newPassword: passC.text.trim(),
      );
      Get.offAllNamed(Routes.resetSuccess);
    } else {
      // ───────────── SIGN‑UP MODE ─────────────
      final cred = await auth.createUser(
        name: name!,
        email: email,
        password: passC.text.trim(),
      );


      await Get.find<FirestoreService>().saveUser(                // ⬅️ use the service
        UserModel(
          uid  : cred.user!.uid,
          name : name!,
          email: email,
        ),
      );



      Get.offAllNamed(Routes.home);
    }
  }
}
