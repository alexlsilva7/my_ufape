import 'package:my_ufape/ui/home/widgets/connectivity_status_widget.dart';
import 'package:my_ufape/ui/home/widgets/upcoming_classes_widget.dart';
import 'package:flutter/material.dart';
import 'package:my_ufape/core/debug/logarte.dart';
import 'package:my_ufape/core/ui/gen/assets.gen.dart';
import 'package:my_ufape/data/repositories/subject_note/subject_note_repository.dart';
import 'package:routefly/routefly.dart';
import 'package:my_ufape/app_widget.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';
import 'package:my_ufape/data/services/shorebird/shorebird_service.dart';
import 'package:terminate_restart/terminate_restart.dart';
import 'package:my_ufape/ui/home/home_view_model.dart';
import 'package:my_ufape/ui/home/widgets/user_info_dialog.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeViewModel _viewModel = injector.get<HomeViewModel>();

  final SigaBackgroundService _sigaService =
      injector.get<SigaBackgroundService>();
  final ShorebirdService _shorebirdService = injector.get<ShorebirdService>();
  bool _isLoggedIn = false;
  late final VoidCallback _loginListener;

  String? version;

  @override
  void initState() {
    super.initState();

    _viewModel.loadUser();
    _viewModel.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _isLoggedIn = _sigaService.isLoggedIn;
    _loginListener = () {
      logarte.log('LOGIN STATUS CHANGED: ${_sigaService.loginNotifier.value}');

      if (mounted) {
        setState(() {
          _isLoggedIn = _sigaService.loginNotifier.value;
        });
      }

      if (_isLoggedIn) {
        //_sigaService.performAutomaticSyncIfNeeded();
      }
    };
    _sigaService.loginNotifier.addListener(_loginListener);
    _sigaService.captchaRequiredNotifier.addListener(_handleCaptchaRequirement);
    _sigaService.initialize();

    // Shorebird update listener
    _shorebirdService.isUpdateReadyToInstall.addListener(_showUpdateBanner);
    // Check on init
    WidgetsBinding.instance.addPostFrameCallback((_) => _showUpdateBanner());
    Future.delayed(const Duration(seconds: 10), () {
      _showUpdateBanner();
    });

    version = _shorebirdService.appVersion;
  }

  bool isNewApkAvailable = false;
  String newVersionApkUrl = '';

  @override
  void dispose() {
    try {
      _viewModel.removeListener(() {});
      _sigaService.loginNotifier.removeListener(_loginListener);
      _sigaService.captchaRequiredNotifier
          .removeListener(_handleCaptchaRequirement);
      _shorebirdService.isUpdateReadyToInstall
          .removeListener(_showUpdateBanner);
    } catch (_) {}
    super.dispose();
  }

  /// Redireciona para a tela do SIGA quando CAPTCHA é detectado
  void _handleCaptchaRequirement() {
    if (_sigaService.captchaRequiredNotifier.value && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Atenção: Resolva o 'Não sou um robô' para continuar a sincronização."),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 6),
        ),
      );
      // Navega para a tela do SIGA onde a WebView interativa vive
      Routefly.push(routePaths.siga);
    }
  }

  bool get _isUpdateAvailable => _shorebirdService.isUpdateReadyToInstall.value;
  bool updateAfter = false;

  void _showUpdateBanner() {
    if (!_isUpdateAvailable || !mounted || updateAfter) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        animation: CurvedAnimation(
          parent: AnimationController(
            duration: const Duration(milliseconds: 300),
            vsync: ScaffoldMessenger.of(context),
          )..forward(),
          curve: Curves.easeInOut,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.system_update,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nova atualização disponível',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reinicie o app para obter as últimas melhorias',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: isDark
            ? Colors.black
            : Theme.of(context)
                .colorScheme
                .primaryContainer
                .withValues(alpha: 0.3),
        dividerColor: Colors.transparent,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              updateAfter = true;
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Depois'),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: () async {
              await TerminateRestart.instance.restartApp(
                options: const TerminateRestartOptions(terminate: true),
              );
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reiniciar'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
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
                mainAxisSize: MainAxisSize.min,
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
                                GestureDetector(
                                  onTap: () {
                                    if (_viewModel.user != null) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => UserInfoDialog(
                                          user: _viewModel.user!,
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    'Olá, ${_viewModel.userName}!',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                ListenableBuilder(
                                  listenable: _sigaService,
                                  builder: (context, _) {
                                    if (_sigaService.isSyncing) {
                                      return Row(
                                        children: [
                                          SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white.withValues(
                                                          alpha: 0.9)),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Sincronizando dados...',
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.9),
                                              fontSize: 14,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                    return Text(
                                      'Bem-vindo ao My UFAPE',
                                      style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                        fontSize: 14,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const ConnectivityStatusWidget(),
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
                  if (isNewApkAvailable && newVersionApkUrl.isNotEmpty)
                    GestureDetector(
                      onTap: () async {
                        if (await canLaunchUrlString(newVersionApkUrl)) {
                          await launchUrlString(newVersionApkUrl,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.6),
                              Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Nova Atualização, clique para baixar',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.download),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildQuickAccessGrid(context, isDark),
                  ),
                  const SizedBox(height: 8),
                  //adicionar mais 2 opções Perfil curricular e Hístórico acadêmico parecido ao menu rápido
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Routefly.push(routePaths.curricularProfile);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 56,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.black : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: isDark ? 0.3 : 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Perfil Curricular',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Routefly.push(routePaths.schoolHistory);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 56,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.black : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: isDark ? 0.3 : 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Histórico',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  const UpcomingClassesWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
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
              (login) async {
                await _sigaService.goToHome();
                // 4) Entra na página do SIGA
                await Routefly.push(routePaths.siga);
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
            // ignore: use_build_context_synchronously
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
      // {
      //   'title': 'Perfil Curricular',
      //   'icon': Icons.person_outline,
      //   'color': Colors.purple.shade600,
      //   'onTap': () async {
      //     Routefly.push(routePaths.curricularProfile);
      //   },
      // },
      {
        'title': 'Disciplinas',
        'icon': Icons.view_list_outlined,
        'color': Colors.red.shade600,
        'onTap': () async {
          Routefly.push(routePaths.subjects.path);
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
      {
        'title': 'Rendimento',
        'icon': Icons.school_rounded,
        'color': Colors.indigo.shade600,
        'onTap': () async {
          Routefly.push(routePaths.academicAchievement);
        },
      },
      // {
      //   'title': 'Histórico',
      //   'icon': Icons.history_edu_outlined,
      //   'color': Colors.indigo.shade600,
      //   'onTap': () {
      //     Routefly.push(routePaths.schoolHistory);
      //   },
      // },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.15,
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
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
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
                    color: (item['color'] as Color).withValues(alpha: 0.15),
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
