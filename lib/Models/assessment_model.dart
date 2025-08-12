// lib/Models/assessment_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/* ═════════════════════════════════  Practitioner side models  ═════════════════════════════════ */

class PostureChoice {
  final bool checked;     // checkbox state (e.g., "Normal" selected)
  final String severity;  // '', 'Mild', 'Moderate', 'Severe'

  const PostureChoice({this.checked = false, this.severity = ''});

  factory PostureChoice.fromMap(Map<String, dynamic>? m) =>
      PostureChoice(
        checked : (m?['checked'] ?? false) as bool,
        severity: (m?['severity'] ?? '') as String,
      );

  Map<String, dynamic> toJson() => {
    'checked' : checked,
    'severity': severity,
  };

  PostureChoice copyWith({bool? checked, String? severity}) =>
      PostureChoice(
        checked : checked  ?? this.checked,
        severity: severity ?? this.severity,
      );
}

class PostureSection {
  // Spine: normal/leanForward/leanBackward
  // Pelvis: normal/tilt/twist/protract/retract
  // Shoulder: normal/leanLeft/leanRight/protract
  // Gait: normal/limp/cane/wheelchair
  final Map<String, PostureChoice> items; // key => PostureChoice
  final String other; // free text

  const PostureSection({this.items = const {}, this.other = ''});

