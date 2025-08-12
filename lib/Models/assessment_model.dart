// lib/Models/assessment_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/* ═════════════════════════════════  Practitioner side models  ═════════════════════════════════ */

class PostureChoice {
  final bool checked;
  final String severity;

  const PostureChoice({this.checked = false, this.severity = ''});

  factory PostureChoice.fromMap(Map<String, dynamic>? m) => PostureChoice(
    checked: (m?['checked'] ?? false) as bool,
    severity: (m?['severity'] ?? '') as String,
  );

  Map<String, dynamic> toJson() => {
    'checked': checked,
    'severity': severity,
  };

  PostureChoice copyWith({bool? checked, String? severity}) => PostureChoice(
    checked: checked ?? this.checked,
    severity: severity ?? this.severity,
  );
}

class PostureSection {
  final Map<String, PostureChoice> items;
  final String other;

  const PostureSection({this.items = const {}, this.other = ''});

  factory PostureSection.fromMap(Map<String, dynamic>? m) {
    final raw = (m?['items'] ?? {}) as Map<String, dynamic>;
    return PostureSection(
      items: raw.map((k, v) =>
          MapEntry(k, PostureChoice.fromMap(v as Map<String, dynamic>?))),
      other: (m?['other'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((k, v) => MapEntry(k, v.toJson())),
    'other': other,
  };

  PostureSection copyWith({Map<String, PostureChoice>? items, String? other}) =>
      PostureSection(
        items: items ?? this.items,
        other: other ?? this.other,
      );
}

class RangeOfMotion {
  final String area;
  final String restriction;

  const RangeOfMotion({this.area = '', this.restriction = ''});

  factory RangeOfMotion.fromMap(Map<String, dynamic>? m) => RangeOfMotion(
    area: (m?['area'] ?? '') as String,
    restriction: (m?['restriction'] ?? '') as String,
  );

  Map<String, dynamic> toJson() => {
    'area': area,
    'restriction': restriction,
  };

  RangeOfMotion copyWith({String? area, String? restriction}) => RangeOfMotion(
    area: area ?? this.area,
    restriction: restriction ?? this.restriction,
  );
}

class PalpationEntry {
  final String area;
  final String tension;
  final String texture;
  final String tenderness;
  final String temperature;

  const PalpationEntry({
    this.area = '',
    this.tension = '',
    this.texture = '',
    this.tenderness = '',
    this.temperature = '',
  });

  factory PalpationEntry.fromMap(Map<String, dynamic>? m) => PalpationEntry(
    area: (m?['area'] ?? '') as String,
    tension: (m?['tension'] ?? '') as String,
    texture: (m?['texture'] ?? '') as String,
    tenderness: (m?['tenderness'] ?? '') as String,
    temperature: (m?['temperature'] ?? '') as String,
  );

  Map<String, dynamic> toJson() => {
    'area': area,
    'tension': tension,
    'texture': texture,
    'tenderness': tenderness,
    'temperature': temperature,
  };

  PalpationEntry copyWith({
    String? area,
    String? tension,
    String? texture,
    String? tenderness,
    String? temperature,
  }) =>
      PalpationEntry(
        area: area ?? this.area,
        tension: tension ?? this.tension,
        texture: texture ?? this.texture,
        tenderness: tenderness ?? this.tenderness,
        temperature: temperature ?? this.temperature,
      );
}

class PractitionerObjective {
  final PostureSection spine;
  final PostureSection pelvis;
  final PostureSection shoulder;
  final PostureSection gait;
  final RangeOfMotion rom;
  final List<PalpationEntry> palpation;

  const PractitionerObjective({
    this.spine = const PostureSection(),
    this.pelvis = const PostureSection(),
    this.shoulder = const PostureSection(),
    this.gait = const PostureSection(),
    this.rom = const RangeOfMotion(),
    this.palpation = const [],
  });

  factory PractitionerObjective.fromMap(Map<String, dynamic>? m) =>
      PractitionerObjective(
        spine: PostureSection.fromMap(m?['spine'] as Map<String, dynamic>?),
        pelvis: PostureSection.fromMap(m?['pelvis'] as Map<String, dynamic>?),
        shoulder: PostureSection.fromMap(m?['shoulder'] as Map<String, dynamic>?),
        gait: PostureSection.fromMap(m?['gait'] as Map<String, dynamic>?),
        rom: RangeOfMotion.fromMap(m?['rom'] as Map<String, dynamic>?),
        palpation: (m?['palpation'] as List?)
            ?.map((e) => PalpationEntry.fromMap(e as Map<String, dynamic>?))
            .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
    'spine': spine.toJson(),
    'pelvis': pelvis.toJson(),
    'shoulder': shoulder.toJson(),
    'gait': gait.toJson(),
    'rom': rom.toJson(),
    'palpation': palpation.map((e) => e.toJson()).toList(),
  };

  PractitionerObjective copyWith({
    PostureSection? spine,
    PostureSection? pelvis,
    PostureSection? shoulder,
    PostureSection? gait,
    RangeOfMotion? rom,
    List<PalpationEntry>? palpation,
  }) =>
      PractitionerObjective(
        spine: spine ?? this.spine,
        pelvis: pelvis ?? this.pelvis,
        shoulder: shoulder ?? this.shoulder,
        gait: gait ?? this.gait,
        rom: rom ?? this.rom,
        palpation: palpation ?? this.palpation,
      );
}

class PractitionerPlan {
  final List<String> areasTreated;
  final String areasOther;
  final List<String> techniquesUsed;
  final String techniquesOther;
  final int painAfterSession;
  final String clientResponse;
  final List<int> followUpWith;
  final List<String> sessionEvery;
  final String recommendations;

  const PractitionerPlan({
    this.areasTreated = const [],
    this.areasOther = '',
    this.techniquesUsed = const [],
    this.techniquesOther = '',
    this.painAfterSession = 0,
    this.clientResponse = '',
    this.followUpWith = const [],
    this.sessionEvery = const [],
    this.recommendations = '',
  });

  factory PractitionerPlan.fromMap(Map<String, dynamic>? m) => PractitionerPlan(
    areasTreated: List<String>.from(m?['areasTreated'] ?? const []),
    areasOther: (m?['areasOther'] ?? '') as String,
    techniquesUsed: List<String>.from(m?['techniquesUsed'] ?? const []),
    techniquesOther: (m?['techniquesOther'] ?? '') as String,
    painAfterSession: _asInt(m?['painAfterSession']),
    clientResponse: (m?['clientResponse'] ?? '') as String,
    followUpWith: (m?['followUpWith'] as List?)
        ?.map((e) => _asInt(e))
        .toList() ??
        const [],
    sessionEvery: List<String>.from(m?['sessionEvery'] ?? const []),
    recommendations: (m?['recommendations'] ?? '') as String,
  );

  Map<String, dynamic> toJson() => {
    'areasTreated': areasTreated,
    'areasOther': areasOther,
    'techniquesUsed': techniquesUsed,
    'techniquesOther': techniquesOther,
    'painAfterSession': painAfterSession,
    'clientResponse': clientResponse,
    'followUpWith': followUpWith,
    'sessionEvery': sessionEvery,
    'recommendations': recommendations,
  };

  // 🔧 Added
  PractitionerPlan copyWith({
    List<String>? areasTreated,
    String? areasOther,
    List<String>? techniquesUsed,
    String? techniquesOther,
    int? painAfterSession,
    String? clientResponse,
    List<int>? followUpWith,
    List<String>? sessionEvery,
    String? recommendations,
  }) => PractitionerPlan(
    areasTreated: areasTreated ?? this.areasTreated,
    areasOther: areasOther ?? this.areasOther,
    techniquesUsed: techniquesUsed ?? this.techniquesUsed,
    techniquesOther: techniquesOther ?? this.techniquesOther,
    painAfterSession: painAfterSession ?? this.painAfterSession,
    clientResponse: clientResponse ?? this.clientResponse,
    followUpWith: followUpWith ?? this.followUpWith,
    sessionEvery: sessionEvery ?? this.sessionEvery,
    recommendations: recommendations ?? this.recommendations,
  );
}

class PractitionerRemarks {
  final bool na;
  final bool initialAppointment;
  final bool finalAppointment;
  final String noteShort;
  final String noteLong;
  final Map<String, List<String>> musclesBySection;
  final String notes;

  const PractitionerRemarks({
    this.na = false,
    this.initialAppointment = false,
    this.finalAppointment = false,
    this.noteShort = '',
    this.noteLong = '',
    this.musclesBySection = const {},
    this.notes = '',
  });

  factory PractitionerRemarks.fromMap(Map<String, dynamic>? m) {
    final raw = (m?['musclesBySection'] ?? {}) as Map<String, dynamic>;
    final mapped =
    raw.map((k, v) => MapEntry(k, List<String>.from(v as List? ?? const [])));
    final legacyNotes = (m?['notes'] ?? '') as String;
    return PractitionerRemarks(
      na: (m?['na'] ?? false) as bool,
      initialAppointment: (m?['initialAppointment'] ?? false) as bool,
      finalAppointment: (m?['finalAppointment'] ?? false) as bool,
      noteShort: (m?['noteShort'] ?? '') as String,
      noteLong: (m?['noteLong'] ?? legacyNotes) as String,
      musclesBySection: mapped,
      notes: legacyNotes,
    );
  }

  Map<String, dynamic> toJson() => {
    'na': na,
    'initialAppointment': initialAppointment,
    'finalAppointment': finalAppointment,
    'noteShort': noteShort,
    'noteLong': noteLong,
    'musclesBySection':
    musclesBySection.map((k, v) => MapEntry(k, v.toList())),
    'notes': notes.isNotEmpty ? notes : noteLong,
  };

  // 🔧 Added
  PractitionerRemarks copyWith({
    bool? na,
    bool? initialAppointment,
    bool? finalAppointment,
    String? noteShort,
    String? noteLong,
    Map<String, List<String>>? musclesBySection,
    String? notes,
  }) => PractitionerRemarks(
    na: na ?? this.na,
    initialAppointment: initialAppointment ?? this.initialAppointment,
    finalAppointment: finalAppointment ?? this.finalAppointment,
    noteShort: noteShort ?? this.noteShort,
    noteLong: noteLong ?? this.noteLong,
    musclesBySection: musclesBySection ?? this.musclesBySection,
    notes: notes ?? this.notes,
  );
}

/* ═════════════════════════════════  Main AssessmentModel  ═════════════════════════════════ */

class AssessmentModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;
  final String practitionerUid;
  final DateTime? analysisUpdatedAt;
  final DateTime? completedAt;
  final Map<String, bool> downloadedBy;
  final String firstName;
  final String lastName;
  final DateTime dob;
  final String referral;
  final String chiefComplaint;
  final String painSince;
  final String progression;
  final int currentPain;
  final int atBest;
  final int atWorst;
  final List<String> timePattern;
  final List<String> incidents;
  final List<String> prevents;
  final List<String> practitioners;
  final String worseFactor;
  final String betterFactor;
  final String additional;
  final List<String> sensations;
  final List<String> bodyPoints;
  final PractitionerObjective? practitionerObjective;
  final PractitionerPlan? practitionerPlan;
  final PractitionerRemarks? practitionerRemarks;

  const AssessmentModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.status = '',
    this.practitionerUid = '',
    this.analysisUpdatedAt,
    this.completedAt,
    this.downloadedBy = const {},
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.referral,
    required this.chiefComplaint,
    required this.painSince,
    required this.progression,
    required this.currentPain,
    required this.atBest,
    required this.atWorst,
    required this.timePattern,
    required this.incidents,
    required this.prevents,
    required this.practitioners,
    required this.worseFactor,
    required this.betterFactor,
    required this.additional,
    required this.sensations,
    required this.bodyPoints,
    this.practitionerObjective,
    this.practitionerPlan,
    this.practitionerRemarks,
  });

