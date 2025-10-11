import 'package:isar_community/isar.dart';
import 'subject.dart';

part 'block_of_profile.g.dart';

@collection
class BlockOfProfile {
  Id id = Isar.autoIncrement;

  @Index(unique: true, caseSensitive: false)
  String name;

  // Relacionamento 1:N com Subject
  final subjects = IsarLinks<Subject>();

  @ignore
  List<Subject> subjectList = [];

  BlockOfProfile({required this.name});

  @override
  String toString() =>
      'BlockOfProfile(name: $name, subjects: ${subjects.length})';
}