  factory PostureSection.fromMap(Map<String, dynamic>? m) {
    final raw = (m?['items'] ?? {}) as Map<String, dynamic>;
    return PostureSection(
      items: raw.map((k, v) => MapEntry(k, PostureChoice.fromMap(v as Map<String, dynamic>?))),
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
  /// One of: '', 'Full Range', 'Slight Restriction', 'Moderate Restriction', 'Severe Restriction'
  final String restriction;

  const RangeOfMotion({this.area = '', this.restriction = ''});

  factory RangeOfMotion.fromMap(Map<String, dynamic>? m) => RangeOfMotion(
    area       : (m?['area'] ?? '') as String,
    restriction: (m?['restriction'] ?? '') as String,
  );

  Map<String, dynamic> toJson() => {
    'area'       : area,
    'restriction': restriction,
  };

  RangeOfMotion copyWith({String? area, String? restriction}) =>
      RangeOfMotion(
        area       : area ?? this.area,
        restriction: restriction ?? this.restriction,
      );
}

class PalpationEntry {
  final String area;
  final String tension;     // '', 'Mild', 'Moderate', 'Severe'
  final String texture;     // '', 'Pliable', 'Adhesive', 'Fibrotic'
  final String tenderness;  // '', 'Mild', 'Moderate', 'Severe'
  final String temperature; // '', 'Normal', 'Increased', 'Decreased'

  const PalpationEntry({
    this.area = '',
    this.tension = '',
    this.texture = '',
    this.tenderness = '',
    this.temperature = '',
  });

  factory PalpationEntry.fromMap(Map<String, dynamic>? m) => PalpationEntry(
    area       : (m?['area'] ?? '') as String,
    tension    : (m?['tension'] ?? '') as String,
    texture    : (m?['texture'] ?? '') as String,
    tenderness : (m?['tenderness'] ?? '') as String,
    temperature: (m?['temperature'] ?? '') as String,
  );

  Map<String, dynamic> toJson() => {
    'area'       : area,
    'tension'    : tension,
    'texture'    : texture,
    'tenderness' : tenderness,
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
        area       : area ?? this.area,
        tension    : tension ?? this.tension,
        texture    : texture ?? this.texture,
        tenderness : tenderness ?? this.tenderness,
        temperature: temperature ?? this.temperature,
      );
}

class PractitionerObjective {
  /// Posture groups
  final PostureSection spine;
  final PostureSection pelvis;
  final PostureSection shoulder;
  final PostureSection gait;
  /// ROM
  final RangeOfMotion rom;
  /// Palpation – list allows 1..N areas
  final List<PalpationEntry> palpation;

  const PractitionerObjective({
    this.spine = const PostureSection(),
    this.pelvis = const PostureSection(),
    this.shoulder = const PostureSection(),
    this.gait = const PostureSection(),
    this.rom = const RangeOfMotion(),
    this.palpation = const [],
  });

  factory PractitionerObjective.fromMap(Map<String, dynamic>? m) => PractitionerObjective(
    spine   : PostureSection.fromMap(m?['spine'] as Map<String, dynamic>?),
    pelvis  : PostureSection.fromMap(m?['pelvis'] as Map<String, dynamic>?),
    shoulder: PostureSection.fromMap(m?['shoulder'] as Map<String, dynamic>?),
    gait    : PostureSection.fromMap(m?['gait'] as Map<String, dynamic>?),
    rom     : RangeOfMotion.fromMap(m?['rom'] as Map<String, dynamic>?),
    palpation: (m?['palpation'] as List?)
        ?.map((e) => PalpationEntry.fromMap(e as Map<String, dynamic>?))
        .toList() ??
        const [],
  );

  Map<String, dynamic> toJson() => {
    'spine'   : spine.toJson(),
    'pelvis'  : pelvis.toJson(),
    'shoulder': shoulder.toJson(),
    'gait'    : gait.toJson(),
    'rom'     : rom.toJson(),
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
        spine    : spine ?? this.spine,
        pelvis   : pelvis ?? this.pelvis,
        shoulder : shoulder ?? this.shoulder,
        gait     : gait ?? this.gait,
        rom      : rom ?? this.rom,
        palpation: palpation ?? this.palpation,
      );
}

/* ═════════════════════════════════  Practitioner Plan (Assessment / Plan page)  ═════════ */

class PractitionerPlan {
  /// Treatment Information
  /// Checkbox lists stored as strings for portability/back-compat.
  final List<String> areasTreated;   // e.g., ['Back','Neck','Shoulders',...]
  final String areasOther;           // free text "Other"
  final List<String> techniquesUsed; // e.g., ['All','Swedish',...]
  final String techniquesOther;      // free text "Other"

  /// Assessment Information
  final int painAfterSession;        // 0..10
  final String clientResponse;       // long text ("AI Narrated" hint)

  /// Plan Information
  final List<int> followUpWith;      // minutes: [15,30,45,60]
  final List<String> sessionEvery;   // ['Week','Two Weeks','Month']
  final String recommendations;      // large text (self-care & plan)

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
    areasTreated   : List<String>.from(m?['areasTreated'] ?? const []),
    areasOther     : (m?['areasOther'] ?? '') as String,
    techniquesUsed : List<String>.from(m?['techniquesUsed'] ?? const []),
    techniquesOther: (m?['techniquesOther'] ?? '') as String,
    painAfterSession: (m?['painAfterSession'] ?? 0) is int
        ? (m?['painAfterSession'] as int)
        : int.tryParse('${m?['painAfterSession'] ?? 0}') ?? 0,
    clientResponse : (m?['clientResponse'] ?? '') as String,
    followUpWith   : (m?['followUpWith'] as List?)
        ?.map((e) => e is int ? e : int.tryParse('$e') ?? 0)
        .toList() ??
        const [],
    sessionEvery   : List<String>.from(m?['sessionEvery'] ?? const []),
    recommendations: (m?['recommendations'] ?? '') as String,
  );

  Map<String, dynamic> toJson() => {
    'areasTreated'    : areasTreated,
    'areasOther'      : areasOther,
    'techniquesUsed'  : techniquesUsed,
    'techniquesOther' : techniquesOther,
    'painAfterSession': painAfterSession,
    'clientResponse'  : clientResponse,
    'followUpWith'    : followUpWith,
    'sessionEvery'    : sessionEvery,
    'recommendations' : recommendations,
  };

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
  }) =>
      PractitionerPlan(
        areasTreated   : areasTreated ?? this.areasTreated,
        areasOther     : areasOther ?? this.areasOther,
        techniquesUsed : techniquesUsed ?? this.techniquesUsed,
        techniquesOther: techniquesOther ?? this.techniquesOther,
        painAfterSession: painAfterSession ?? this.painAfterSession,
        clientResponse : clientResponse ?? this.clientResponse,
        followUpWith   : followUpWith ?? this.followUpWith,
        sessionEvery   : sessionEvery ?? this.sessionEvery,
        recommendations: recommendations ?? this.recommendations,
      );
}

