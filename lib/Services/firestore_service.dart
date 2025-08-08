// Practitioner-side Firestore service
//
// ──────────────────────────────────────────────────────────────
// ❶  New capabilities
//     • streamWaitingPatients() – real-time list of “waiting” patients
//     • streamIncompleteAssessments() – real-time drafts per patient
//     • savePractitionerAnalysis() – upsert practitioner’s note/plan
// ❷  Keeps all read helpers from the client app so shared code compiles
// ──────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/patient_model.dart';
import '../Models/assessment_model.dart';
import '../Models/practitioner_model.dart';
import '../Models/user_model.dart';       // Optional: practitioner profile

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // Top-level collections
  CollectionReference get _users       => _db.collection('users');
  CollectionReference get _patients    => _db.collection('patients');
  CollectionReference get _practitioners => _db.collection('practitioners');

  /* ─────────────── USERS / PRACTITIONERS ─────────────── */

  Future<void> savePractitionerProfile(PractitionerModel p) =>
      _practitioners.doc(p.uid).set(p.toJson(), SetOptions(merge: true));

  Stream<PractitionerModel> streamPractitioner(String uid) =>
      _practitioners.doc(uid).snapshots().map(PractitionerModel.fromDoc);

  /* ─────────────── PATIENT LISTS ─────────────── */

  /// Live list of patients whose **status == "waiting"**.
  Stream<List<PatientModel>> streamWaitingPatients() =>
      _patients
          .where('status', isEqualTo: 'waiting')
          .orderBy('createdAt')
          .snapshots()
          .map((s) => s.docs.map(PatientModel.fromDoc).toList());

  /// All draft / incomplete assessments for one patient.
  Stream<List<AssessmentModel>> streamIncompleteAssessments(String referral) =>
      _patients
          .doc(referral)
          .collection('assessments')
          .where('status', isEqualTo: 'incomplete')
          .orderBy('createdAt')
          .snapshots()
          .map((s) => s.docs.map(AssessmentModel.fromDoc).toList());

  /* ─────────────── PATIENT READ (unchanged) ─────────────── */

  Future<PatientModel?> getPatientByReferral(String referral) async {
    final patientDoc = await _patients.doc(referral).get();
    if (!patientDoc.exists) return null;

    final historySnap = await _patients
        .doc(referral)
        .collection('assessments')
        .where(FieldPath.documentId, isNotEqualTo: '_draft')
        .orderBy('createdAt', descending: true)
        .get();

    final history = historySnap.docs.map(AssessmentModel.fromDoc).toList();
    return PatientModel.fromDoc(patientDoc, history: history);
  }

  Future<void> saveUser(UserModel u) =>
      _users.doc(u.uid).set(u.toJson(), SetOptions(merge: true));

  /// Optional: real-time user stream (also used in a few widgets)
  Stream<UserModel> streamUser(String uid) =>
      _users.doc(uid).snapshots().map(UserModel.fromDoc);

  Stream<PatientModel?> streamPatient(String referral) =>
      _patients.doc(referral).snapshots().map((d) =>
      d.exists ? PatientModel.fromDoc(d) : null);

/* ─────────────── DASHBOARD STREAMS ─────────────── */

  /// Assessments scheduled for **today** and still marked “waiting”.
  Stream<List<AssessmentModel>> streamTodaysPatients() {
    final start = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final end   = start.add(const Duration(days: 1));

    return _db
        .collectionGroup('assessments')
        .where('status', isEqualTo: 'waiting')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('createdAt')                       // Firestore requires an index
        .snapshots()
        .map((s) => s.docs.map(AssessmentModel.fromDoc).toList());
  }

  /// Drafts already touched by *this* practitioner but not finished.
  Stream<List<AssessmentModel>> streamPendingForms(String practitionerUid) =>
      _db
          .collectionGroup('assessments')
          .where('status', isEqualTo: 'incomplete')
          .where('practitionerUid', isEqualTo: practitionerUid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) => s.docs.map(AssessmentModel.fromDoc).toList());

  /* ─────────────── PRACTITIONER WRITE ─────────────── */

  /// Upsert practitioner analysis inside the assessment document.
  ///
  /// The patient’s demographic shell is **never** modified here.
  /// A successful call also flips `status` ⇒ `"completed"`.
  Future<void> savePractitionerAnalysis({
    required String referral,
    required String assessmentId,
    required Map<String, dynamic> analysis,      // Free-form JSON
    required String practitionerUid,
  }) async {
    final doc = _patients
        .doc(referral)
        .collection('assessments')
        .doc(assessmentId);

    await doc.set({
      'practitionerAnalysis': analysis,
      'practitionerUid'     : practitionerUid,
      'analysisUpdatedAt'   : FieldValue.serverTimestamp(),
      'status'              : 'completed',
    }, SetOptions(merge: true));
  }


  /* ─────────────── Single-assessment lookup ─────────────── */
  /// Fetch *one* assessment (regardless of patient) by its **document-id**.
  ///
  /// We use a collection-group query so you don’t need to know the patient /
  /// referral ahead of time. Returns `null` if that id is not found.
  Future<AssessmentModel?> getAssessment(
      String referral,          // ← patient-document id
      String assessmentId,      // ← assessments/<here>
      ) async {
    final doc = await _patients
        .doc(referral)
        .collection('assessments')
        .doc(assessmentId)
        .get();

    return doc.exists ? AssessmentModel.fromDoc(doc) : null;
  }

  // FirestoreService
  Future<void> updateAssessment(String referral, String id, Map<String, dynamic> data) {
    return FirebaseFirestore.instance
        .collection('patients')
        .doc(referral)
        .collection('assessments')
        .doc(id)
        .set(data, SetOptions(merge: true));
  }


}
