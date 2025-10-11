# Documentação do Pacote Result Dart para Dart/Flutter

O `result_dart` é um pacote Dart que implementa o padrão `Result` inspirado nas classes do Kotlin e Swift, permitindo lidar com sucessos e falhas de forma mais estruturada. Ele reduz o uso de try/catch, centralizando o tratamento de erros e facilitando o fluxo de código em arquiteturas modernas. Inspirado em pacotes como `multiple_result`, `dartz` e `fpdart`, é distribuído sob a licença MIT.[1]

## Sobre o Projeto

Erros são comuns em aplicações, e arquiteturas modernas designam locais específicos para tratá-los, diminuindo try/catch e mantendo tratamentos centralizados. O `Result` encapsula dois valores principais: `Success` (sucesso) e `Failure` (falha). Essa implementação traz o padrão do Kotlin e Swift para o Dart, simplificando o manejo de resultados.[1]

## Migração da Versão 1.1.1 para 2.0.0

Essa versão reduz o boilerplate tornando `Failure` do tipo `Exception` por padrão, simplificando declarações:

```
// Antigo
Result<int, Exception> myResult = Success(42);

// Novo
Result<int> myResult = Success(42);
```

Para tipar `Failure` explicitamente, use `ResultDart<Success, Failure>`:

```
// Antigo
Result<int, String> myResult = Success(42);

// Novo
ResultDart<int, String> myResult = Success(42);
```


## Instalação

Adicione o `result_dart` ao seu projeto:

- No `pubspec.yaml`:

  ```
  dependencies:
    result_dart: ^2.0.0
  ```

- Ou via comando:

  ```
  dart pub add result_dart
  ```


## Como Usar

Defina funções que retornam `Result` para indicar sucesso ou falha:

```
Result<String> getSomethingPretty() {
  if (isOk) {
    return Success('OK!');
  } else {
    return Failure(Exception('Not Ok!'));
  }
}
```

Ou usando extensões:

```
Result<String> getSomethingPretty() {
  if (isOk) {
    return 'OK!'.toSuccess();
  } else {
    return Exception('Not Ok!').toFailure();
  }
}
```

Nota: `toSuccess()` e `toFailure()` não podem ser usados em objetos `Result` ou `Future`, senão lançam uma exceção de asserção.[1]

### Manipulando o Resultado

- **fold**: Aplica funções para sucesso ou falha.

  ```
  final result = getSomethingPretty();
  final message = result.fold(
    (success) => "success",
    (failure) => "failure",
  );
  ```

- **getOrThrow**: Retorna o valor ou lança exceção.

  ```
  try {
    final value = result.getOrThrow();
  } on Exception catch (e) {
    // Trata e
  }
  ```

- **getOrNull**: Retorna o valor de sucesso ou null.

  ```
  result.getOrNull();
  ```

- **getOrElse**: Retorna valor ou aplica função em falha.

  ```
  result.getOrElse((failure) => 'OK');
  ```

- **getOrDefault**: Retorna valor ou default.

  ```
  result.getOrDefault('OK');
  ```

- **exceptionOrNull**: Retorna a exceção ou null.

  ```
  result.exceptionOrNull();
  ```


### Transformando um Resultado

- **map**: Mapeia o valor de sucesso.

  ```
  final result = getResult().map((e) => MyObject.fromMap(e));
  ```

- **mapError**: Mapeia o valor de falha.

  ```
  final result = getResult().mapError((e) => MyException(e));
  ```

- **flatMap**: Encadeia outro `Result` em sucesso.

  ```
  Result<String, MyException> checkIsEven(String input) {
    if (int.parse(input) % 2 == 0) {
      return Success(input);
    } else {
      return Failure(MyException('isn`t even!'));
    }
  }

  final result = getNumberResult().flatMap((s) => checkIsEven(s));
  ```

- **flatMapError**: Encadeia outro `Result` em falha.

  ```
  final result = getNumberResult().flatMapError((e) => checkError(e));
  ```

- **recover**: Resolve falha retornando um novo `Result`.

  ```
  final result = getNumberResult().recover((f) => Success('Resolved!'));
  ```

- **pure**: Altera o valor de sucesso.

  ```
  final result = getSomethingPretty().pure(10);
  ```

- **pureError**: Altera o valor de falha.

  ```
  final result = getSomethingPretty().pureError(10);
  ```

- **swap**: Troca sucesso e falha.

  ```
  Result<String, int> result = ...;
  Result<int, String> newResult = result.swap();
  ```


### Tipo Unit

Use `Unit` para retornos vazios:

```
Result<Unit>
```


### Funções Auxiliares

Importe `'package:result_dart/functions.dart'` para funções como `identity` (ou `id`) para retornar o parâmetro diretamente:

```
final result = Success(0);
String value = result.when((s) => '$s', id);
```


### AsyncResult

`AsyncResult<S, E>` é um alias para `Future<Result<S, E>>`, com operadores semelhantes para computações assíncronas:

```
AsyncResult<String> fetchProducts() async {
  try {
    final response = await dio.get('/products');
    final products = ProductModel.fromList(response.data);
    return Success(products);
  } on DioError catch (e) {
    return Failure(ProductException(e.message));
  }
}

final state = await fetch().map((products) => LoadedState(products)).mapError((failure) => ErrorState(failure));
```


## Recursos

- Implementação de `Result`.
- Operadores para `Result` e `AsyncResult` (map, flatMap, etc.).
- Funções auxiliares (id, successOf, failureOf).
- Tipo Unit.

Para mais detalhes, consulte a documentação oficial no pub.dev.[1]

[1](https://pub.dev/packages/auto_injector)
[2](https://pub.dev/packages/result_dart)
[3](https://pub.dev/documentation/result_dart/latest/result_dart)
[4](https://docs.flutter.dev/app-architecture/design-patterns/result)
[5](https://fluttergems.dev/packages/result_dart/)
[6](https://github.com/Flutterando/result_command)
[7](https://www.youtube.com/watch?v=5kJog_PhGbY)
[8](https://github.com/Flutterando)
[9](https://www.youtube.com/watch?v=3P8yuWp7hcI)
[10](https://fluttergems.dev/language-extension-enhancement/)