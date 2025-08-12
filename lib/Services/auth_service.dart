// Practitioner-side Auth service
// Updated 2025-08-07 (type-safe map casts)
//
// – Identical public API to previous snippet.
// – streamRoleOk / hasPractitionerRole now cast data → Map<String,dynamic>
//   before indexing, so static analysis is happy.

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';


/// Quick date ranges for the filters dialog.
enum _QuickRange { today, last7, all }

/// Sort choices for the filters dialog.
enum _Sort { nameAsc, lastVisitDesc }

class AuthService extends GetxService {
  final _auth      = FirebaseAuth.instance;
  final _db        = FirebaseFirestore.instance;
  CollectionReference get _otpCol => _db.collection('emailOtps');
  final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');



  User? get currentUser => _auth.currentUser;

  /* ─────────────── PRACTITIONER ROLE HELPERS ─────────────── */

  CollectionReference get _users => _db.collection('users');

  Future<bool> hasPractitionerRole() async {
    final uid = currentUser?.uid;
    if (uid == null) return false;

    final snap = await _users.doc(uid).get();
    final map  = snap.data() as Map<String, dynamic>?;   // ⬅️ cast first
    final role = map?['role'] as String?;
    return role == 'practitioner' || role == 'admin';
  }

  Stream<bool> streamRoleOk() => _users
      .doc(currentUser?.uid)
      .snapshots()
      .map((snap) {
    final map  = snap.data() as Map<String, dynamic>?; // ⬅️ cast first
    final role = map?['role'] as String?;
    return role == 'practitioner' || role == 'admin';
  });

  /* ──────────── OTP-based sign-up / reset (unchanged) ──────────── */

  Future<void> sendSignupOtp(String email) => _sendOtp(email, purpose: _OtpPurpose.signup);
  Future<bool>  verifySignupOtp(String email, String code) => _verifyOtp(email, code);

  Future<UserCredential> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email, password: password,
    );
    await cred.user!.updateDisplayName(name);

    // Mark as practitioner by default
    await _users.doc(cred.user!.uid).set(
      {'role': 'practitioner', 'name': name, 'email': email},
      SetOptions(merge: true),
    );
    return cred;
  }

  Future<void> sendResetOtp(String email) => _sendOtp(email, purpose: _OtpPurpose.reset);
  Future<bool>  verifyResetOtp(String email, String code) => _verifyOtp(email, code);

  Future<void> resetPasswordOnServer({
    required String email,
    required String newPassword,
  }) async {
    final callable = _functions.httpsCallable('forceResetPassword');
    await callable.call({'email': email, 'newPassword': newPassword});
  }

  /* ─────────── login / logout ─────────── */

  Future<UserCredential> login(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> logout() => _auth.signOut();

  /* ─────────── INTERNAL OTP UTILS ─────────── */

  Future<void> _sendOtp(String email, {required _OtpPurpose purpose}) async {
    final code = (Random().nextInt(90000) + 10000).toString(); // 10000–99999

    await _otpCol.doc(email).set({
      'code'      : code,
      'purpose'   : purpose.name,
      'expiresAt' : Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
    });

    final callable = _functions.httpsCallable('sendOtpEmail');
    await callable.call({
      'email'   : email,
      'code'    : code,
      'purpose' : purpose.name,
    });
  }

  Future<bool> _verifyOtp(String email, String code) async {
    final snap = await _otpCol.doc(email).get();
    if (!snap.exists) return false;

    final data   = snap.data() as Map<String, dynamic>;
    final stored = data['code'].toString();
    final expiry = (data['expiresAt'] as Timestamp).toDate();

    return stored == code && expiry.isAfter(DateTime.now());
  }
}

enum _OtpPurpose { signup, reset }
