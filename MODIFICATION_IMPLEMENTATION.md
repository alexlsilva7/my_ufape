# Plano de Implementação: Melhoria no Rastreamento de Background Sync

Este documento detalha as fases para implementar o rastreamento aprimorado da sincronização em segundo plano.

## Journal

*Esta seção será atualizada após cada fase com um log das ações, aprendizados e desvios.*

---

## Fase 1: Modificar a Entidade e o Repositório

Nesta fase, vamos atualizar a estrutura de dados para suportar as novas informações de sincronização.

- [ ] Criar o enum `SyncStatus` em `lib/domain/entities/user.dart`.
- [ ] Modificar a entidade `User` em `lib/domain/entities/user.dart` para:
    - Renomear `lastBackgroundSync` para `lastSyncAttempt`.
    - Renomear `lastSuccessfulSync` para `lastSyncSuccess`.
    - Adicionar `lastSyncStatus` do tipo `SyncStatus`.
    - Adicionar `lastSyncMessage` do tipo `String?`.
- [ ] Executar o `build_runner` para gerar o novo schema do Isar.
- [ ] Atualizar o `UserRepositoryImpl` se necessário para lidar com as mudanças na entidade `User`.
- [ ] Criar/modificar testes unitários para a entidade `User` e `UserRepository`.
- [ ] Executar `dart fix --apply`.
- [ ] Executar `dart format .`.
- [ ] Executar `flutter analyze`.
- [ ] Executar todos os testes para garantir que nada foi quebrado.
- [ ] Revisar as mudanças com `git diff`.
- [ ] Apresentar a mensagem de commit para aprovação.

---

## Fase 2: Implementar a Lógica no Serviço de Background

Agora, vamos implementar a lógica que atualiza o status da sincronização durante a execução.

- [ ] Modificar `runFullBackgroundSync` em `lib/data/services/siga/siga_background_service.dart`:
    - No início do método, obter o usuário e atualizar `lastSyncStatus` para `IN_PROGRESS` e `lastSyncAttempt` para `DateTime.now()`.
    - No final do bloco `try` (sucesso), atualizar `lastSyncStatus` para `SUCCESS` e `lastSyncSuccess` para `DateTime.now()`.
    - No bloco `catch` (falha), atualizar `lastSyncStatus` para `FAILED` e `lastSyncMessage` com a mensagem de erro.
- [ ] Criar/modificar testes unitários para `SigaBackgroundService` para cobrir a nova lógica de atualização de status.
- [ ] Executar `dart fix --apply`.
- [ ] Executar `dart format .`.
- [ ] Executar `flutter analyze`.
- [ ] Executar todos os testes.
- [ ] Revisar as mudanças com `git diff`.
- [ ] Apresentar a mensagem de commit para aprovação.

---

## Fase 3: Finalização e Limpeza

Nesta fase, vamos garantir que o projeto esteja limpo e pronto.

- [ ] Atualizar o `GEMINI.md` para refletir as mudanças na entidade `User` e na lógica de sincronização.
- [ ] Remover o arquivo `MODIFICATION_DESIGN.md`.
- [ ] Remover o arquivo `MODIFICATION_IMPLEMENTATION.md`.
- [ ] Apresentar a mensagem de commit final para aprovação.
- [ ] Perguntar ao usuário se ele está satisfeito com as modificações.
