# Solução para Problema de Concorrência no SigaBackgroundService

## Problema Identificado

O [`SigaBackgroundService`](lib/data/services/siga/siga_background_service.dart:26) usa um único `WebViewController` compartilhado. Quando múltiplas sincronizações tentam executar simultaneamente, elas competem pelo mesmo controller, causando:

1. **Conflitos de navegação**: Uma sincronização pode mudar a página enquanto outra está extraindo dados
2. **Dados corrompidos**: Scripts podem executar na página errada
3. **Timeouts**: Verificações de página pronta podem falhar
4. **Estado inconsistente**: `isSyncing` pode não refletir o estado real

### Cenários Problemáticos

1. **Sincronização automática** ([`performAutomaticSyncIfNeeded()`](lib/data/services/siga/siga_background_service.dart:85)) + **Sincronização manual** ([`syncFromSiga()`](lib/ui/school_history/school_history_view_model.dart:66))
2. **Múltiplas telas** tentando sincronizar simultaneamente
3. **Sincronização em background** enquanto usuário navega manualmente

## Análise do Código Atual

### Flag `isSyncing`
```dart
bool _isSyncing = false;
bool get isSyncing => _isSyncing;
```

- Existe mas **não é verificada** antes de iniciar sincronizações
- [`navigateAndExtractSchoolHistory()`](lib/data/services/siga/siga_background_service.dart:889) não verifica se já está sincronizando
- [`syncFromSiga()`](lib/ui/school_history/school_history_view_model.dart:66) verifica localmente mas não globalmente

### Métodos de Sincronização

1. **[`_runSync()`](lib/data/services/siga/siga_background_service.dart:121)** - Sincronização completa (notas + horário + histórico)
2. **[`navigateAndExtractSchoolHistory()`](lib/data/services/siga/siga_background_service.dart:889)** - Apenas histórico
3. **[`navigateAndExtractGrades()`](lib/data/services/siga/siga_background_service.dart:485)** - Apenas notas
4. **[`navigateAndExtractTimetable()`](lib/data/services/siga/siga_background_service.dart:730)** - Apenas horário

Todos usam o mesmo `_controller` sem coordenação.

## Soluções Propostas

### Solução 1: Sistema de Lock Simples (Recomendada)

Adicionar verificação e bloqueio antes de qualquer operação de sincronização.

**Vantagens:**
- Simples de implementar
- Baixo overhead
- Fácil de entender e manter

**Desvantagens:**
- Sincronizações são rejeitadas se já houver uma em andamento
- Usuário precisa tentar novamente

**Implementação:**

```dart
class SigaBackgroundService extends ChangeNotifier {
  // ... código existente ...
  
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;
  
  // Método auxiliar para verificar e adquirir lock
  bool _acquireSyncLock() {
    if (_isSyncing) {
      logarte.log('Sync already in progress, rejecting new sync request');
      return false;
    }
    _isSyncing = true;
    notifyListeners();
    return true;
  }
  
  // Método auxiliar para liberar lock
  void _releaseSyncLock() {
    _isSyncing = false;
    _syncStatusMessage = '';
    notifyListeners();
  }
  
  // Atualizar todos os métodos de sincronização
  Future<void> navigateAndExtractSchoolHistory() async {
    if (!_acquireSyncLock()) {
      throw Exception('Sincronização já em andamento. Aguarde a conclusão.');
    }
    
    try {
      // ... código de sincronização existente ...
    } finally {
      _releaseSyncLock();
    }
  }
  
  // Aplicar o mesmo padrão para:
  // - navigateAndExtractGrades()
  // - navigateAndExtractTimetable()
  // - navigateAndExtractProfile()
  // - navigateAndExtractUser()
  // - navigateAndExtractAcademicAchievement()
}
```

### Solução 2: Fila de Sincronização (Mais Complexa)

Enfileirar requisições de sincronização e executá-las sequencialmente.

**Vantagens:**
- Nenhuma requisição é perdida
- Execução automática quando possível
- Melhor UX (usuário não precisa tentar novamente)

**Desvantagens:**
- Mais complexo de implementar
- Pode causar atrasos longos se muitas requisições
- Precisa gerenciar cancelamento de requisições antigas

**Implementação:**

