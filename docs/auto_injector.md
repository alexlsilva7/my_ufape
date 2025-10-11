# Documentação do Pacote Auto Injector para Dart/Flutter

O Auto Injector é um pacote Dart que facilita a injeção de dependências automática, sem a necessidade de build_runner. Ele permite injetar dependências de forma simples e prática, registrando classes em métodos como "add" e acessando-as facilmente. É distribuído sob a licença MIT.[1]

## Sobre o Projeto

O Auto Injector foi criado para simplificar a vida do desenvolvedor, tornando a injeção de dependências mais intuitiva. Basta criar a classe a ser injetada e declará-la em um dos métodos "add" disponíveis. Isso elimina a complexidade de configurações manuais, sendo ideal para projetos Flutter ou Dart puros.[1]

## Instalação

Para adicionar o Auto Injector ao seu projeto, siga uma das opções abaixo:

- Adicione como dependência no seu `pubspec.yaml`:

  ```
  dependencies:
    auto_injector: ^2.1.1
  ```

- Ou use o comando Dart Pub:

  ```
  dart pub add auto_injector
  ```

Após adicionar, execute `dart pub get` para instalar.[1]

## Como Usar

### Registro de Instâncias

Crie um injetor e registre instâncias usando métodos como factory, singleton, lazySingleton ou instance. Finalize com `commit()`:

```
final autoInjector = AutoInjector();

void main() {
  // Factory
  autoInjector.add(Controller.new);

  // Singleton
  autoInjector.addSingleton(Datasource.new);

  // Lazy Singleton
  autoInjector.addLazySingleton(Repository.new);

  // Instance
  autoInjector.addInstance('Instance');

  // Finalize o registro
  autoInjector.commit();
}

class Controller {
  final Repository repository;
  Controller(this.repository);
}

class Repository {
  final Datasource datasource;
  Repository({required this.datasource});
}

class Datasource {}
```

Para registrar com uma chave específica:

```
autoInjector.add(Controller.new, key: 'MyCustomName');
```


### Obtenção de Instâncias

Recupere instâncias registradas:

```
// Obter instância
final controller = autoInjector.get<Controller>();
print(controller); // Instance of 'Controller'

// Ou use a função callable (sem .get())
final datasource = autoInjector<Datasource>();
print(datasource); // Instance of 'Datasource'
```

Por chave:

```
final controller = autoInjector.get<Controller>(key: 'CustomController');
```

Tente obter (retorna null se falhar):

```
final datasource = autoInjector.tryGet<Datasource>() ?? Datasource();
```

Transforme parâmetros (útil para mocks em testes):

```
final datasource = autoInjector.get<Datasource>(transform: changeParam(DataSourceMock()));
```


### Descarte de Singletons

Descarte singletons sob demanda e execute rotinas de limpeza:

```
final deadInstance = autoInjector.disposeSingleton<MyController>();
deadInstance.close();
```


## Modularização

Para projetos com múltiplos escopos, use injetores nomeados (tags) para organizar módulos:

```
// app_module.dart
final appModule = AutoInjector(
  tag: 'AppModule',
  on: (i) {
    i.addInjector(productModule);
    i.addInjector(userModule);
    i.commit();
  },
);

// product_module.dart
final productModule = AutoInjector(
  tag: 'ProductModule',
  on: (i) {
    i.addInstance(1);
  },
);

// user_module.dart
final userModule = AutoInjector(
  tag: 'UserModule',
  on: (i) {
    i.addInstance(true);
  },
);

void main() {
  print(appModule.get<int>()); // 1
  print(appModule.get<bool>()); // true
}
```

Descarte singletons por tag:

```
autoInjector.disposeSingletonsByTag('ProductModule', (instance) {
  // Rotina de descarte individual
});
```


## Transformação de Parâmetros

Ouça e transforme parâmetros durante a solicitação de instâncias:

```
final homeModule = AutoInjector(
  paramTransforms: [
    (param) {
      if (param is NamedParam) {
        return param;
      } else if (param is PositionalParam) {
        return param;
      }
    },
  ],
);
```


## Configuração de Bind

Configure dispose e notifier para binds, útil para classes como BLoC:

```
final injector = AutoInjector();
final config = BindConfig<Bloc>(
  onDispose: (bloc) => bloc.close(),
  onNotifier: (bloc) => bloc.stream,
);
injector.addSingleton(ProductBloc.new, config: config);
```


## Recursos

- Injeção automática de dependências
- Injeção de factory
- Injeção de singleton
- Injeção de lazy singleton
- Injeção de instância

Para mais exemplos e detalhes, consulte a documentação oficial no pub.dev.[1]

[1](https://pub.dev/packages/auto_injector)