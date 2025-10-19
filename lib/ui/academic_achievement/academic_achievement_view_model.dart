import 'package:flutter/foundation.dart';
import 'package:my_ufape/data/repositories/academic_achievement/academic_achievement_repository.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';
import 'package:my_ufape/domain/entities/academic_achievement.dart';

class AcademicAchievementViewModel extends ChangeNotifier {
  final AcademicAchievementRepository _repository;
  final SigaBackgroundService _sigaService;

  AcademicAchievementViewModel(this._repository, this._sigaService);

  AcademicAchievement? _achievement;
  AcademicAchievement? get achievement => _achievement;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getAcademicAchievement();
    result.fold(
      (data) {
        _achievement = data;
        _isLoading = false;
        notifyListeners();
      },
      (error) {
        _errorMessage = "Erro ao carregar dados: ${error.toString()}";
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> syncFromSiga() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _isLoading = true; // Mostra loading durante o sync
    _errorMessage = null;
    notifyListeners();

    try {
      await _sigaService.navigateAndExtractAcademicAchievement();
      // Após sincronizar, recarrega os dados do banco local
      await loadData();
    } catch (e) {
      _errorMessage = "Erro ao sincronizar: ${e.toString()}";
    } finally {
      _isSyncing = false;
      _isLoading = false;
      notifyListeners();
    }
  }
}
