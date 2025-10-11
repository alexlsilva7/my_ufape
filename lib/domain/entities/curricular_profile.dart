class CurriculumBlock {
  final String title;
  final List<SubjectProfile> subjects;

  CurriculumBlock({required this.title, required this.subjects});
}

class SubjectProfile {
  final String code;
  final String name;
  final String type;
  final String semester;
  final String workloadTheoretical;
  final String workloadPractical;
  final String workloadExtension;
  final String workloadTotal;
  final String credits;
  final List<String> prerequisites;
  final List<String> corequisites;
  final List<String> equivalences;
  final String syllabus;

  SubjectProfile({
    required this.code,
    required this.name,
    required this.type,
    required this.semester,
    required this.workloadTheoretical,
    required this.workloadPractical,
    required this.workloadExtension,
    required this.workloadTotal,
    required this.credits,
    required this.prerequisites,
    required this.corequisites,
    required this.equivalences,
    required this.syllabus,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'type': type,
      'semester': semester,
      'workloadTheoretical': workloadTheoretical,
      'workloadPractical': workloadPractical,
      'workloadExtension': workloadExtension,
      'workloadTotal': workloadTotal,
      'credits': credits,
      'prerequisites': prerequisites,
      'corequisites': corequisites,
      'equivalences': equivalences,
      'syllabus': syllabus,
    };
  }

  factory SubjectProfile.fromJson(Map<String, dynamic> json) {
    return SubjectProfile(
      code: json['code'],
      name: json['name'],
      type: json['type'],
      semester: json['semester'],
      workloadTheoretical: json['workloadTheoretical'],
      workloadPractical: json['workloadPractical'],
      workloadExtension: json['workloadExtension'],
      workloadTotal: json['workloadTotal'],
      credits: json['credits'],
      prerequisites: List<String>.from(json['prerequisites']),
      corequisites: List<String>.from(json['corequisites']),
      equivalences: List<String>.from(json['equivalences']),
      syllabus: json['syllabus'],
    );
  }

  @override
  String toString() {
    return 'SubjectProfile(code: $code, name: $name, type: $type, semester: $semester, workloadTheoretical: $workloadTheoretical, workloadPractical: $workloadPractical, workloadExtension: $workloadExtension, workloadTotal: $workloadTotal, credits: $credits, prerequisites: $prerequisites, corequisites: $corequisites, equivalences: $equivalences, syllabus: $syllabus)';
  }
}
