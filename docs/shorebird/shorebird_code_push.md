O pacote shorebird_code_push permite implementar atualizações OTA (over-the-air) em aplicativos Flutter de forma prática. Veja como integrar e usar o Shorebird no projeto:

### Instalação

Adicione o pacote no seu pubspec.yaml:
```
flutter pub add shorebird_code_push
```
Isto também requer que o app seja inicializado e construído com Shorebird (leia o guia rápido oficial antes de avançar).[1][2]

### Uso Básico

No código do seu app:

```dart
import 'package:shorebird_code_push/shorebird_code_push.dart';

final updater = ShorebirdUpdater();

@override
void initState() {
  super.initState();
  updater.readCurrentPatch().then((currentPatch) {
    print('Patch atual: ${currentPatch?.number}');
  });
}
```

### Verificando e Aplicando Atualizações

Para verificar e instalar patches, crie uma função usando Future:

```dart
Future<void> _checkForUpdates() async {
  final status = await updater.checkForUpdate();
  if (status == UpdateStatus.outdated) {
    try {
      await updater.update();
    } on UpdateException catch (error) {
      // Trate erro de atualização
    }
  }
}
```
No seu widget, adicione um botão que chama esta função:

```dart
ElevatedButton(
  child: Text('Verificar atualizações'),
  onPressed: _checkForUpdates,
)
```
Se quiser usar tracks personalizados para distribuição segmentada:

```dart
final status = await updater.checkForUpdate(track: UpdateTrack.beta);
if (status == UpdateStatus.outdated) {
  await updater.update(track: UpdateTrack.beta);
}
```
Tracks permitem aplicar patches apenas para parte dos usuários, útil para testes A/B ou rollout gradual.[3][4]

### Recomendações Avançadas

- Use `TrackPicker` para selecionar o canal de rollout: stable, beta, staging ou customizado.
- Gerencie banners para informar ao usuário sobre atualizações baixadas ou erros.
- Integre releases automáticas via CI/CD para maximizar eficiência no deploy.[5][6]

### Recursos Adicionais

