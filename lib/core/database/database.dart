import 'package:isar_community/isar.dart';
import 'package:my_ufape/core/debug/logarte.dart';
import 'package:my_ufape/domain/entities/academic_achievement.dart';
import 'package:my_ufape/domain/entities/school_history.dart';
import 'package:my_ufape/domain/entities/school_history_subject.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:my_ufape/domain/entities/user.dart';
import 'package:my_ufape/domain/entities/subject.dart';
import 'package:my_ufape/domain/entities/subject_note.dart';
import 'package:my_ufape/domain/entities/block_of_profile.dart';
import 'package:my_ufape/domain/entities/time_table.dart';
import 'package:my_ufape/domain/entities/teaching_plan.dart';

class Database {
  Isar? _databaseInstance;
  final SharedPreferences prefs;

  Database({required this.prefs});

  Future<Isar> get connection async {
    if (_databaseInstance == null || !_databaseInstance!.isOpen) {
      await _openConnection();
    }
    return _databaseInstance!;
  }

  Future<void> _openConnection() async {
    if (_databaseInstance != null && _databaseInstance!.isOpen) {
      logarte.log('Database connection already open.');
      return;
    }
    try {
      final dir = await getApplicationDocumentsDirectory();
      _databaseInstance = await Isar.open(
        [
          UserSchema,
          SubjectSchema,
          SubjectNoteSchema,
          BlockOfProfileSchema,
          ScheduledSubjectSchema,
          SchoolHistorySchema,
          SchoolHistorySubjectSchema,
          AcademicAchievementSchema,
          TeachingPlanSchema,
        ],
        directory: dir.path,
        inspector: kDebugMode,
        name: 'my_ufape_db',
      );
      logarte.log('Database connection opened successfully at ${dir.path}');
    } catch (e) {
      logarte.log('Error opening database connection: $e');
      rethrow;
    }
  }

  Future<void> seed() async {
    const seededKey = 'database_seeded_v1';
    if (prefs.getBool(seededKey) ?? false) {
      logarte.database(
        target: 'Database',
        source: 'seed',
        value: 'Database already seeded. Skipping seeding process.',
      );
      return;
    }

    logarte.database(
      target: 'Database',
      source: 'seed',
      value: 'Starting database seeding process...',
    );
    try {
      await _seedFromStructuredData();
      await prefs.setBool(seededKey, true);
      logarte.database(
        target: 'Database',
        source: 'seed',
        value: 'Database seeding completed successfully.',
      );
    } catch (e) {
      logarte.log('Error during database seeding: $e');
    }
  }

  Future<void> resetAndSeedDatabase({
    SharedPreferences? prefs,
    bool clearSeedingFlag = false,
  }) async {
    logarte.log('Starting database reset and seed...');
    await _resetData();
    await _seedFromStructuredData();

    if (clearSeedingFlag && prefs != null) {
      const seededKey = 'database_seeded_v1';
      await prefs.remove(seededKey);
      logarte.database(
        target: 'Database',
        source: 'resetAndSeedDatabase',
        value: 'Seeding flag cleared in SharedPreferences.',
      );
    }
    logarte.database(
      target: 'Database',
      source: 'resetAndSeedDatabase',
      value: 'Database reset and reseeded successfully.',
    );
  }

  Future<void> _seedFromStructuredData() async {
    final isar = await connection;

    await isar.writeTxn(() async {
      // Aqui você pode adicionar a lógica para popular o banco de dados
    });
    logarte.database(
      target: 'Database',
      source: '_seedFromStructuredData',
      value: 'Database seeded with initial data.',
    );
  }

  Future<void> _resetData() async {
    logarte.log('Resetting database data...');
    final isar = await connection;
    await isar.writeTxn(() async {
      // Limpa todas as coleções do banco de dados
      await isar.clear();
      logarte.database(
        target: 'Database',
        source: '_resetData',
        value: 'All collections cleared.',
      );
    });
  }

  Future<void> close() async {
    if (_databaseInstance != null && _databaseInstance!.isOpen) {
      await _databaseInstance!.close();
      _databaseInstance = null;
      logarte.database(
        target: 'Database',
        source: 'close',
        value: 'Database connection closed.',
      );
    }
  }
}
