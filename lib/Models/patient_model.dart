import 'package:cloud_firestore/cloud_firestore.dart';
import 'assessment_model.dart';

class PatientModel {
  final String referral;       // primary id (doc id)
  final String firstName;
  final String lastName;
  final DateTime dob;
  final List<AssessmentModel> history;

  PatientModel({
    required this.referral,
    required this.firstName,
    required this.lastName,
    required this.dob,
    this.history = const [],
  });

  factory PatientModel.fromDoc(DocumentSnapshot doc,
      {List<AssessmentModel> history = const []}) {
    final d = doc.data()! as Map<String, dynamic>;
    return PatientModel(
      referral: doc.id,
      firstName: d['firstName'],
      lastName: d['lastName'],
      dob: (d['dob'] as Timestamp).toDate(),
      history: history,
    );
  }

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'dob': Timestamp.fromDate(dob),
  };
}
