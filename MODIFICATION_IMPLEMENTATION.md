# Plano de Implementação da Modificação: Melhoria do Fluxo de Login (Híbrido)

Este documento detalha as fases e tarefas para implementar a melhoria do fluxo de login, conforme descrito no `MODIFICATION_DESIGN.md`.

## Journal

*   **Fase 2:** Refatorei o `SigaBackgroundService` para incluir a lógica de login ativo com um `Completer`, e adicionei um `ValueNotifier` para notificar sobre falhas de autenticação. Adicionei também o `checkAuthErrorScript` ao `siga_scripts.dart` para detectar senhas inválidas. Executei as ferramentas de formatação e análise, e corrigi um aviso de documentação no `siga_background_service.dart`.
*   **Fase 3:** Refatorei a `LoginPage` para ser `Stateful` e gerenciar um estado de `_isLoading`. A UI agora exibe um `CircularProgressIndicator` durante o login. O método `_handleLogin` foi atualizado para chamar o `SigaBackgroundService` e aguardar o resultado, e a lógica para carregar credenciais salvas foi removida. Corrigi um aviso de `deprecated_member_use` que surgiu na nova implementação.

---

## Fase 1: Preparação

O objetivo desta fase é garantir que o projeto esteja em um estado estável antes de iniciarmos as modificações.

- [x] *(Nenhuma ação necessária, pois os testes automatizados foram pulados a pedido.)*

---

## Fase 2: Refatoração do `SigaBackgroundService`

Nesta fase, vamos adaptar o serviço para orquestrar o login ativo e notificar a aplicação sobre falhas críticas de autenticação.

- [x] Adicionar um `Completer<bool>? _loginCompleter;` à classe `SigaBackgroundService`.
- [x] Implementar o novo método público `Future<bool> login(String username, String password)` conforme o design.
- [x] Modificar os métodos `onPageFinished` e `_checkLoginStatus` para interagir com o `_loginCompleter`:
    - [x] Ao detectar sucesso no login (`_isLoggedIn` se torna `true`), completar o `_loginCompleter` com `true`.
    - [x] Ao detectar uma falha (ex: timeout, erro na página), completar o `_loginCompleter` com `false`.
- [x] Adicionar um novo `ValueNotifier<bool> _authFailureNotifier = ValueNotifier(false);` para notificar a aplicação sobre credenciais inválidas detectadas em segundo plano.
- [x] Criar um getter `ValueListenable<bool> get authFailureNotifier => _authFailureNotifier;` para expor o notifier.
- [x] No `_checkLoginStatus` ou em um método auxiliar, adicionar lógica para identificar uma falha de autenticação na página do SIGA (ex: procurar por texto como "usuário ou senha inválida") e, se encontrada, atualizar `_authFailureNotifier.value = true;`.

**Após esta fase:**

- [x] Executar `dart fix --apply` para limpar o código.
- [x] Executar `dart format .` para garantir a formatação correta.
- [x] Executar a análise estática (`analyze_files`) e corrigir quaisquer problemas.
- [x] Atualizar a seção "Journal" deste documento.
- [x] Apresentar as alterações e a mensagem de commit para sua aprovação antes de prosseguir.

---

## Fase 3: Refatoração da `LoginPage`

O objetivo é transformar a `LoginPage` para que ela gerencie o estado de carregamento e utilize o novo método de login do serviço.

- [x] Adicionar uma variável de estado `bool _isLoading = false;` no `_LoginPageState`.
- [x] Envolver o `Scaffold` ou a `Column` principal com um `Stack` para sobrepor um `CircularProgressIndicator` quando `_isLoading` for `true`.
- [x] Implementar a nova lógica do método `_handleLogin`, que agora será `async`, chamará `injector.get<SigaBackgroundService>().login(...)`, e aguardará o resultado para navegar ou mostrar erro, conforme o design.

**Após esta fase:**

- [x] Executar `dart fix --apply`.
- [x] Executar `dart format .`.
- [x] Executar a análise estática e corrigir problemas.
- [x] Atualizar a seção "Journal" deste documento.
- [ ] Apresentar as alterações e a mensagem de commit para sua aprovação.

---

## Fase 4: Refatoração da `SplashViewModel` e `SettingsRepository`

Vamos implementar o fluxo de inicialização offline-first.

- [ ] No `SettingsRepository`, criar um novo método `Future<bool> hasUserCredentials()` que verifica se as chaves 'username' e 'password' existem no `FlutterSecureStorage`.
- [ ] Refatorar o método `init()` na `SplashViewModel` para seguir a nova lógica offline-first, usando `hasUserCredentials()` para decidir se navega imediatamente para a Home ou para a tela de Login.

**Após esta fase:**

- [ ] Executar `dart fix --apply`.
- [ ] Executar `dart format .`.
- [ ] Executar a análise estática e corrigir problemas.
- [ ] Atualizar a seção "Journal" deste documento.
- [ ] Apresentar as alterações e a mensagem de commit para sua aprovação.

---

## Fase 5: Gestão Global de Falha de Autenticação e Finalização

Nesta fase final, vamos garantir que o app reaja a uma falha de autenticação em segundo plano e faremos a verificação final.

- [ ] No `AppWidget` (ou em um widget pai adequado que não seja descartado), obter a instância do `SigaBackgroundService`.
- [ ] Usar um `ValueListenableBuilder` para escutar o `authFailureNotifier` do serviço.
- [ ] No `builder` do `ValueListenableBuilder`, se o valor for `true`, chamar `Routefly.navigate(routePaths.login)` para forçar o usuário a ir para a tela de login. É importante também resetar o notifier para `false` para não entrar em um loop de navegação.
- [ ] **Testes Manuais:**
    - [ ] Testar o login pela primeira vez (online).
    - [ ] Fechar e abrir o app sem internet (deve ir para a Home e mostrar dados locais).
    - [ ] Fechar e abrir o app com internet (deve ir para a Home e sincronizar em segundo plano).
    - [ ] Testar o login ativo com credenciais erradas (deve mostrar erro).
    - [ ] Simular uma falha de autenticação em segundo plano (alterando a senha salva para uma incorreta) para garantir que o usuário é redirecionado para a tela de login.
- [ ] Atualizar o arquivo `README.md` do projeto com informações sobre o novo fluxo de login, se relevante.
- [ ] Revisar o `MODIFICATION_DESIGN.md` e este `MODIFICATION_IMPLEMENTATION.md` para garantir que estão consistentes com o resultado final.
- [ ] Perguntar a você se está satisfeito com o resultado final e se alguma outra modificação é necessária.

---

**Instruções Gerais:**

*   Após completar uma tarefa, se você adicionou algum `TODO` ao código ou não implementou algo completamente, certifique-se de adicionar novas tarefas para que possamos voltar e completá-las mais tarde.
*   Ao final de cada fase, aguarde a aprovação da mensagem de commit antes de executá-lo e passar para a próxima fase.