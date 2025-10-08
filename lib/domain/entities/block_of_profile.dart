// lib/models/block.dart

import 'subject.dart';

class BlockOfProfile {
  final String name;
  final List<Subject> subjects = [];

  BlockOfProfile({required this.name});
}