```dart
class SigaBackgroundService extends ChangeNotifier {
  // ... código existente ...
  
  final List<Future<void> Function()> _syncQueue = [];
  bool _isProcessingQueue = false;
  
  Future<void> _enqueueSyncOperation(Future<void> Function() operation) async {
    final completer = Completer<void>();
    
    _syncQueue.add(() async {
      try {
        await operation();
        completer.complete();
      } catch (e) {
        completer.completeError(e);
      }
    });
    
    _processQueue();
    return completer.future;
  }
  
  Future<void> _processQueue() async {
    if (_isProcessingQueue || _syncQueue.isEmpty) return;
    
    _isProcessingQueue = true;
    _isSyncing = true;
    notifyListeners();
    
    while (_syncQueue.isNotEmpty) {
      final operation = _syncQueue.removeAt(0);
      try {
        await operation();
      } catch (e) {
        logarte.log('Queue operation failed: $e');
      }
    }
    
    _isProcessingQueue = false;
    _isSyncing = false;
    _syncStatusMessage = '';
    notifyListeners();
  }
  
  Future<void> navigateAndExtractSchoolHistory() async {
    return _enqueueSyncOperation(() async {
      // ... código de sincronização existente ...
    });
  }
}
```

### Solução 3: Múltiplos Controllers (Não Recomendada)

Criar um controller separado para cada tipo de sincronização.

**Vantagens:**
- Sincronizações podem executar em paralelo (teoricamente)

**Desvantagens:**
- Múltiplas sessões SIGA (pode ser bloqueado pelo servidor)
- Maior consumo de memória
- Complexidade de gerenciar múltiplos controllers
- Pode violar termos de uso do SIGA

## Solução Recomendada: Lock Simples com Feedback

Combinar Solução 1 com melhor feedback ao usuário.

### Implementação Detalhada

```dart
class SigaBackgroundService extends ChangeNotifier {
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;
  
  String _syncStatusMessage = '';
  String get syncStatusMessage => _syncStatusMessage;
  
  String? _currentSyncOperation;
  String? get currentSyncOperation => _currentSyncOperation;
  
  /// Tenta adquirir o lock de sincronização
  /// Retorna true se conseguiu, false se já está sincronizando
  bool _acquireSyncLock(String operationName) {
    if (_isSyncing) {
      logarte.log(
        'Sync lock denied: $_currentSyncOperation already in progress',
        source: 'SigaBackgroundService'
      );
      return false;
    }
    
    _isSyncing = true;
    _currentSyncOperation = operationName;
    _syncStatusMessage = 'Iniciando $operationName...';
    notifyListeners();
    logarte.log('Sync lock acquired for: $operationName');
    return true;
  }
  
  /// Libera o lock de sincronização
  void _releaseSyncLock() {
    final operation = _currentSyncOperation;
    _isSyncing = false;
    _currentSyncOperation = null;
    _syncStatusMessage = '';
    notifyListeners();
    logarte.log('Sync lock released for: $operation');
  }
  
  /// Atualiza status da sincronização
  void _updateSyncStatus(String message) {
    _syncStatusMessage = message;
    notifyListeners();
  }
  
  // Exemplo de aplicação no método de histórico escolar
  Future<void> navigateAndExtractSchoolHistory() async {
    if (!_acquireSyncLock('Histórico Escolar')) {
      throw SyncInProgressException(
        'Sincronização de $_currentSyncOperation já em andamento. '
        'Aguarde a conclusão ou tente novamente em alguns instantes.'
      );
    }
    
    try {
      if (_controller == null) {
        throw Exception('Controller not initialized');
      }
      
      logarte.log('Starting school history extraction from SIGA...');
      
      _updateSyncStatus('Navegando para o menu...');
      await _controller!.runJavaScript(SigaScripts.scriptNav());
      
      _updateSyncStatus('Acessando informações do discente...');
      await _controller!.runJavaScriptReturningResult(SigaScripts.scriptInfo());
      await _waitForStudentInfoPageReady();
      
      _updateSyncStatus('Abrindo histórico escolar...');
      await _controller!.runJavaScriptReturningResult(
        SigaScripts.scriptHistoricoEscolar()
      );
      await _waitForSchoolHistoryPageReady();
      await Future.delayed(const Duration(milliseconds: 500));
      
      _updateSyncStatus('Extraindo dados do histórico...');
      final jsonResult = await _controller!.runJavaScriptReturningResult(
        SigaScripts.extractSchoolHistoryScript()
      );
      
      // ... resto do código de processamento ...
      
      _updateSyncStatus('Salvando histórico no banco de dados...');
      await _schoolHistoryRepository.upsertFromSiga(decodedData);
      
      _updateSyncStatus('Atualizando dados do usuário...');
      final userResult = await _userRepository.getUser();
      userResult.fold((user) async {
        user.overallAverage = (decodedData['overallAverage'] as num?)?.toDouble();
        user.overallCoefficient = (decodedData['overallCoefficient'] as num?)?.toDouble();
        await _userRepository.upsertUser(user);
      }, (error) => null);
      
      _updateSyncStatus('Sincronização concluída!');
      logarte.log('School history extraction successful.');
      
      await goToHome();
      
    } catch (e) {
      logarte.log('Failed to navigate and extract school history: $e');
      await goToHome();
      throw Exception('Error navigating and extracting history: $e');
    } finally {
      _releaseSyncLock();
    }
  }
  
  // Aplicar o mesmo padrão para todos os métodos de sincronização:
  // - _runSync()
  // - navigateAndExtractGrades()
  // - navigateAndExtractTimetable()
  // - navigateAndExtractProfile()
  // - navigateAndExtractUser()
  // - navigateAndExtractAcademicAchievement()
}

// Exceção customizada para sincronização em andamento
class SyncInProgressException implements Exception {
  final String message;
  SyncInProgressException(this.message);
  
  @override
  String toString() => message;
}
```

