import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_ufape/data/repositories/academic_achievement/academic_achievement_repository.dart';
import 'package:my_ufape/data/repositories/scheduled_subject/scheduled_subject_repository.dart';
import 'package:my_ufape/data/repositories/subject/subject_repository.dart';
import 'package:my_ufape/data/repositories/subject_note/subject_note_repository.dart';
import 'package:my_ufape/domain/entities/academic_achievement.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportViewModel extends ChangeNotifier {
  final SubjectRepository _subjectRepo;
  final SubjectNoteRepository _subjectNoteRepo;
  final ScheduledSubjectRepository _scheduledSubjectRepo;
  final AcademicAchievementRepository _achievementRepo;

  ExportViewModel(
    this._subjectRepo,
    this._subjectNoteRepo,
    this._scheduledSubjectRepo,
    this._achievementRepo,
  );

  bool _isExporting = false;
  bool get isExporting => _isExporting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> exportDataAsJson() async {
    _isExporting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Coletando todos os dados concorrentemente para ser mais rápido
      final results = await Future.wait([
        _subjectRepo.getAllSubjects(),
        _subjectNoteRepo.getAllSubjectNotes(),
        _scheduledSubjectRepo.getAllScheduledSubjects(),
        _achievementRepo.getAcademicAchievement(),
      ]);

      final subjectsResult = results[0] as dynamic;
      final notesResult = results[1] as dynamic;
      final timetableResult = results[2] as dynamic;
      final achievementResult = results[3] as dynamic;

      // Montando a estrutura principal
      final Map<String, dynamic> exportPayload = {
        'export_date': DateTime.now().toIso8601String(),
        'subjects': subjectsResult.getOrNull()?.map((s) => {
              'code': s.code,
              'name': s.name,
              'type': s.type.toString(),
              'period': s.period,
              'credits': s.credits,
              'workload': {
                'teorica': s.workload.teorica,
                'pratica': s.workload.pratica,
                'extensao': s.workload.extensao,
                'total': s.workload.total,
              },
              'prerequisites': s.prerequisites.map((p) => {'code': p.code, 'name': p.name}).toList(),
              'corequisites': s.corequisites.map((p) => {'code': p.code, 'name': p.name}).toList(),
              'equivalences': s.equivalences.map((p) => {'code': p.code, 'name': p.name}).toList(),
              'ementa': s.ementa,
            }).toList() ??[],
        'grades': notesResult.getOrNull()?.map((n) => n.toJson()).toList() ??[],
        'timetable': timetableResult.getOrNull()?.map((t) => {
              'code': t.code,
              'name': t.name,
              'className': t.className,
              'room': t.room,
              'status': t.status,
              'timeSlots': t.timeSlots.map((ts) => {
                    'day': ts.day.toString(),
                    'startTime': ts.startTime,
                    'endTime': ts.endTime,
                  }).toList(),
            }).toList() ??[],
        'academic_achievement': _mapAchievement(achievementResult.getOrNull()),
      };

      // Convertendo para String JSON formatada
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportPayload);

      // Salvando em arquivo temporário
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/meus_dados_ufape.json');
      await file.writeAsString(jsonString);

      // Compartilhando o arquivo
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Backup dos dados acadêmicos - My UFAPE',
        ),
      );

    } catch (e) {
      _errorMessage = 'Erro ao exportar os dados: $e';
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  Map<String, dynamic>? _mapAchievement(AcademicAchievement? achievement) {
    if (achievement == null) return null;

    Map<String, dynamic> mapWorkloadItem(WorkloadSummaryItem item) {
      return {
        'category': item.category,
        'name': item.name,
        'integration': item.integration,
        'completedHours': item.completedHours,
        'completedPercentage': item.completedPercentage,
        'waivedHours': item.waivedHours,
        'toCompleteHours': item.toCompleteHours,
        'children': item.children.map((c) => mapWorkloadItem(c)).toList(),
      };
    }

    return {
      'totalPendingHours': achievement.totalPendingHours,
      'pendingSubjects': achievement.pendingSubjects.map((ps) => {
            'code': ps.code,
            'name': ps.name,
            'workload': ps.workload,
            'period': ps.period,
            'credits': ps.credits,
          }).toList(),
      'componentSummary': achievement.componentSummary.map((cs) => {
            'description': cs.description,
            'hours': cs.hours,
            'quantity': cs.quantity,
          }).toList(),
      'workloadSummary': achievement.workloadSummary.map((ws) => mapWorkloadItem(ws)).toList(),
    };
  }
}
