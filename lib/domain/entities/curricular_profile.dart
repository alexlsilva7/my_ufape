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
}
