// lib/models/block.dart

import 'course.dart';

class Block {
  final String name;
  final List<Course> courses = [];

  Block({required this.name});
}
