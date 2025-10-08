import 'package:flutter/material.dart';
import 'package:my_ufape/domain/entities/semester.dart';
import 'package:my_ufape/domain/entities/login.dart';
import 'package:result_dart/result_dart.dart';

abstract interface class SettingsRepository extends ChangeNotifier {
  AsyncResult<Unit> toggleDarkMode();
  AsyncResult<Unit> restoreApp();
  bool isDarkMode = false;

  AsyncResult<Unit> saveUserCredentials(Login login);

  AsyncResult<Login> getUserCredentials();

  AsyncResult<Unit> deleteUserCredentials();

  AsyncResult<Unit> saveGrades(List<Semester> periodos);
  AsyncResult<List<Semester>> getCachedGrades();
}