### Atualização no ViewModel

```dart
class SchoolHistoryViewModel extends ChangeNotifier {
  // ... código existente ...
  
  Future<void> syncFromSiga() async {
    // Verifica localmente primeiro (otimização)
    if (_isSyncing) return;
    
    // Verifica globalmente no serviço
    if (_sigaService.isSyncing) {
      _errorMessage = 'Sincronização já em andamento: ${_sigaService.currentSyncOperation}';
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
```

### Atualização na UI

```dart
// Em school_history_page.dart
Widget _buildSyncingState(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sincronizando com o SIGA',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          if (_viewModel.syncStatusMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _viewModel.syncStatusMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Por favor, aguarde...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
        ],
      ),
    ),
  );
}
```

## Benefícios da Solução

1. **Previne Conflitos**: Apenas uma sincronização por vez
2. **Feedback Claro**: Usuário sabe qual operação está em andamento
3. **Logs Detalhados**: Facilita debug de problemas
4. **Simples**: Fácil de entender e manter
5. **Robusto**: Try-finally garante que lock sempre é liberado
6. **Escalável**: Fácil aplicar para todos os métodos de sincronização

## Checklist de Implementação

- [ ] Adicionar `_acquireSyncLock()` e `_releaseSyncLock()`
- [ ] Criar `SyncInProgressException`
- [ ] Adicionar propriedade `currentSyncOperation`
- [ ] Atualizar `navigateAndExtractSchoolHistory()`
- [ ] Atualizar `navigateAndExtractGrades()`
- [ ] Atualizar `navigateAndExtractTimetable()`
- [ ] Atualizar `navigateAndExtractProfile()`
- [ ] Atualizar `navigateAndExtractUser()`
- [ ] Atualizar `navigateAndExtractAcademicAchievement()`
- [ ] Atualizar `_runSync()`
- [ ] Atualizar ViewModels para tratar `SyncInProgressException`
- [ ] Testar sincronização manual durante automática
- [ ] Testar múltiplas telas tentando sincronizar
- [ ] Verificar que lock sempre é liberado (mesmo em erro)

## Testes Recomendados

1. **Teste de Concorrência Básico**
   - Iniciar sincronização automática
   - Tentar sincronização manual imediatamente
   - Verificar que segunda é rejeitada com mensagem clara

2. **Teste de Múltiplas Telas**
   - Abrir tela de histórico
   - Abrir tela de notas
   - Tentar sincronizar em ambas simultaneamente
   - Verificar que apenas uma executa

3. **Teste de Recuperação de Erro**
   - Forçar erro durante sincronização
   - Verificar que lock é liberado
   - Verificar que próxima sincronização funciona

4. **Teste de Timeout**
   - Simular timeout em operação
   - Verificar que lock é liberado
   - Verificar estado consistente

5. **Teste de Navegação Manual**
   - Iniciar sincronização
   - Tentar navegar manualmente no SIGA
   - Verificar comportamento (idealmente bloquear navegação manual)