  static DateTime _tsToDate(dynamic v) =>
      v is Timestamp ? v.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
  static DateTime? _tsToDateNullable(dynamic v) =>
      v is Timestamp ? v.toDate() : null;
  static List<String> _asStringList(dynamic v) =>
      v is List ? v.map((e) => '$e').toList() : const [];

  factory AssessmentModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;
    return AssessmentModel(
      id: doc.id,
      createdAt: _tsToDate(d['createdAt']),
      updatedAt: _tsToDate(d['updatedAt']),
      status: (d['status'] ?? '') as String,
      practitionerUid: (d['practitionerUid'] ?? '') as String,
      analysisUpdatedAt: _tsToDateNullable(d['analysisUpdatedAt']),
      completedAt: _tsToDateNullable(d['completedAt']),
      downloadedBy: (d['downloadedBy'] as Map<String, dynamic>? ?? const {})
          .map((k, v) => MapEntry(k, v == true)),
      firstName: d['firstName'] ?? '',
      lastName: d['lastName'] ?? '',
      dob: _tsToDate(d['dob']),
      referral: d['referral'] ?? '',
      chiefComplaint: d['chiefComplaint'] ?? '',
      painSince: d['painSince'] ?? '',
      progression: d['progression'] ?? '',
      currentPain: _asInt(d['currentPain']),
      atBest: _asInt(d['atBest']),
      atWorst: _asInt(d['atWorst']),
      timePattern: _asStringList(d['timePattern']),
      incidents: _asStringList(d['incidents']),
      prevents: _asStringList(d['prevents']),
      practitioners: _asStringList(d['practitioners']),
      worseFactor: d['worseFactor'] ?? '',
      betterFactor: d['betterFactor'] ?? '',
      additional: d['additional'] ?? '',
      sensations: _asStringList(d['sensations']),
      bodyPoints: _asStringList(d['bodyPoints']),
      practitionerObjective: d['practitionerObjective'] != null
          ? PractitionerObjective.fromMap(
          d['practitionerObjective'] as Map<String, dynamic>)
          : null,
      practitionerPlan: d['practitionerPlan'] != null
          ? PractitionerPlan.fromMap(
          d['practitionerPlan'] as Map<String, dynamic>)
          : null,
      practitionerRemarks: d['practitionerRemarks'] != null
          ? PractitionerRemarks.fromMap(
          d['practitionerRemarks'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'status': status,
    'practitionerUid': practitionerUid,
    if (analysisUpdatedAt != null)
      'analysisUpdatedAt': Timestamp.fromDate(analysisUpdatedAt!),
    if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
    'downloadedBy': downloadedBy,
    'firstName': firstName,
    'lastName': lastName,
    'dob': Timestamp.fromDate(dob),
    'referral': referral,
    'chiefComplaint': chiefComplaint,
    'painSince': painSince,
    'progression': progression,
    'currentPain': currentPain,
    'atBest': atBest,
    'atWorst': atWorst,
    'timePattern': timePattern,
    'incidents': incidents,
    'prevents': prevents,
    'practitioners': practitioners,
    'worseFactor': worseFactor,
    'betterFactor': betterFactor,
    'additional': additional,
    'sensations': sensations,
    'bodyPoints': bodyPoints,
    if (practitionerObjective != null)
      'practitionerObjective': practitionerObjective!.toJson(),
    if (practitionerPlan != null)
      'practitionerPlan': practitionerPlan!.toJson(),
    if (practitionerRemarks != null)
      'practitionerRemarks': practitionerRemarks!.toJson(),
  };

  AssessmentModel copyWith({
    DateTime? updatedAt,
    DateTime? completedAt,
    Map<String, bool>? downloadedBy,
    String? status,
    String? practitionerUid,
    DateTime? analysisUpdatedAt,
    List<String>? sensations,
    List<String>? bodyPoints,
    PractitionerObjective? practitionerObjective,
    PractitionerPlan? practitionerPlan,
    PractitionerRemarks? practitionerRemarks,
  }) =>
      AssessmentModel(
        id: id,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        completedAt: completedAt ?? this.completedAt,
        downloadedBy: downloadedBy ?? this.downloadedBy,
        status: status ?? this.status,
        practitionerUid: practitionerUid ?? this.practitionerUid,
        analysisUpdatedAt: analysisUpdatedAt ?? this.analysisUpdatedAt,
        firstName: firstName,
        lastName: lastName,
        dob: dob,
        referral: referral,
        chiefComplaint: chiefComplaint,
        painSince: painSince,
        progression: progression,
        currentPain: currentPain,
        atBest: atBest,
        atWorst: atWorst,
        timePattern: timePattern,
        incidents: incidents,
        prevents: prevents,
        practitioners: practitioners,
        worseFactor: worseFactor,
        betterFactor: betterFactor,
        additional: additional,
        sensations: sensations ?? this.sensations,
        bodyPoints: bodyPoints ?? this.bodyPoints,
        practitionerObjective:
        practitionerObjective ?? this.practitionerObjective,
        practitionerPlan: practitionerPlan ?? this.practitionerPlan,
        practitionerRemarks: practitionerRemarks ?? this.practitionerRemarks,
      );

  bool get isCompleted => status == 'completed';
  bool get isIncomplete => status == 'incomplete';
  bool get isWaiting => status.isEmpty || status == 'waiting';

  String get defaultPdfName {
    final fn = firstName.isEmpty ? 'Patient' : firstName;
    final ln = lastName.isEmpty ? '' : ' ${lastName[0]}.';
    final d = (completedAt ?? analysisUpdatedAt ?? createdAt);
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final yy = (d.year % 100).toString().padLeft(2, '0');
    return '$fn$ln\_$mm-$dd-$yy\_SOAPNote.pdf';
  }
}

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is num) return v.toInt();
  return int.tryParse('$v') ?? 0;
}
