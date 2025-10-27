# Mapa método -> script -> retorno -> parser / repositório

Arquivos inspecionados:
- [`lib/data/services/siga/siga_background_service.dart`](lib/data/services/siga/siga_background_service.dart:1)
- [`lib/data/services/siga/siga_scripts.dart`](lib/data/services/siga/siga_scripts.dart:1)
- [`lib/data/parsers/profile_parser.dart`](lib/data/parsers/profile_parser.dart:1)

Observação: este mapa relaciona métodos de alto nível do serviço SIGA com os scripts JS usados, o tipo de retorno esperado do JS, o pós-processamento realizado no Dart e o parser/repositório alvo.

Mapa:

- navigateAndExtractGrades()
  - scripts: SigaScripts.scriptNav(), script inline que clica no link de notas (no arquivo de serviço)
  - JS return types: scriptNav -> Promise; click script -> Promise; extractGradesScript -> JSON string (array) ou [{ error: ... }]
  - SigaBackgroundService post-processing: await waiter -> chama extractGrades() que faz jsonDecode (tratamento de double-encoding)
  - Output -> List<SubjectNote> -> persistido via _subjectNoteRepository.upsertSubjectNote

- extractGrades()
  - script: SigaScripts.extractGradesScript()
  - JS return: JSON string (stringified array) ou array/string com campo error
  - Processing: jsonDecode robusto (possível double-encode), mapeia para SubjectNote.fromJson
  - Parser: n/a (parsing em Dart)

- navigateAndExtractProfile()
  - scripts: SigaScripts.scriptNav(), SigaScripts.scriptInfo(), SigaScripts.scriptPerfil(), SigaScripts.getHtmlScript()
  - returns: scriptNav/info/perfil -> Promise; waiters -> boolean; getHtmlScript -> HTML string ou JSON { error: ... }
  - Processing: getHtmlScript pode retornar JSON de erro ou HTML; em caso de HTML usa ProfileParser(html).parseProfile()
  - Output -> List<BlockOfProfile> -> persistido via _subjectRepository e _blockRepository

- navigateAndExtractTimetable()
  - scripts: SigaScripts.scriptNav(), SigaScripts.scriptInfo(), SigaScripts.scriptGradeHorario(), SigaScripts.extractTimetableScript()
  - returns: scriptGradeHorario -> Promise; waitForTimetable -> boolean; extractTimetableScript -> JSON string (array) ou error
  - Processing: decode robusto, map para ScheduledSubject.fromJson
  - Persistido via _scheduledSubjectRepository (apaga todos antes se necessário)

- navigateAndExtractUser()
  - scripts: SigaScripts.scriptNav(), SigaScripts.scriptInfo(), SigaScripts.extractUserScript()
  - returns: extractUserScript -> JSON string (objeto) ou error
  - Processing: jsonDecode (double-encoded handling), mapeia para User entity
  - Persistido via _userRepository.upsertUser

- navigateAndExtractSchoolHistory()
  - scripts: SigaScripts.scriptNav(), SigaScripts.scriptInfo(), SigaScripts.scriptHistoricoEscolar(), SigaScripts.extractSchoolHistoryScript()
  - returns: extractSchoolHistoryScript -> JSON string (objeto) ou error
  - Processing: jsonDecode; campos como periods podem vir string -> decodificar novamente; normaliza e passa para _schoolHistoryRepository.upsertFromSiga
  - Também atualiza campos do usuário via _userRepository

- navigateAndExtractAcademicAchievement()
  - scripts: SigaScripts.scriptNav(), SigaScripts.scriptInfo(), SigaScripts.scriptAproveitamentoAcademico(), SigaScripts.extractAcademicAchievementScript()
  - returns: extractAcademicAchievementScript -> objeto JSON, porém com campos aninhados stringificados (workload_summary, component_summary, pending_components.subjects)
  - Processing: decodificação em camadas (jsonDecode múltiplas vezes), normalização (transforma workload summary plana em tree), persistência via _achievementRepository.upsertFromSiga

- Auth e checagens de sessão
  - scripts: SigaScripts.checkLoginScript(), SigaScripts.checkAuthErrorScript(), SigaScripts.loginScript(user,pass), SigaScripts.loginPageStylesScript, SigaScripts.suppressSigaErrorsScript
  - returns: checkLogin -> boolean; checkAuthError -> boolean; loginScript/styles/suppress -> sem retorno significativo (void)
  - Processing: _checkLoginStatus usa runJavaScriptReturningResult e atualiza _isLoggedIn, _authFailureNotifier, e completa _loginCompleter quando aplicável

- Helpers de navegação
  - scripts: scriptNav, scriptInfo, scriptPerfil, scriptGradeHorario, scriptHistoricoEscolar, scriptAproveitamentoAcademico
  - returns: Promises que resolvem em SUCESSO ou rejeitam com ERRO; serviço aguarda via runJavaScriptReturningResult

Issues e oportunidades de normalização (resumo)
- Formatos de retorno inconsistentes:
  - Alguns scripts retornam stringified JSON, outros retornam objetos/arrays ou simples booleans/strings de status.
  - Resultado: repetição de jsonDecode e verificações de double-encoding em vários pontos do serviço.
- Campos double-encoded (ex: academic achievement) exigem tratamentos específicos por método.
- Waiters duplicados:
  - Padrão Timer.periodic + timeout aparece em _waitForGradesPageReady, _waitForProfilePageReady, _waitForTimetablePageReady, _waitForStudentInfoPageReady, _waitForSchoolHistoryPageReady, _waitForAcademicAchievementPageReady.
  - Recomendação: extrair utilitário genérico Waiter.waitFor(script, timeout, pollInterval, errorPredicate).
- Mistura de responsabilidades:
  - Navegação, extração e persistência estão no mesmo método. Recomendar extrair *extractors* (retornam DTOs) e ter um *orquestrador* que persista.
- Logs e erros:
  - Padrão de retorno error em vários formatos; criar função decodeJsonRobust que normalize outputs e lance exceções padronizadas.

Recomendações de artefatos a gerar
- `docs/siga_scripts_spec.md` com assinatura e formato esperado de cada script e recomendação de retorno padrão (preferir objetos/arrays JSON não stringificados).
- Helper Dart decodeJsonRobust(data) para lidar com double-encoding e erros.
- Utilitário Waiter genérico para consolidar lógica de polling/timeouts.
- Extrair módulos:
  - siga_auth.dart (login, reconnect, _injectLoginScript, authNotifier)
  - siga_navigation.dart (WebViewController init/dispose, goHome, wrappers de scriptNav/scriptInfo)
  - siga_waiters.dart (todos os waiters)
  - siga_extractors.dart (grades, timetable, profile, user, school history, achievement) -> retornar DTOs, sem persistir
  - siga_orchestrator.dart (coordena locks, atualiza status, chama persistência)
- Testes prioritários:
  - ProfileParser com fixtures HTML
  - decodeJsonRobust com exemplos de double-encoded e malformados
  - Waiter util mockando runJavaScriptReturningResult

Prioridade curta (a executar primeiro)
1. Normalizar retornos via decodeJsonRobust
2. Extrair Waiters genéricos
3. Separar extractors da persistência
4. Mover lógica de auth

Referências:
- Serviço original: [`lib/data/services/siga/siga_background_service.dart`](lib/data/services/siga/siga_background_service.dart:1)
- Scripts: [`lib/data/services/siga/siga_scripts.dart`](lib/data/services/siga/siga_scripts.dart:1)
- Parser perfil: [`lib/data/parsers/profile_parser.dart`](lib/data/parsers/profile_parser.dart:1)