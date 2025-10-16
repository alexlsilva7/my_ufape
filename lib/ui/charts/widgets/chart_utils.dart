import 'package:flutter/material.dart';

Color getColorForGradeRange(String range) {
  switch (range) {
    case '0-2':
      return Colors.red.shade700;
    case '2-4':
      return Colors.orange.shade700;
    case '4-6':
      return Colors.amber.shade700;
    case '6-8':
      return Colors.lightGreen.shade600;
    case '8-10':
      return Colors.green.shade700;
    default:
      return Colors.grey;
  }
}
