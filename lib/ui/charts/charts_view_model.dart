import 'dart:math' as math;
import 'package:my_ufape/domain/entities/subject_note.dart';

class ChartsViewModel {
  Map<String, dynamic> analytics = {};
  List<Map<String, dynamic>> periodMedias = [];
  List<Map<String, dynamic>> subjectPerformance = [];
  Map<String, int> gradeDistribution = {};
  Map<String, dynamic>? performanceTrend;
  Map<String, dynamic>? consistency;
  Map<String, dynamic>? progression;

  void computeAll(List<Map<String, dynamic>> periodosData) {
    analytics = _computeAnalytics(periodosData);
    periodMedias = _computePeriodAverages(periodosData);
    subjectPerformance = _computeSubjectPerformance(periodosData);
    gradeDistribution = _computeGradeDistribution(periodosData);
    performanceTrend = _computePerformanceTrend(periodMedias);
    consistency = _computeConsistency(periodosData);
    progression = _computeProgression(periodMedias);
  }

  Map<String, dynamic> _computeAnalytics(
      List<Map<String, dynamic>> periodosData) {
    final allDisciplinas = periodosData
        .expand((p) => (p['disciplinas'] as List<dynamic>).cast<SubjectNote>())
        .toList();
    final totalDisciplinas = allDisciplinas.length;
    final totalAprovadas = allDisciplinas
        .where((d) => d.situacao.toUpperCase().contains('APROVADO'))
        .length;
    final totalReprovadas = allDisciplinas
        .where((d) => d.situacao.toUpperCase().contains('REPROVADO'))
        .length;
    final totalCursando = totalDisciplinas - totalAprovadas - totalReprovadas;
    final totalConcluidas = totalAprovadas + totalReprovadas;
    final approvalRate =
        totalConcluidas > 0 ? (totalAprovadas / totalConcluidas) * 100 : 0.0;

    return {
      'totalDisciplinas': totalDisciplinas,
      'totalAprovadas': totalAprovadas,
      'totalReprovadas': totalReprovadas,
      'totalCursando': totalCursando,
      'totalPeriodos': periodosData.length,
      'approvalRate': approvalRate,
      'overallAverage': _computeOverallAverage(periodosData),
    };
  }

  List<Map<String, dynamic>> _computePeriodAverages(
      List<Map<String, dynamic>> periodosData) {
    final periodMedias = <Map<String, dynamic>>[];

    for (final periodoData in periodosData) {
      final disciplinas =
          (periodoData['disciplinas'] as List<dynamic>).cast<SubjectNote>();
      final medias = <double>[];

      for (final disciplina in disciplinas) {
        for (final entry in disciplina.notas.entries) {
          if (_isMediaKey(entry.key)) {
            final value = double.tryParse(entry.value.replaceAll(',', '.'));
            if (value != null) medias.add(value);
          }
        }
      }

      if (medias.isNotEmpty) {
        final mediaPeriodo = medias.reduce((a, b) => a + b) / medias.length;
        periodMedias.add({
          'periodo': periodoData['nome'] as String,
          'media': mediaPeriodo,
        });
      }
    }

    periodMedias.sort(
        (a, b) => (a['periodo'] as String).compareTo(b['periodo'] as String));

    return periodMedias;
  }

  List<Map<String, dynamic>> _computeSubjectPerformance(
      List<Map<String, dynamic>> periodosData) {
    final subjectData = <String, Map<String, dynamic>>{};

    for (final periodoData in periodosData) {
      final disciplinas =
          (periodoData['disciplinas'] as List<dynamic>).cast<SubjectNote>();
      for (final disciplina in disciplinas) {
        for (final entry in disciplina.notas.entries) {
          if (_isMediaKey(entry.key)) {
            final value = double.tryParse(entry.value.replaceAll(',', '.'));
            if (value != null) {
              if (!subjectData.containsKey(disciplina.nome)) {
                subjectData[disciplina.nome] = {
                  'grades': <double>[],
                  'periodo': periodoData['nome'] as String,
                  'professor': disciplina.teacher,
                };
              }
              subjectData[disciplina.nome]!['grades'].add(value);
            }
          }
        }
      }
    }

    final performance = subjectData.entries.map((entry) {
      final grades = entry.value['grades'] as List<double>;
      final avg = grades.reduce((a, b) => a + b) / grades.length;
      return {
        'nome': entry.key,
        'media': avg,
        'periodo': entry.value['periodo'],
        'professor': entry.value['professor'],
      };
    }).toList();

    performance
        .sort((a, b) => (b['media'] as double).compareTo(a['media'] as double));

    return performance;
  }

