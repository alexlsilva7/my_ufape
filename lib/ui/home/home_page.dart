import 'package:flutter/material.dart';
import 'package:my_ufape/data/repositories/subject_note/subject_note_repository.dart';
import 'package:routefly/routefly.dart';
import 'package:my_ufape/app_widget.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String _userName = 'Estudante';

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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Olá, $_userName! 👋',
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
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined,
                                  color: Colors.white),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Nenhuma notificação no momento'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings_outlined,
                                  color: Colors.white),
                              onPressed: () {
                                Routefly.push(routePaths.settings);
                              },
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
                  _buildSectionTitle('Próximas Aulas', Icons.schedule),
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
    // Dados fictícios de próximas aulas
    final classes = [
      {
        'subject': 'Algoritmos e Programação',
        'time': '08:00 - 10:00',
        'room': 'Lab 101',
        'teacher': 'Prof. João Silva',
        'color': Colors.blue.shade600,
      },
      {
        'subject': 'Banco de Dados',
        'time': '10:00 - 12:00',
        'room': 'Sala 205',
        'teacher': 'Prof. Maria Santos',
        'color': Colors.purple.shade600,
      },
      {
        'subject': 'Engenharia de Software',
        'time': '14:00 - 16:00',
        'room': 'Sala 301',
        'teacher': 'Prof. Carlos Souza',
        'color': Colors.green.shade600,
      },
    ];

    return Column(
      children: classes.map((classInfo) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (classInfo['color'] as Color).withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
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
                  color: classInfo['color'] as Color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classInfo['subject'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          classInfo['time'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.room,
                          size: 14,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          classInfo['room'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 14,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          classInfo['teacher'] as String,
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
          final SubjectNoteRepository subjectNoteRepo =
              injector.get<SubjectNoteRepository>();
          final result = await subjectNoteRepo.getAllSubjectNotes();
          if (context.mounted) {
            result.fold(
              (periodos) {
                if (periodos.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Nenhuma nota no cache. Sincronizando com o SIGA...'),
                    ),
                  );
                  Routefly.push(routePaths.siga);
                } else {
                  Routefly.push(routePaths.grades,
                      arguments: {'periodos': periodos});
                }
              },
              (failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Nenhuma nota em cache. Sincronizando com o SIGA...'),
                  ),
                );
                Routefly.push(routePaths.siga);
              },
            );
          }
        },
      },
      {
        'title': 'Horários',
        'icon': Icons.schedule_outlined,
        'color': Colors.orange.shade600,
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Funcionalidade em desenvolvimento'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      },
      {
        'title': 'Perfil',
        'icon': Icons.person_outline,
        'color': Colors.purple.shade600,
        'onTap': () {},
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
      {
        'title': 'Ajustes',
        'icon': Icons.settings_outlined,
        'color': Colors.grey.shade600,
        'onTap': () {
          Routefly.push(routePaths.settings);
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
