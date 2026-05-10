import 'dart:convert';

import 'package:home_widget/home_widget.dart';
import 'package:routefly/routefly.dart';
import 'package:my_ufape/data/services/upcoming_classes/upcoming_classes_service.dart';
import 'package:my_ufape/domain/entities/upcoming_class_data.dart';

/// Serviço para comunicação entre Flutter e Home Screen Widget nativo.
///
/// Salva dados das próximas aulas no SharedPreferences compartilhado
/// para que o widget nativo possa ler e exibir.
class HomeWidgetService {
  final UpcomingClassesService _upcomingClassesService;

  /// Nome do widget Android (apenas o nome da classe, não o pacote completo)
  /// Conforme documentação do home_widget
  static const String _androidWidgetName = 'UpcomingClassesWidgetProvider';

  /// Chave para armazenar os dados das aulas
  static const String _upcomingClassesKey = 'upcoming_classes_data';

  /// Armazena a URI pendente para tratamento posterior (ex: na Splash)
  static Uri? pendingDeepLink;

  HomeWidgetService(this._upcomingClassesService);

  /// Inicializa o serviço de Home Widget.
  ///
  /// Deve ser chamado na inicialização do app para registrar
  /// o group ID do Android (se necessário).
  static Future<void> initialize() async {
    // Definir o App Group ID para Android (opcional, mas recomendado)
    // No Android, isso define o nome do SharedPreferences
    await HomeWidget.setAppGroupId('group.com.alexlopes.myufape');
  }

  /// Atualiza o Home Screen Widget com as próximas aulas.
  ///
  /// Busca as próximas aulas, serializa em JSON e salva
  /// no SharedPreferences compartilhado para o widget nativo ler.
  Future<void> updateWidget() async {
    try {
      // Buscar próximas aulas
      final result = await _upcomingClassesService.getUpcomingClasses(limit: 3);

      await result.fold(
        (classes) async => await _saveClassesToWidget(classes),
        (_) async => await _saveClassesToWidget([]),
      );

      // Disparar atualização do widget nativo
      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
      );
    } catch (e) {
      // Em caso de erro, salvar lista vazia e tentar atualizar mesmo assim
      await _saveClassesToWidget([]);
      try {
        await HomeWidget.updateWidget(
          androidName: _androidWidgetName,
        );
      } catch (_) {
        // Ignora erro silenciosamente
      }
    }
  }

  /// Salva a lista de aulas no SharedPreferences compartilhado.
  Future<void> _saveClassesToWidget(List<UpcomingClassData> classes) async {
    final jsonList = classes.map((c) => c.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    await HomeWidget.saveWidgetData<String>(
      _upcomingClassesKey,
      jsonString,
    );
  }

  /// Verifica se o app foi aberto via clique no widget.
  ///
  /// Retorna a URI do intent quando o usuário clica no widget.
  static Future<Uri?> getInitialUri() async {
    return await HomeWidget.initiallyLaunchedFromHomeWidget();
  }

  /// Registra listener para cliques no widget quando o app está aberto.
  static void registerClickListener(void Function(Uri? uri) callback) {
    HomeWidget.widgetClicked.listen(callback);
  }

  /// Processa a URI recebida do widget.
  ///
  /// Retorna true se a URI foi tratada, false caso contrário.
  static Future<bool> handleWidgetUri(Uri? uri) async {
    if (uri == null) return false;

    // Verifica se é uma URI do widget e se a ação é abrir a grade de horários
    if (uri.toString().contains('/timetable')) {
      await Routefly.navigate('/timetable');
      return true;
    }

    return false;
  }
}