  Map<String, int> _computeGradeDistribution(
      List<Map<String, dynamic>> periodosData) {
    final distribution = <String, int>{
      '0-2': 0,
      '2-4': 0,
      '4-6': 0,
      '6-8': 0,
      '8-10': 0,
    };

    for (final periodoData in periodosData) {
      final disciplinas =
          (periodoData['disciplinas'] as List<dynamic>).cast<SubjectNote>();
      for (final disciplina in disciplinas) {
        for (final entry in disciplina.notas.entries) {
          if (_isMediaKey(entry.key)) {
            final value = double.tryParse(entry.value.replaceAll(',', '.'));
            if (value != null) {
              if (value < 2) {
                distribution['0-2'] = distribution['0-2']! + 1;
              } else if (value < 4) {
                distribution['2-4'] = distribution['2-4']! + 1;
              } else if (value < 6) {
                distribution['4-6'] = distribution['4-6']! + 1;
              } else if (value < 8) {
                distribution['6-8'] = distribution['6-8']! + 1;
              } else {
                distribution['8-10'] = distribution['8-10']! + 1;
              }
            }
          }
        }
      }
    }

    return distribution;
  }

  Map<String, dynamic>? _computePerformanceTrend(
      List<Map<String, dynamic>> periodMedias) {
    if (periodMedias.length < 2) return null;

    final lastPeriod = periodMedias.last['media'] as double;
    final previousPeriod =
        periodMedias[periodMedias.length - 2]['media'] as double;
    final change = lastPeriod - previousPeriod;

    return {
      'isImproving': change > 0,
      'change': change,
    };
  }

  Map<String, dynamic>? _computeConsistency(
      List<Map<String, dynamic>> periodosData) {
    final allMedias = <double>[];

    for (final periodoData in periodosData) {
      final disciplinas =
          (periodoData['disciplinas'] as List<dynamic>).cast<SubjectNote>();
      for (final disciplina in disciplinas) {
        for (final entry in disciplina.notas.entries) {
          if (_isMediaKey(entry.key)) {
            final value = double.tryParse(entry.value.replaceAll(',', '.'));
            if (value != null) allMedias.add(value);
          }
        }
      }
    }

    if (allMedias.length < 2) return null;

    final mean = allMedias.reduce((a, b) => a + b) / allMedias.length;
    final variance =
        allMedias.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) /
            allMedias.length;
    final stdDev = math.sqrt(variance);

    return {
      'stdDev': stdDev,
      'isConsistent': stdDev < 1.5,
    };
  }

  Map<String, dynamic>? _computeProgression(
      List<Map<String, dynamic>> periodMedias) {
    if (periodMedias.length < 2) return null;

    final first = periodMedias.first['media'] as double;
    final last = periodMedias.last['media'] as double;
    final change = last - first;
    final percentage = first > 0 ? (change / first) * 100 : 0.0;

    return {
      'change': change,
      'percentage': percentage,
    };
  }

  double _computeOverallAverage(List<Map<String, dynamic>> periodosData) {
    final allMedias = <double>[];

    for (final periodoData in periodosData) {
      final disciplinas =
          (periodoData['disciplinas'] as List<dynamic>).cast<SubjectNote>();
      for (final disciplina in disciplinas) {
        final situacao = (disciplina.situacao).toUpperCase();
        if (!situacao.contains('APROVADO') && !situacao.contains('REPROVADO')) {
          continue;
        }
        for (final entry in disciplina.notas.entries) {
          if (_isMediaKey(entry.key)) {
            final value = double.tryParse(entry.value.replaceAll(',', '.'));
            if (value != null) allMedias.add(value);
          }
        }
      }
    }

    if (allMedias.isEmpty) return 0.0;
    return allMedias.reduce((a, b) => a + b) / allMedias.length;
  }

  bool _isMediaKey(String key) {
    final k = key.toLowerCase();
    return k.contains('média') || k.contains('media') || k.contains('mf');
  }
}
