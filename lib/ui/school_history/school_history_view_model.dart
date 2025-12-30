import 'package:flutter/foundation.dart';
import 'package:my_ufape/data/repositories/school_history/school_history_repository.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';
import 'package:my_ufape/domain/entities/school_history.dart';
import 'package:my_ufape/domain/entities/user.dart';

class SchoolHistoryViewModel extends ChangeNotifier {
  final SchoolHistoryRepository _repository;

  final SigaBackgroundService _sigaService;

  List<SchoolHistory> _history = [];
  List<SchoolHistory> get history => _history;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String get syncStatusMessage => _sigaService.syncStatusMessage;

  SchoolHistoryViewModel(this._repository, this._sigaService) {
    _sigaService.addListener(_onSigaServiceUpdate);
  }

  void _onSigaServiceUpdate() {
    notifyListeners();
  }

  @override
  void dispose() {
    _sigaService.removeListener(_onSigaServiceUpdate);
    super.dispose();
  }

  User? currentUser;

  Future<void> loadHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getAllSchoolHistories();
    result.fold(
      (data) {
        if (data.isEmpty) {
          syncFromSiga();
        } else {
          _history = data;
          _isLoading = false;
          notifyListeners();
        }
      },
      (error) {
        _errorMessage = "Error loading history: ${error.toString()}";
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> syncFromSiga() async {
    // Verifica localmente primeiro (otimização)
    if (_isSyncing) return;

    // Verifica globalmente no serviço
    if (_sigaService.isSyncing) {
      _errorMessage =
          'Sincronização já em andamento: ${_sigaService.currentSyncOperation}';
      notifyListeners();
      return;
    }

    _isSyncing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _sigaService.navigateAndExtractSchoolHistory();
      await loadHistory();
    } on SyncInProgressException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = "Sync error: ${e.toString()}";
    } finally {
      _isSyncing = false;
      _isLoading = false;
      notifyListeners();
    }
  }
}
