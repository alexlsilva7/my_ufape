# Documentação do Pacote Result Command para Flutter

O `result_command` é um pacote leve que implementa o padrão **Command Pattern** no Flutter, permitindo encapsular ações, rastrear estados e gerenciar resultados. Ele utiliza o pacote `result_dart` para lidar com sucessos e falhas de forma estruturada, facilitando o gerenciamento de estados em aplicações.[1]

## Instalação

Adicione o pacote ao seu `pubspec.yaml`:

```
dependencies:
  result_command: ^2.1.0
  result_dart: ^2.0.0
```

Em seguida, execute `flutter pub get` para instalar.[1]

## Como Usar

### 1. Criando um Comando

Comandos encapsulam ações e gerenciam seu ciclo de vida. Use `Command0` para ações sem parâmetros, `Command1` para um parâmetro e `Command2` para dois:

```
final fetchGreetingCommand = Command0<String>(
  () async {
    await Future.delayed(Duration(seconds: 2));
    return Success('Hello, World!');
  },
);

final calculateSquareCommand = Command1<int, int>(
  (number) async {
    if (number < 0) {
      return Failure(Exception('Negative numbers are not allowed.'));
    }
    return Success(number * number);
  },
);
```


### 2. Escutando um Comando

Comandos são `Listenable`, permitindo reagir a mudanças de estado:

#### Usando `addListener`

```
fetchGreetingCommand.addListener(() {
  final status = fetchGreetingCommand.value;
  if (status is SuccessCommand<String>) {
    print('Success: ${status.value}');
  } else if (status is FailureCommand<String>) {
    print('Failure: ${status.error}');
  }
});
```

#### Usando `ValueListenableBuilder`

```
Widget build(BuildContext context) {
  return ListenableBuilder(
    listenable: fetchGreetingCommand,
    builder: (context, _) {
      return switch (fetchGreetingCommand.value) {
        RunningCommand<String>() => CircularProgressIndicator(),
        SuccessCommand<String>(:final value) => Text('Success: $value'),
        FailureCommand<String>(:final error) => Text('Failure: $error'),
        _ => ElevatedButton(
            onPressed: () => fetchGreetingCommand.execute(),
            child: Text('Fetch Greeting'),
          ),
      };
    },
  );
}
```

#### Usando `when` para Manipulação Simplificada

```
fetchGreetingCommand.addListener(() {
  final status = fetchGreetingCommand.value;
  final message = status.when(
    data: (value) => 'Success: $value',
    failure: (exception) => 'Error: ${exception?.message}',
    running: () => 'Fetching...',
    orElse: () => 'Idle',
  );
  print(message);
});
```


### 3. Executando um Comando

O método `execute()` dispara a ação. O comando passa por estados como Idle, Running, Success, Failure ou Cancelled. Execuções simultâneas são ignoradas:

```
fetchGreetingCommand.execute();
```


### 4. Cancelando um Comando

Cancele comandos em estado Running, invocando um callback opcional `onCancel`:

```
final uploadCommand = Command0<void>(
  () async {
    await Future.delayed(Duration(seconds: 5));
  },
  onCancel: () {
    print('Upload cancelled');
  },
);

uploadCommand.execute();
Future.delayed(Duration(seconds: 2), () {
  uploadCommand.cancel();
});
```


### 5. Facilitadores

- Verificadores de estado: `isRunning`, `isIdle`, etc.

```
if (command.isRunning) {
  print('Command is running.');
}
```

- Valores em cache: `getCachedSuccess()` e `getCachedFailure()` para evitar atualizações desnecessárias.

```
final successValue = command.getCachedSuccess();
if (successValue != null) {
  print('Last successful value: $successValue');
}
```


### 6. Filtrando Estados do Comando

O método `filter` deriva um novo valor do estado do comando:

```
final filteredValue = command.filter<String>(
  'Default Value',
  (state) {
    if (state is SuccessCommand<String>) {
      return 'Success: ${state.value}';
    } else if (state is FailureCommand<String>) {
      return 'Error: ${state.error}';
    }
    return null; // Ignora outros estados
  },
);

filteredValue.addListener(() {
  print('Filtered Value: ${filteredValue.value}');
});
```


### 7. CommandRef

`CommandRef` cria comandos que escutam mudanças em `ValueListenables` e executam ações baseadas em valores derivados:

```
final listenable = ValueNotifier<int>(0);
final commandRef = CommandRef<int, int>(
  (ref) => ref(listenable),
  (value) async => Success(value * 2),
);

commandRef.addListener(() {
  final status = commandRef.value;
  if (status is SuccessCommand<int>) {
    print('Result: ${status.value}');
  }
});

listenable.value = 5; // Executa o comando com o valor 5
```


## Recursos

- Implementação do Command Pattern com estados encapsulados.
- Integração com `result_dart` para resultados.
- Suporte a escuta, execução, cancelamento e filtragem.

Para exemplos avançados e documentação detalhada, consulte o pub.dev.[1]

[1](https://pub.dev/packages/auto_injector)
[2](https://pub.dev/packages/result_command)
[3](https://pub.dev/packages/result_command/versions)
[4](https://docs.flutter.dev/app-architecture/design-patterns/result)
[5](https://pt.linkedin.com/posts/jacob-moura_tivemos-algumas-atualiza%C3%A7%C3%B5es-no-resultcommand-activity-7338953855625297920-DoXn)
[6](https://stackoverflow.com/questions/57213340/how-to-add-a-package-from-command-line-in-flutter)
[7](https://docs.flutter.dev/packages-and-plugins/developing-packages)
[8](https://fluttergems.dev)
[9](https://dart.dev/tools/pub/package-layout)
[10](https://getstream.io/blog/breaking-down-flutter-package/)
[11](https://learn.microsoft.com/en-us/clarity/mobile-sdk/flutter-sdk)