// lib/Services/firestore_service.dart
// Practitioner-side Firestore service
//
// ──────────────────────────────────────────────────────────────
// ❶  New capabilities
//     • streamWaitingPatients() – real-time list of “waiting” patients
//     • streamIncompleteAssessments() – real-time drafts per patient
//     • savePractitionerAnalysis() – upsert practitioner’s note/plan
// ❷  Completed assessments helpers + per-practitioner download flag
//     • streamPatientCompletedAssessments(referral, practitionerUid)
//     • markAssessmentDownloaded(referral, assessmentId, practitionerUid)
// ❸  Filter enums for your CustomFilterAlert (public, not underscored)
//     • QuickRange  • SortOption
// ──────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/patient_model.dart';
import '../Models/assessment_model.dart';
import '../Models/practitioner_model.dart';
import '../Models/user_model.dart';

/// Public enums so other files can import them.
enum QuickRange { today, last7, all }
enum SortOption { nameAsc, lastVisitDesc }

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // Top-level collections
  CollectionReference get _users         => _db.collection('users');
  CollectionReference get _patients      => _db.collection('patients');
  CollectionReference get _practitioners => _db.collection('practitioners');

  /* ─────────────── USERS / PRACTITIONERS ─────────────── */

  Future<void> savePractitionerProfile(PractitionerModel p) =>
      _practitioners.doc(p.uid).set(p.toJson(), SetOptions(merge: true));

  Stream<PractitionerModel> streamPractitioner(String uid) =>
      _practitioners.doc(uid).snapshots().map(PractitionerModel.fromDoc);

  Future<void> saveUser(UserModel u) =>
      _users.doc(u.uid).set(u.toJson(), SetOptions(merge: true));

  /// Optional: real-time user stream (also used in a few widgets)
  Stream<UserModel> streamUser(String uid) =>
      _users.doc(uid).snapshots().map(UserModel.fromDoc);

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

  /* ─────────────── PATIENT READ ─────────────── */

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

  Stream<PatientModel?> streamPatient(String referral) =>
      _patients.doc(referral).snapshots().map(
            (d) => d.exists ? PatientModel.fromDoc(d) : null,
      );

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
        .orderBy('createdAt')
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

  /// Upsert practitioner analysis inside the assessment document and mark completed.
  Future<void> savePractitionerAnalysis({
    required String referral,
    required String assessmentId,
    required Map<String, dynamic> analysis,      // Free-form JSON (objective/plan/remarks, etc.)
    required String practitionerUid,
  }) async {
    final doc = _patients.doc(referral).collection('assessments').doc(assessmentId);

    await doc.set({
      'practitionerAnalysis': analysis,
      'practitionerUid'     : practitionerUid,
      'analysisUpdatedAt'   : FieldValue.serverTimestamp(),
      'completedAt'         : FieldValue.serverTimestamp(),
      'status'              : 'completed',
      'updatedAt'           : FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Generic partial update helper (optionally mark as touched by practitioner).
  Future<void> updateAssessment(
      String referral,
      String id,
      Map<String, dynamic> data, {
        bool markTouchedByPractitioner = false,
        String? practitionerUid,
      }) async {
    final doc = _patients.doc(referral).collection('assessments').doc(id);

    final patch = <String, dynamic>{
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (markTouchedByPractitioner) {
      patch['status'] = 'incomplete';
      if (practitionerUid != null) {
        patch['practitionerUid'] = practitionerUid;
      }
    }

    await doc.set(patch, SetOptions(merge: true));
  }

  /// Flip an assessment to completed (used by finish buttons).
  Future<void> completeAssessment(
      String referral,
      String id, {
        required String practitionerUid,
      }) async {
    final doc = _patients.doc(referral).collection('assessments').doc(id);
    await doc.set({
      'status'            : 'completed',
      'practitionerUid'   : practitionerUid,                 // used by Users page filter
      'analysisUpdatedAt' : FieldValue.serverTimestamp(),    // for ordering
      'completedAt'       : FieldValue.serverTimestamp(),
      'updatedAt'         : FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /* ─────────────── COMPLETED LISTS / DOWNLOAD FLAGS ─────────────── */

  /// Completed assessments across all patients (optionally only for one practitioner).
  Stream<List<AssessmentModel>> streamCompletedAssessments({String? practitionerUid}) {
    Query q = _db
        .collectionGroup('assessments')
        .where('status', isEqualTo: 'completed')
        .orderBy('completedAt', descending: true);

    if (practitionerUid != null && practitionerUid.isNotEmpty) {
      q = q.where('practitionerUid', isEqualTo: practitionerUid);
    }
    return q.snapshots().map((s) => s.docs.map(AssessmentModel.fromDoc).toList());
  }

  /// Completed assessments **for a single patient** (optionally filtered to one practitioner).
  ///
  /// Used by `CustomDownloadAlert`.
  Stream<List<AssessmentModel>> streamPatientCompletedAssessments({
    required String referral,
    String? practitionerUid,
  }) {
    Query q = _patients
        .doc(referral)
        .collection('assessments')
        .where('status', isEqualTo: 'completed')
        .orderBy('completedAt', descending: true);

    if (practitionerUid != null && practitionerUid.isNotEmpty) {
      q = q.where('practitionerUid', isEqualTo: practitionerUid);
    }
    return q.snapshots().map((s) => s.docs.map(AssessmentModel.fromDoc).toList());
  }

  /// Mark a completed assessment as "downloaded" by this practitioner.
  ///
  /// Writes: `downloadedBy.<uid> = true` and bumps `updatedAt` (doesn't overwrite the whole map).
  Future<void> markAssessmentDownloaded({
    required String referral,
    required String assessmentId,
    required String practitionerUid,
  }) async {
    final doc = _patients.doc(referral).collection('assessments').doc(assessmentId);
    await doc.set({
      'downloadedBy.$practitionerUid': true,
      'updatedAt'                    : FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /* ─────────────── Single-assessment lookup ─────────────── */

  /// Fetch *one* assessment by patient and id.
  Future<AssessmentModel?> getAssessment(
      String referral,     // patients/<referral>
      String assessmentId, // assessments/<id>
      ) async {
    final doc = await _patients
        .doc(referral)
        .collection('assessments')
        .doc(assessmentId)
        .get();

    return doc.exists ? AssessmentModel.fromDoc(doc) : null;
  }

  /* ─────────────── (Optional) FILTERED COMPLETED STREAM ─────────────── */

  /// If you want the service to apply your quick-range + sort:
  Stream<List<AssessmentModel>> streamCompletedAssessmentsFiltered({
    String? practitionerUid,
    QuickRange range = QuickRange.all,
    SortOption sort = SortOption.lastVisitDesc,
  }) {
    final bounds = _rangeBounds(range);
    Query q = _db.collectionGroup('assessments')
        .where('status', isEqualTo: 'completed');

    if (bounds != null) {
      q = q
          .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(bounds.$1))
          .where('completedAt', isLessThan: Timestamp.fromDate(bounds.$2));
    }

    // Primary Firestore ordering
    q = q.orderBy('completedAt', descending: true);

    if (practitionerUid != null && practitionerUid.isNotEmpty) {
      q = q.where('practitionerUid', isEqualTo: practitionerUid);
    }

    return q.snapshots().map((s) {
      final list = s.docs.map(AssessmentModel.fromDoc).toList();
      if (sort == SortOption.nameAsc) {
        list.sort((a, b) {
          final al = a.lastName.toLowerCase();
          final bl = b.lastName.toLowerCase();
          final cmp = al.compareTo(bl);
          if (cmp != 0) return cmp;
          return a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase());
        });
      }
      return list;
    });
  }

  /* ─────────────── Helpers ─────────────── */

  /// Returns (start, end) for the given quick range in local time, or null for "all".
  (DateTime, DateTime)? _rangeBounds(QuickRange r) {
    final now = DateTime.now();
    switch (r) {
      case QuickRange.today:
        final start = DateTime(now.year, now.month, now.day);
        final end   = start.add(const Duration(days: 1));
        return (start, end);
      case QuickRange.last7:
        final end   = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
        final start = end.subtract(const Duration(days: 7));
        return (start, end);
      case QuickRange.all:
        return null;
    }
  }
}
