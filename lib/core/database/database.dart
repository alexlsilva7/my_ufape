import 'dart:developer';

import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:my_ufape/domain/entities/user.dart';
import 'package:my_ufape/domain/entities/subject.dart';
import 'package:my_ufape/domain/entities/subject_note.dart';
import 'package:my_ufape/domain/entities/block_of_profile.dart';

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
      log('Database connection already open.');
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
        ],
        directory: dir.path,
        inspector: kDebugMode,
        name: 'my_ufape_db',
      );
      log('Database connection opened successfully at ${dir.path}');
    } catch (e) {
      log('Error opening database connection: $e');
      rethrow;
    }
  }

  Future<void> seed() async {
    const seededKey = 'database_seeded_v1';
    if (prefs.getBool(seededKey) ?? false) {
      log('Database already seeded.');
      return;
    }

    log('Starting database seeding...');
    try {
      await _seedFromStructuredData();
      await prefs.setBool(seededKey, true);
      log('Database seeding completed successfully.');
    } catch (e) {
      log('Error during database seeding: $e');
    }
  }

  Future<void> resetAndSeedDatabase({
    SharedPreferences? prefs,
    bool clearSeedingFlag = false,
  }) async {
    log('Starting database reset and seed...');
    await _resetData();
    await _seedFromStructuredData();

    if (clearSeedingFlag && prefs != null) {
      const seededKey = 'database_seeded_v1';
      await prefs.remove(seededKey);
      log('Seeding flag cleared from SharedPreferences.');
    }
    log('Database reset and seed completed successfully.');
  }

  Future<void> _seedFromStructuredData() async {
    final isar = await connection;

    await isar.writeTxn(() async {
      // Aqui você pode adicionar a lógica para popular o banco de dados
    });
    log('Finished seeding data from structured source.');
  }

  Future<void> _resetData() async {
    log('Resetting database data...');
    final isar = await connection;
    await isar.writeTxn(() async {
      // Limpa todas as coleções do banco de dados
      await isar.clear();
      log('Database collections cleared successfully.');
    });
  }

  Future<void> close() async {
    if (_databaseInstance != null && _databaseInstance!.isOpen) {
      await _databaseInstance!.close();
      _databaseInstance = null;
      log('Database connection closed.');
    }
  }
}
