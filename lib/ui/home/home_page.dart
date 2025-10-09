import 'package:flutter/material.dart';
import 'package:my_ufape/data/repositories/subject_note/subject_note_repository.dart';
import 'package:routefly/routefly.dart';
import 'package:my_ufape/app_widget.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('My UFAPE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Routefly.push(routePaths.settings);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bem-vindo ao My UFAPE!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Acesse rapidamente os serviços da UFAPE',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildFeatureCard(
                    context,
                    title: 'Acessar o SIGA',
                    subtitle: 'Sistema Integrado de Gestão Acadêmica',
                    icon: Icons.school,
                    color: Colors.blue,
                    onTap: () async {
                      try {
                        // Obtém credenciais salvas
                        final settingsRepo = injector.get<SettingsRepository>();
                        final credentials =
                            await settingsRepo.getUserCredentials();

                        await credentials.fold(
                          (login) {
                            Routefly.push(routePaths.siga);
                          },
                          (login) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
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
                  ),
                  _buildFeatureCard(
                    context,
                    title: 'Notas',
                    subtitle: 'Visualizar notas e histórico',
                    icon: Icons.grade,
                    color: Colors.green,
                    onTap: () async {
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
                                        'Nenhuma nota no cache. Sincronizando com o SIGA...')),
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
                                      'Nenhuma nota em cache. Sincronizando com o SIGA...')),
                            );
                            Routefly.push(routePaths.siga);
                          },
                        );
                      }
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    title: 'Horários',
                    subtitle: 'Consultar grade horária',
                    icon: Icons.schedule,
                    color: Colors.orange,
                    onTap: () {
                      // TODO: Implementar funcionalidade de horários
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    title: 'Configurações',
                    subtitle: 'Personalizar aplicativo',
                    icon: Icons.settings,
                    color: Colors.purple,
                    onTap: () {
                      Routefly.push(routePaths.settings);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