- [Exemplo oficial](https://pub.dev/packages/shorebird_code_push/example)
- [Dashboard Shorebird](https://docs.shorebird.dev/code-push/)
- Vídeos tutoriais no YouTube para explicações visuais da integração (Gabuldev, FULL STACKER).[7][8][9]

Esta abordagem cobre desde o setup básico até a utilização avançada de tracks para atualizações distribuídas.

[1](https://docs.shorebird.dev/getting-started/)
[2](https://pub.dev/packages/shorebird_code_push)
[3](https://pub.dev/packages/shorebird_code_push/example)
[4](https://pub.dev/packages/shorebird_code_push)
[5](https://vibe-studio.ai/in/insights/hot-restartless-code-push-with-shorebird-in-flutter)
[6](https://blog.codemagic.io/how-to-set-up-flutter-code-push-with-shorebird-and-codemagic-cicd/)
[7](https://www.youtube.com/watch?v=p1cMarxDCaM)
[8](https://www.youtube.com/watch?v=rrEmWGvEBnI)
[9](https://www.youtube.com/watch?v=k_d15vTEmH8)
[10](https://translate.google.com/translate?u=https%3A%2F%2Fdocs.shorebird.dev%2Fcode-push%2F&hl=pt&sl=en&tl=pt&client=srp)
[11](https://pt.linkedin.com/pulse/voc%C3%AA-j%C3%A1-ouviu-sobre-shorebird-vilson-dauinheimer)
[12](https://www.freecodecamp.org/news/how-to-push-silent-updates-in-flutter-using-shorebird/)
[13](https://docs.shorebird.dev/code-push/guides/hybrid-apps/android/)
[14](https://shorebird.dev/blog/how-we-built-code-push/)
[15](https://blog.codemagic.io/how-to-set-up-flutter-code-push-with-shorebird-and-codemagic/)
[16](https://www.reddit.com/r/reactnative/comments/17ozr4d/is_code_push_still_a_good_option_for_react_native/)
[17](https://www.youtube.com/watch?v=EIiBDoVHlNc)

# Tutorial Completo: shorebird_code_push com Exemplos Práticos

Agora que você já tem uma base sobre o Shorebird, vou mostrar como implementar recursos avançados como forçar reinicialização do app e integrar com telas de configurações.

## Implementação com Controle Manual de Atualizações

### 1. **Configuração Básica com Controle Manual**

Primeiro, desabilite as atualizações automáticas no `shorebird.yaml`:

```yaml
auto_update: false
```

Depois, implemente o controle manual no seu app:

```dart
import 'package:shorebird_code_push/shorebird_code_push.dart';

class UpdateService {
  final _updater = ShorebirdUpdater();
  
  Future<bool> checkForUpdates() async {
    final status = await _updater.checkForUpdate();
    return status == UpdateStatus.outdated;
  }

  Future<void> downloadUpdate() async {
    await _updater.update();
  }

  Future<bool> isUpdateReadyToInstall() async {
    final status = await _updater.checkForUpdate();
    return status == UpdateStatus.restartRequired;
  }
}
```

### 2. **Forçar Reinicialização do App**

Para reinicializar o app após uma atualização, você tem algumas opções:[1][2]

#### Opção 1: Usando `restart_app` (Recomendado)

```dart
import 'package:restart_app/restart_app.dart';

Future<void> forceAppRestart() async {
  await Restart.restartApp(
    notificationTitle: 'Reiniciando App',
    notificationBody: 'Por favor, toque aqui para abrir o app novamente.',
  );
}
```

#### Opção 2: Usando `flutter_phoenix`

```dart
import 'package:flutter_phoenix/flutter_phoenix.dart';

void main() {
  runApp(Phoenix(child: MyApp()));
}

// Para reiniciar em qualquer lugar:
Phoenix.rebirth(context);
```

#### Opção 3: Implementação Customizada

```dart
class RestartWidget extends StatefulWidget {
  final Widget child;
  
  const RestartWidget({Key? key, required this.child}) : super(key: key);
  
  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
```

### 3. **Tela de Configurações com Controle de Atualizações**

Aqui está um exemplo completo de como integrar o Shorebird numa tela de configurações:[3][1]

```dart
class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _updater = ShorebirdUpdater();
  bool _isCheckingUpdate = false;
  bool _isDownloadingUpdate = false;
  Patch? _currentPatch;
  UpdateTrack _selectedTrack = UpdateTrack.stable;

  @override
  void initState() {
    super.initState();
    _loadCurrentPatch();
  }

  Future<void> _loadCurrentPatch() async {
    try {
      final patch = await _updater.readCurrentPatch();
      setState(() {
        _currentPatch = patch;
      });
    } catch (e) {
      print('Erro ao carregar patch atual: $e');
    }
  }

  Future<void> _checkForUpdates() async {
    if (_isCheckingUpdate) return;
    
    setState(() {
      _isCheckingUpdate = true;
    });

    try {
      final status = await _updater.checkForUpdate(track: _selectedTrack);
      
      switch (status) {
        case UpdateStatus.upToDate:
          _showMessage('Nenhuma atualização disponível');
          break;
        case UpdateStatus.outdated:
          _showUpdateDialog();
          break;
        case UpdateStatus.restartRequired:
          _showRestartDialog();
          break;
        case UpdateStatus.unavailable:
          _showMessage('Shorebird não disponível');
          break;
      }
    } catch (e) {
      _showMessage('Erro ao verificar atualizações: $e');
    } finally {
      setState(() {
        _isCheckingUpdate = false;
      });
    }
  }

  Future<void> _downloadUpdate() async {
    setState(() {
      _isDownloadingUpdate = true;
    });

    try {
      await _updater.update(track: _selectedTrack);
      _showRestartDialog();
    } catch (e) {
      _showMessage('Erro ao baixar atualização: $e');
    } finally {
      setState(() {
        _isDownloadingUpdate = false;
      });
    }
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Atualização Disponível'),
        content: Text('Uma nova atualização está disponível. Deseja baixar agora?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Mais Tarde'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadUpdate();
            },
            child: Text('Baixar'),
          ),
        ],
      ),
    );
  }

  void _showRestartDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Reinicialização Necessária'),
        content: Text('A atualização foi baixada. Reinicie o app para aplicar as mudanças.'),
        actions: [
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Restart.restartApp();
            },
            child: Text('Reiniciar Agora'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Informações da Versão
          Card(
            child: ListTile(
              title: Text('Versão do Patch'),
              subtitle: Text(_currentPatch?.number.toString() ?? 'Nenhum patch instalado'),
              trailing: Icon(Icons.info_outline),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Seletor de Track
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Canal de Atualização', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 8),
                  SegmentedButton<UpdateTrack>(
                    segments: [
                      ButtonSegment(
                        value: UpdateTrack.stable,
                        label: Text('Estável'),
                      ),
                      ButtonSegment(
                        value: UpdateTrack.beta,
                        label: Text('Beta'),
                        icon: Icon(Icons.science),
                      ),
                      ButtonSegment(
                        value: UpdateTrack.staging,
                        label: Text('Teste'),
                        icon: Icon(Icons.construction),
                      ),
                    ],
                    selected: {_selectedTrack},
                    onSelectionChanged: (tracks) {
                      setState(() {
                        _selectedTrack = tracks.first;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Botão de Verificar Atualizações
          Card(
            child: ListTile(
              title: Text('Verificar Atualizações'),
              subtitle: Text('Procurar por novas atualizações disponíveis'),
              trailing: _isCheckingUpdate 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.refresh),
              onTap: _isCheckingUpdate ? null : _checkForUpdates,
            ),
          ),
          
          // Indicador de Download
          if (_isDownloadingUpdate)
            Card(
              child: ListTile(
                title: Text('Baixando Atualização...'),
                trailing: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
```

### 4. **Implementação com Estratégia Avançada**

Para uma estratégia mais robusta, combine Shorebird com Remote Config:[1]

```dart
class AdvancedUpdateStrategy {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  final _updater = ShorebirdUpdater();
  
  Future<void> checkUpdateStrategy() async {
    await _remoteConfig.fetchAndActivate();
    
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    
    final forceUpdateVersion = _remoteConfig.getString('force_update_for_version');
    final enableShorebirdUpdates = _remoteConfig.getBool('enable_shorebird_updates');
    
    if (currentVersion == forceUpdateVersion) {
      // Forçar atualização via loja
      _showForceUpdateDialog();
    } else if (enableShorebirdUpdates) {
      // Verificar patch do Shorebird
      _checkShorebirdPatch();
    }
  }
  
  Future<void> _checkShorebirdPatch() async {
    final status = await _updater.checkForUpdate();
    if (status == UpdateStatus.outdated) {
      // Download silencioso
      await _updater.update();
      // Mostrar notificação para reiniciar
      _showSoftRestartNotification();
    }
  }
}
```

### 5. **Exemplo de Uso com Timer Automático**

Para verificações periódicas em background:[4]

```dart
class AutoUpdateService {
  Timer? _timer;
  final _updater = ShorebirdUpdater();
  
  void startPeriodicCheck() {
    _timer = Timer.periodic(Duration(minutes: 15), (timer) async {
      try {
        final status = await _updater.checkForUpdate();
        if (status == UpdateStatus.outdated) {
          // Download automático em background
          await _updater.update();
          // Notificar usuário discretamente
          _showUpdateReadyNotification();
        }
      } catch (e) {
        print('Erro na verificação automática: $e');
      }
    });
  }
  
  void stopPeriodicCheck() {
    _timer?.cancel();
    _timer = null;
  }
}
```

### Considerações Importantes

1. **iOS vs Android**: No iOS, forçar o fechamento do app pode levar à rejeição na App Store. Use `restart_app` com cuidado.[5]

2. **Experiência do Usuário**: Prefira downloads silenciosos e notificações discretas ao invés de interrupções forçadas.[1]

3. **Tracks**: Use tracks (stable, beta, staging) para rollouts graduais e testes.[6]

4. **Tratamento de Erros**: Sempre implemente tratamento robusto de erros para conexões instáveis.[7]

Este tutorial cobre desde implementações básicas até estratégias avançadas para integrar o Shorebird em telas de configurações, com controle manual completo sobre o processo de atualização.

[1](https://www.freecodecamp.org/news/how-to-push-silent-updates-in-flutter-using-shorebird/)
[2](https://stackoverflow.com/questions/50115311/how-to-force-a-flutter-application-restart-in-production-mode)
[3](https://pub.dev/packages/shorebird_code_push/example)
[4](https://github.com/shorebirdtech/shorebird/issues/950)
[5](https://stackoverflow.com/questions/76161548/how-do-i-close-my-flutter-app-programmatically-on-ios/76162002)
[6](https://pub.dev/packages/shorebird_code_push)
[7](https://docs.shorebird.dev/code-push/update-strategies/)
[8](https://docs.shorebird.dev/code-push/guides/hybrid-apps/ios/)
[9](https://pub.dev/packages/shorebird_code_push)
[10](https://blog.codemagic.io/how-to-set-up-flutter-code-push-with-shorebird-and-codemagic-cicd/)
[11](https://docs.shorebird.dev/code-push/faq/)
[12](https://vibe-studio.ai/in/insights/hot-restartless-code-push-with-shorebird-in-flutter)
[13](https://shorebird.dev/blog/shorebird-codemagic/)
[14](https://www.youtube.com/watch?v=03wB0I1Z3NI)
[15](https://github.com/shorebirdtech/shorebird/issues/3055)
[16](https://docs.shorebird.dev/code-push/guides/hybrid-apps/android/)
[17](https://github.com/shorebirdtech/shorebird/issues/3275)
[18](https://www.youtube.com/watch?v=stWph9Mthts)
[19](https://blog.codemagic.io/how-to-set-up-flutter-code-push-with-shorebird-and-codemagic/)
[20](https://docs.codemagic.io/flutter-publishing/shorebird/)
[21](https://pub.dev/packages/shorebird_code_push/versions/1.1.6/example)
[22](https://fluttergems.dev/packages/shorebird_code_push/)
[23](https://www.dhiwise.com/post/flutter-phoenix-for-effective-flutter-application-restart)
[24](https://www.ungapps.com/2021/09/how-to-restart-app-with-flutter-android.html)
[25](https://www.geeksforgeeks.org/flutter/flutter-programmatically-exit-from-the-application/)
[26](https://github.com/shorebirdtech/shorebird/issues/2350)
[27](https://pub.dev/documentation/flutter_phoenix/latest/)
[28](https://vibe-studio.ai/insights/hot-restartless-code-push-with-shorebird-in-flutter)
[29](https://github.com/Zhalkhas/phoenix_native)
[30](https://pub.dev/packages/restart_app)
[31](https://docs.shorebird.dev/code-push/)
[32](https://www.reddit.com/r/FlutterDev/comments/sjfqif/how_to_restart_a_flutter_app_inside_the_engine/)
[33](https://mobikul.com/reload-restart-app-in-flutter/)
[34](https://pub.dev/packages/phoenix_loading/example)
[35](https://stackoverflow.com/questions/45109557/flutter-how-to-programmatically-exit-the-app)