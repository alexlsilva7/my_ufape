# Documento de Design da Modificação: Toggle para Overlay de Debug em Release

## 1. Visão Geral

Este documento descreve o design para adicionar uma nova funcionalidade que permite habilitar o overlay de debug (o botão flutuante que abre o `WebView` do SIGA) em builds de release. A ativação será feita através de um novo switch na tela de Configurações.

## 2. Análise Detalhada

Atualmente, o `DebugOverlayWidget` só é visível quando a flag `kDebugMode` do Flutter é `true`. Para permitir que ele seja ativado em modo release, precisamos de uma forma de persistir a escolha do usuário. A arquitetura existente já possui um `SettingsRepository` e um `LocalStoragePreferencesService` que usam `SharedPreferences` para persistir configurações simples, como o modo escuro. Usaremos essa mesma estrutura.

## 3. Design Detalhado da Modificação

A implementação será dividida em quatro partes principais: o serviço de armazenamento local, o repositório de configurações, a página de configurações (UI) e o widget do overlay.

### 3.1. `LocalStoragePreferencesService`

Seguindo o padrão existente para o `isDarkMode`, vamos adicionar a lógica para o overlay de debug.

- **Nova Chave:**
  ```dart
  static const String _debugOverlayKey = 'debug_overlay_enabled';
  ```
- **Novo Getter:**
  ```dart
  bool get isDebugOverlayEnabled => prefs.getBool(_debugOverlayKey) ?? false;
  ```
- **Novo Método de Toggle:**
  ```dart
  AsyncResult<Unit> toggleDebugOverlay() async {
    try {
      await prefs.setBool(_debugOverlayKey, !isDebugOverlayEnabled);
      return Success(unit);
    } catch (e, s) {
      return Failure(AppException(e.toString(), s));
    }
  }
  ```

### 3.2. `SettingsRepository` (Interface e Implementação)

O repositório irá expor a nova configuração para o resto do aplicativo.

- **Interface (`settings_repository.dart`):**
  - Adicionar a propriedade: `bool isDebugOverlayEnabled = false;`
  - Adicionar a assinatura do método: `AsyncResult<Unit> toggleDebugOverlay();`

- **Implementação (`settings_repository_impl.dart`):**
  - No construtor, inicializar a nova propriedade: `isDebugOverlayEnabled = _localStoragePreferencesService.isDebugOverlayEnabled;`
  - Implementar o método `toggleDebugOverlay` que chamará o método correspondente no `_localStoragePreferencesService` e notificará os listeners.
  ```dart
  @override
  AsyncResult<Unit> toggleDebugOverlay() async {
    await _localStoragePreferencesService.toggleDebugOverlay();
    isDebugOverlayEnabled = !isDebugOverlayEnabled;
    notifyListeners();
    return Success(unit);
  }
  ```

### 3.3. `SettingsPage`

A UI será atualizada para incluir o novo switch.

- **Novo `SwitchListTile`:**
  - Dentro do `Card` de "Preferências", um novo `SwitchListTile` será adicionado.
  - `title`: `Text('Habilitar Overlay de Debug')`
  - `subtitle`: `Text('Exibe o botão de debug mesmo em release')`
  - `value`: Vinculado a `_settingsRepository.isDebugOverlayEnabled`.
  - `onChanged`: Chamará `_settingsRepository.toggleDebugOverlay()`.

### 3.4. `DebugOverlayWidget`

O widget será modificado para considerar a nova configuração, além do `kDebugMode`.

- **Injeção de Dependência:** O `SettingsRepository` será injetado no widget.
- **Lógica de Visibilidade Atualizada:** O `build` do widget será envolvido por um `ListenableBuilder` que escuta o `settingsRepository`. A condição para exibir o `Stack` com o botão será alterada de `if (!kDebugMode)` para:
  ```dart
  final settingsRepository = injector.get<SettingsRepository>();
  // ... dentro do build method ...
  return ListenableBuilder(
    listenable: settingsRepository,
    builder: (context, child) {
      final showOverlay = kDebugMode || settingsRepository.isDebugOverlayEnabled;
      if (!showOverlay) {
        return widget.child; // Acessando o child do StatefulWidget
      }
      // ... resto da lógica do Stack ...
    },
  );
  ```
  **Correção:** O `DebugOverlayWidget` é um `StatelessWidget`, então a lógica será mais simples, sem `StatefulWidget`.

  ```dart
  // Lógica final no DebugOverlayWidget
  @override
  Widget build(BuildContext context) {
    final settingsRepository = injector.get<SettingsRepository>();

    return ListenableBuilder(
      listenable: settingsRepository,
      builder: (context, _) {
        final showOverlay = kDebugMode || settingsRepository.isDebugOverlayEnabled;

        if (!showOverlay) {
          return child;
        }

        return Stack(
          children: [
            child,
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  Routefly.push(routePaths.debugSiga);
                },
                child: const Icon(Icons.bug_report),
              ),
            ),
          ],
        );
      },
    );
  }
  ```

## 4. Resumo do Design

A solução é simples e reutiliza a arquitetura de configurações existente. Ao adicionar a flag `isDebugOverlayEnabled` e persisti-la com `SharedPreferences`, permitimos que o `DebugOverlayWidget` reaja a essa configuração em tempo real, além da verificação padrão do `kDebugMode`. A adição do switch na tela de configurações torna a funcionalidade acessível e fácil de usar.
