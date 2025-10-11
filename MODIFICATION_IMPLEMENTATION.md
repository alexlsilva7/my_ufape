# Plano de Implementação: Toggle para Overlay de Debug em Release

Este documento detalha as fases para implementar a funcionalidade de toggle do overlay de debug.

## Journal

*(Esta seção será atualizada ao final de cada fase.)*

---

## Fase 1: Lógica de Armazenamento (`LocalStoragePreferencesService`)

- [ ] No arquivo `lib/data/services/settings/local_storage_preferences_service.dart`:
  - [ ] Adicionar a chave estática: `static const String _debugOverlayKey = 'debug_overlay_enabled';`
  - [ ] Adicionar o getter: `bool get isDebugOverlayEnabled => prefs.getBool(_debugOverlayKey) ?? false;`
  - [ ] Adicionar o método `toggleDebugOverlay` para alterar e persistir o valor booleano.

**Pós-fase:**
- [ ] Executar as ferramentas de formatação e análise (`dart fix`, `dart format`, `analyze_files`).
- [ ] Atualizar o Journal e apresentar as alterações para aprovação do commit.

---

## Fase 2: Lógica de Negócios (`SettingsRepository`)

- [ ] No arquivo de interface `lib/data/repositories/settings/settings_repository.dart`:
  - [ ] Adicionar a propriedade: `bool isDebugOverlayEnabled;`
  - [ ] Adicionar a assinatura do método: `AsyncResult<Unit> toggleDebugOverlay();`
- [ ] No arquivo de implementação `lib/data/repositories/settings/settings_repository_impl.dart`:
  - [ ] Inicializar `isDebugOverlayEnabled` no construtor, buscando o valor do `LocalStoragePreferencesService`.
  - [ ] Implementar o método `toggleDebugOverlay`, que chama o serviço, atualiza a propriedade local e notifica os listeners.

**Pós-fase:**
- [ ] Executar as ferramentas de formatação e análise.
- [ ] Atualizar o Journal e apresentar as alterações para aprovação do commit.

---

## Fase 3: Interface do Usuário (`SettingsPage`)

- [ ] No arquivo `lib/ui/settings/settings_page.dart`:
  - [ ] Adicionar um `SwitchListTile` dentro do `Card` de "Preferências".
  - [ ] O título será "Habilitar Overlay de Debug".
  - [ ] O valor do switch será vinculado a `_settingsRepository.isDebugOverlayEnabled`.
  - [ ] O `onChanged` chamará o método `_settingsRepository.toggleDebugOverlay()`.

**Pós-fase:**
- [ ] Executar as ferramentas de formatação e análise.
- [ ] Atualizar o Journal e apresentar as alterações para aprovação do commit.

---

## Fase 4: Lógica de Exibição (`DebugOverlayWidget`)

- [ ] No arquivo `lib/ui/widgets/debug_overlay_widget.dart`:
  - [ ] Injetar o `SettingsRepository`.
  - [ ] Envolver o widget com um `ListenableBuilder` que escuta o `settingsRepository`.
  - [ ] Atualizar a condição de visibilidade do `Stack` para `kDebugMode || settingsRepository.isDebugOverlayEnabled`.

**Pós-fase:**
- [ ] Executar as ferramentas de formatação e análise.
- [ ] Atualizar o Journal e apresentar as alterações para aprovação do commit.

---

## Fase 5: Finalização

- [ ] Realizar testes manuais:
  - [ ] Verificar se o switch na tela de configurações ativa/desativa o botão de debug em modo release (será necessário criar uma build de release para testar 100%).
  - [ ] Verificar se em modo debug o botão está sempre visível, independentemente do switch.
- [ ] Atualizar o `README.md` se a nova funcionalidade for relevante para os usuários finais.
- [ ] Perguntar se você está satisfeito com o resultado final.
