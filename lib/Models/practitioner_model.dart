import 'package:cloud_firestore/cloud_firestore.dart';

/// Minimal record for a practitioner account.
/// Extend later with specialty, license-ID, avatar URL, etc.
class PractitionerModel {
  final String uid;          // same as Firebase-Auth uid
  final String name;
  final String email;
  final DateTime dob;

  PractitionerModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.dob,
  });

  /* ───────────── Firestore helpers ───────────── */

  factory PractitionerModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PractitionerModel(
      uid   : doc.id,
      name  : data['name']  ?? '',
      email : data['email'] ?? '',
      dob   : (data['dob'] as Timestamp?)?.toDate() ?? DateTime(1970, 1, 1),
    );
  }

  Map<String, dynamic> toJson() => {
    'name' : name,
    'email': email,
    'dob'  : Timestamp.fromDate(dob),
  };
}