/* ═════════════════════════════════  Practitioner Remarks (Remarks page)  ═════════ */

class PractitionerRemarks {
  /// Additional Information
  final bool na;
  final bool initialAppointment;
  final bool finalAppointment;

  /// Practitioner Note (small + large)
  final String noteShort;
  final String noteLong;

  /// Muscle selections per section, e.g. {'Neck': ['SCM','Levator Scapulae']}
  final Map<String, List<String>> musclesBySection;

  /// Legacy single notes field (kept for back-compat; we also map it into noteLong when loading)
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
    final mapped = raw.map((k, v) =>
        MapEntry(k, List<String>.from(v as List? ?? const [])));

    // Backward compatibility: if only `notes` existed previously, use it as noteLong
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
    // Keep writing legacy key for older data readers (safe duplicate)
    'notes': notes.isNotEmpty ? notes : noteLong,
  };

  PractitionerRemarks copyWith({
    bool? na,
    bool? initialAppointment,
    bool? finalAppointment,
    String? noteShort,
    String? noteLong,
    Map<String, List<String>>? musclesBySection,
    String? notes,
  }) =>
      PractitionerRemarks(
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
  // META
  final String   id;
  final DateTime createdAt;
  final DateTime updatedAt;

  // PAGE-1 – Personal
  final String   firstName;
  final String   lastName;
  final DateTime dob;
  final String   referral;
  final String   chiefComplaint;

  // PAGE-2 – Subjective
  final String        painSince;
  final String        progression; // Better | Worse | Same
  final int           currentPain; // /10
  final int           atBest;      // /10
  final int           atWorst;     // /10
  final List<String>  timePattern;
  final List<String>  incidents;
  final List<String>  prevents;
  final List<String>  practitioners;
  final String        worseFactor;
  final String        betterFactor;
  final String        additional;

  // PAGE-3 – Sensation / Map
  final List<String>  sensations;
  final List<String>  bodyPoints;

  // PRACTITIONER – Objective / Plan / Remarks
  final PractitionerObjective? practitionerObjective;
  final PractitionerPlan?      practitionerPlan;
  final PractitionerRemarks?   practitionerRemarks;

  const AssessmentModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    // page-1
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.referral,
    required this.chiefComplaint,
    // page-2
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
    // page-3
    required this.sensations,
    required this.bodyPoints,
    // practitioner
    this.practitionerObjective,
    this.practitionerPlan,
    this.practitionerRemarks,
  });

  factory AssessmentModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;

    DateTime _tsToDate(dynamic v) =>
        v is Timestamp ? v.toDate() : DateTime.fromMillisecondsSinceEpoch(0);

    return AssessmentModel(
      id            : doc.id,
      createdAt     : _tsToDate(d['createdAt']),
      updatedAt     : _tsToDate(d['updatedAt']),
      // page-1
      firstName     : d['firstName']        ?? '',
      lastName      : d['lastName']         ?? '',
      dob           : _tsToDate(d['dob']),
      referral      : d['referral']         ?? '',
      chiefComplaint: d['chiefComplaint']   ?? '',
      // page-2
      painSince     : d['painSince']        ?? '',
      progression   : d['progression']      ?? '',
      currentPain   : d['currentPain']      ?? 0,
      atBest        : d['atBest']           ?? 0,
      atWorst       : d['atWorst']          ?? 0,
      timePattern   : List<String>.from(d['timePattern']   ?? const []),
      incidents     : List<String>.from(d['incidents']     ?? const []),
      prevents      : List<String>.from(d['prevents']      ?? const []),
      practitioners : List<String>.from(d['practitioners'] ?? const []),
      worseFactor   : d['worseFactor']      ?? '',
      betterFactor  : d['betterFactor']     ?? '',
      additional    : d['additional']       ?? '',
      // page-3
      sensations    : List<String>.from(d['sensations']    ?? const []),
      bodyPoints    : List<String>.from(d['bodyPoints']    ?? const []),
      // practitioner (nullable & backward compatible)
      practitionerObjective: d['practitionerObjective'] != null
          ? PractitionerObjective.fromMap(d['practitionerObjective'] as Map<String, dynamic>)
          : null,
      practitionerPlan: d['practitionerPlan'] != null
          ? PractitionerPlan.fromMap(d['practitionerPlan'] as Map<String, dynamic>)
          : null,
      practitionerRemarks: d['practitionerRemarks'] != null
          ? PractitionerRemarks.fromMap(d['practitionerRemarks'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    // meta
    'createdAt'     : Timestamp.fromDate(createdAt),
    'updatedAt'     : Timestamp.fromDate(updatedAt),
    // page-1
    'firstName'     : firstName,
    'lastName'      : lastName,
    'dob'           : Timestamp.fromDate(dob),
    'referral'      : referral,
    'chiefComplaint': chiefComplaint,
    // page-2
    'painSince'     : painSince,
    'progression'   : progression,
    'currentPain'   : currentPain,
    'atBest'        : atBest,
    'atWorst'       : atWorst,
    'timePattern'   : timePattern,
    'incidents'     : incidents,
    'prevents'      : prevents,
    'practitioners' : practitioners,
    'worseFactor'   : worseFactor,
    'betterFactor'  : betterFactor,
    'additional'    : additional,
    // page-3
    'sensations'    : sensations,
    'bodyPoints'    : bodyPoints,
    // practitioner
    if (practitionerObjective != null)
      'practitionerObjective': practitionerObjective!.toJson(),
    if (practitionerPlan != null)
      'practitionerPlan': practitionerPlan!.toJson(),
    if (practitionerRemarks != null)
      'practitionerRemarks': practitionerRemarks!.toJson(),
  };

  AssessmentModel copyWith({
    DateTime? updatedAt,
    // page-3
    List<String>? sensations,
    List<String>? bodyPoints,
    // practitioner
    PractitionerObjective? practitionerObjective,
    PractitionerPlan? practitionerPlan,
    PractitionerRemarks? practitionerRemarks,
  }) =>
      AssessmentModel(
        id            : id,
        createdAt     : createdAt,
        updatedAt     : updatedAt ?? this.updatedAt,
        // page-1
        firstName     : firstName,
        lastName      : lastName,
        dob           : dob,
        referral      : referral,
        chiefComplaint: chiefComplaint,
        // page-2
        painSince     : painSince,
        progression   : progression,
        currentPain   : currentPain,
        atBest        : atBest,
        atWorst       : atWorst,
        timePattern   : timePattern,
        incidents     : incidents,
        prevents      : prevents,
        practitioners : practitioners,
        worseFactor   : worseFactor,
        betterFactor  : betterFactor,
        additional    : additional,
        // page-3
        sensations    : sensations ?? this.sensations,
        bodyPoints    : bodyPoints ?? this.bodyPoints,
        // practitioner
        practitionerObjective: practitionerObjective ?? this.practitionerObjective,
        practitionerPlan     : practitionerPlan      ?? this.practitionerPlan,
        practitionerRemarks  : practitionerRemarks   ?? this.practitionerRemarks,
      );
}
