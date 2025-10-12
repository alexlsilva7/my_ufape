import 'package:flutter/material.dart';
import 'package:my_ufape/core/ui/gen/assets.gen.dart';
import 'package:my_ufape/data/repositories/subject_note/subject_note_repository.dart';
import 'package:my_ufape/data/repositories/scheduled_subject/scheduled_subject_repository.dart';
import 'package:routefly/routefly.dart';
import 'package:my_ufape/app_widget.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';
import 'package:my_ufape/data/services/shorebird/shorebird_service.dart';
import 'package:my_ufape/domain/entities/time_table.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String _userName = 'Estudante';

  final SigaBackgroundService _sigaService =
      injector.get<SigaBackgroundService>();
  final ShorebirdService _shorebirdService =
      injector.get<ShorebirdService>();
  final ScheduledSubjectRepository _scheduledRepo = injector.get();
  bool _isLoggedIn = false;
  late final VoidCallback _login_listener;
  late final VoidCallback _loginListener;

  List<Map<String, dynamic>> _nextClasses = [];
  bool _isLoadingNext = true;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = _sigaService.isLoggedIn;
    _loginListener = () {
      if (mounted) {
        setState(() {
          _isLoggedIn = _sigaService.loginNotifier.value;
        });
      }
    };
    _sigaService.loginNotifier.addListener(_loginListener);
    _sigaService.initialize();
    // Carregar próximas aulas ao iniciar
    _loadNextClasses();
  }

  @override
  void dispose() {
    try {
      _sigaService.loginNotifier.removeListener(_loginListener);
    } catch (_) {}
    super.dispose();
  }

  Future<void> _loadNextClasses() async {
    setState(() {
      _isLoadingNext = true;
    });

    try {
      final result = await _scheduledRepo.getAllScheduledSubjects();
      await Future.delayed(const Duration(milliseconds: 500));
      result.fold(
        (subjects) {
          if (!mounted) return;

          final now = DateTime.now();

          // Map DayOfWeek to index (segunda=1 .. domingo=7)
          int dayIndex(DayOfWeek d) {
            switch (d) {
              case DayOfWeek.segunda:
                return 1;
              case DayOfWeek.terca:
                return 2;
              case DayOfWeek.quarta:
                return 3;
              case DayOfWeek.quinta:
                return 4;
              case DayOfWeek.sexta:
                return 5;
              case DayOfWeek.sabado:
                return 6;
              case DayOfWeek.domingo:
                return 7;
              default:
                return 0;
            }
          }

          final todayIndex = now.weekday; // Monday=1 .. Sunday=7

          int parseMinutes(String hhmm) {
            try {
              final parts = hhmm.split(':');
              final h = int.tryParse(parts[0]) ?? 0;
              final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
              return h * 60 + m;
            } catch (_) {
              return 0;
            }
          }

          final nowMinutes = now.hour * 60 + now.minute;

          // Agrupar slots por disciplina + dia e mesclar horários contíguos
          final grouped = <String, List<TimeSlot>>{};
          final subjectByKey = <String, ScheduledSubject>{};

          for (final s in subjects) {
            for (final slot in s.timeSlots) {
              final key = '${s.code}_${slot.day}';
              subjectByKey[key] = s;
              grouped.putIfAbsent(key, () => []).add(slot);
            }
          }

          final intervals = <Map<String, dynamic>>[];

          for (final entry in grouped.entries) {
            final key = entry.key;
            final slots = entry.value;
            if (slots.isEmpty) continue;

            // ordenar por startTime
            slots.sort((a, b) => a.startTime.compareTo(b.startTime));

            String currentStart = slots.first.startTime;
            String currentEnd = slots.first.endTime;
            final day = slots.first.day;
            final subject = subjectByKey[key]!;

            for (var i = 1; i < slots.length; i++) {
              final s = slots[i];
              // se o próximo começa exatamente quando o atual termina, mesclar
              if (s.startTime == currentEnd) {
                currentEnd = s.endTime;
              } else {
                // finalizar intervalo atual
                final mergedSlot = TimeSlot.create(
                    day: day, startTime: currentStart, endTime: currentEnd);
                intervals.add({'subject': subject, 'slot': mergedSlot});
                // iniciar novo intervalo
                currentStart = s.startTime;
                currentEnd = s.endTime;
              }
            }

            // adicionar último intervalo
            final lastMerged = TimeSlot.create(
                day: day, startTime: currentStart, endTime: currentEnd);
            intervals.add({'subject': subject, 'slot': lastMerged});
          }

          // Para cada intervalo, calcular score de proximidade (em minutos)
          final upcoming = <Map<String, dynamic>>[];
          for (final it in intervals) {
            final slot = it['slot'] as TimeSlot;
            final sDayIndex = dayIndex(slot.day);
            if (sDayIndex == 0) continue;

            final offsetDays = (sDayIndex - todayIndex + 7) % 7;
            final startMinutes = parseMinutes(slot.startTime);

            final effectiveOffset =
                (offsetDays == 0 && startMinutes <= nowMinutes)
                    ? 7
                    : offsetDays;

            final score = effectiveOffset * 24 * 60 + startMinutes;
            upcoming
                .add({'subject': it['subject'], 'slot': slot, 'score': score});
          }

          // ordenar por score (menor = próximo)
          upcoming
              .sort((a, b) => (a['score'] as int).compareTo(b['score'] as int));

          setState(() {
            _nextClasses = upcoming
                .take(3)
                .map((e) => {'subject': e['subject'], 'slot': e['slot']})
                .toList(growable: false);
            _isLoadingNext = false;
          });
        },
        (err) {
          if (mounted) {
            setState(() {
              _nextClasses = [];
              _isLoadingNext = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _nextClasses = [];
          _isLoadingNext = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Column(
        children: [
          // Container azul que engloba AppBar e parte do menu
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        primaryColor.withValues(alpha: 0.3),
                        primaryColor.withValues(alpha: 0),
                      ]
                    : [
                        primaryColor,
                        primaryColor.withValues(alpha: 0.8),
                        primaryColor.withValues(alpha: 0.5),
                        primaryColor.withValues(alpha: 0),
                      ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // AppBar customizada
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          spacing: 8.0,
                          children: [
                            ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                              child: Assets.images.myUfapeLogo.image(
                                width: 50,
                                height: 50,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Olá, $_userName!',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Bem-vindo ao My UFAPE',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              _isLoggedIn ? Icons.wifi : Icons.wifi_off,
                              size: 14,
                              color: _isLoggedIn ? Colors.green : Colors.red,
                            ),
                            ValueListenableBuilder<bool>(
                              valueListenable:
                                  _shorebirdService.isUpdateReadyToInstall,
                              builder: (context, isReady, child) {
                                return Badge(
                                  isLabelVisible: isReady,
                                  child: child,
                                );
                              },
                              child: IconButton(
                                icon: const Icon(Icons.settings_outlined,
                                    color: Colors.white),
                                onPressed: () {
                                  Routefly.push(routePaths.settings);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildQuickAccessGrid(context, isDark),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Conteúdo abaixo (Próximas aulas)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: _buildSectionTitle(
                              'Próximas Aulas', Icons.schedule)),
                      IconButton(
                        icon: Icon(
                          Icons.refresh,
                          size: 20,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: _loadNextClasses,
                        tooltip: 'Atualizar próximas aulas',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildNextClassesSection(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Theme.of(context).primaryColor),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNextClassesSection(bool isDark) {
    if (_isLoadingNext) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0),
          child: Column(
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text('Carregando próximas aulas...'),
            ],
          ),
        ),
      );
    }

    if (_nextClasses.isEmpty) {
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Nenhuma próxima aula encontrada.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: _nextClasses.map((item) {
        final subject = item['subject'] as ScheduledSubject;
        final slot = item['slot'] as TimeSlot;
        final color = Colors.blue.shade600;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 55,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          '${slot.startTime} - ${slot.endTime}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.room, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          subject.room,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          subject.className.isNotEmpty
                              ? subject.className
                              : subject.status,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context, bool isDark) {
    final items = [
      {
        'title': 'SIGA',
        'icon': Icons.school_outlined,
        'color': Colors.blue.shade600,
        'onTap': () async {
          try {
            final settingsRepo = injector.get<SettingsRepository>();
            final credentials = await settingsRepo.getUserCredentials();

            await credentials.fold(
              (login) {
                Routefly.push(routePaths.siga);
              },
              (login) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Credenciais não encontradas. Faça login novamente.'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao acessar SIGA: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      },
      {
        'title': 'Notas',
        'icon': Icons.grade_outlined,
        'color': Colors.green.shade600,
        'onTap': () async {
          Routefly.push(routePaths.grades);
        },
      },
      {
        'title': 'Horários',
        'icon': Icons.schedule_outlined,
        'color': Colors.orange.shade600,
        'onTap': () async {
          Routefly.push(routePaths.timetable);
        },
      },
      {
        'title': 'Perfil Curricular do Curso',
        'icon': Icons.person_outline,
        'color': Colors.purple.shade600,
        'onTap': () async {
          Routefly.push(routePaths.curricularProfile);
        },
      },
      {
        'title': 'Gráficos',
        'icon': Icons.bar_chart_outlined,
        'color': Colors.teal.shade600,
        'onTap': () async {
          final SubjectNoteRepository subjectNoteRepo =
              injector.get<SubjectNoteRepository>();
          final result = await subjectNoteRepo.getAllSubjectNotes();
          if (context.mounted) {
            result.fold(
              (disciplinas) {
                if (disciplinas.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nenhum dado disponível')),
                  );
                } else {
                  // Agrupar por semestre
                  final Map<String, List> grouped = {};
                  for (final d in disciplinas) {
                    if (!grouped.containsKey(d.semestre)) {
                      grouped[d.semestre] = [];
                    }
                    grouped[d.semestre]!.add(d);
                  }
                  final periodos = grouped.entries.map((e) {
                    return {'nome': e.key, 'disciplinas': e.value};
                  }).toList();
                  Routefly.push(routePaths.charts,
                      arguments: {'periodos': periodos});
                }
              },
              (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erro ao carregar dados')),
                );
              },
            );
          }
        },
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: item['onTap'] as VoidCallback,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
