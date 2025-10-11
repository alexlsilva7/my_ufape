# Guia de Implementação do Isar Database no Flutter

O Isar é um banco de dados NoSQL de alta performance projetado especialmente para Flutter, oferecendo operações rápidas, queries reativas e integração nativa com Dart.[1][2][3]

## Passo 1: Adicionar Dependências

Adicione os pacotes necessários ao projeto usando o terminal :[4][5]

```bash
dart pub add isar:^3.1.8 isar_flutter_libs:^3.1.8 --hosted-url=https://pub.isar-community.dev
dart pub add dev:isar_generator:^3.1.8 --hosted-url=https://pub.isar-community.dev
```

Para projetos Flutter, você pode usar alternativamente :[1]

```bash
flutter pub add isar isar_flutter_libs
flutter pub add -d isar_generator build_runner
```

## Passo 2: Criar o Modelo de Dados

Crie uma classe anotada com `@collection` e defina um campo `Id` :[6][4]

```dart
import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement; // auto incremento automático
  String? name;
  int? age;
}
```

O campo `Id` identifica exclusivamente cada objeto na coleção e permite localizá-lo posteriormente.[4][6]

## Passo 3: Executar o Gerador de Código

Execute o build_runner para gerar os arquivos necessários :[6][4]

```bash
dart run build_runner build
```

Para projetos Flutter :[1]

```bash
flutter pub run build_runner build
```

Isso criará o arquivo `user.g.dart` com o schema gerado automaticamente.[3][7]

## Passo 4: Inicializar a Instância Isar

Abra uma instância do Isar e passe os schemas das coleções :[4][1]

```dart
import 'package:path_provider/path_provider.dart';

final dir = await getApplicationDocumentsDirectory();
final isar = await Isar.open(
  [UserSchema],
  directory: dir.path,
);
```

Você pode especificar opcionalmente um nome de instância e diretório personalizado.[7][6]

## Passo 5: Operações CRUD

### Criar e Atualizar (Create/Update)

Use `writeTxn` para transações de escrita :[6][4]

```dart
final newUser = User()
  ..name = 'Jane Doe'
  ..age = 36;

await isar.writeTxn(() async {
  await isar.users.put(newUser); // inserir ou atualizar
});
```

### Ler (Read)

Busque objetos pelo ID :[3][4]

```dart
final existingUser = await isar.users.get(newUser.id);
```

Para buscar todos os registros :[2]

```dart
final allUsers = await isar.users.where().findAll();
```

### Deletar (Delete)

Remova objetos dentro de uma transação :[4][6]

```dart
await isar.writeTxn(() async {
  await isar.users.delete(existingUser.id!);
});
```

## Recursos Adicionais

### Queries Complexas

O Isar oferece uma linguagem de queries poderosa com filtros e ordenação :[8][3]

```dart
final results = await isar.users
  .filter()
  .ageGreaterThan(18)
  .sortByName()
  .findAll();
```

### Índices e Full-Text Search

Adicione índices para melhorar a performance das buscas :[8][3]

```dart
@collection
class User {
  Id id = Isar.autoIncrement;
  
  @Index(type: IndexType.value)
  String? name;
  
  int? age;
}
```

### Isar Inspector

Execute o app em modo debug com a flag do inspector :[3]

```bash
flutter run --dart-define=ISAR_INSPECTOR=true
```

O inspector permite explorar coleções, dados e índices visualmente no navegador.[8][3]

## Considerações Importantes

O Isar é uma excelente escolha para apps Flutter que necessitam de persistência local rápida, queries reativas e suporte a operações complexas sem boilerplate. Ele oferece segurança em tempo de compilação, suporte a JSON e transações assíncronas seguras.[9][2][3]

[1](https://isar.dev/pt/tutorials/quickstart.html)
[2](https://www.freecodecamp.org/news/store-data-locally-with-isar-in-flutter/)
[3](https://www.dhiwise.com/post/isar-database-flutter-guide)
[4](https://isar-community.dev/v3/pt/tutorials/quickstart.html)
[5](https://isar-community.dev/pt/tutorials/quickstart.html)
[6](https://isar-community.dev/v3/tutorials/quickstart.html)
[7](https://atuoha.hashnode.dev/implementing-isar-database-in-your-flutter-project-a-comprehensive-guide)
[8](https://www.youtube.com/watch?v=R3FvZ8L25Mw)
[9](https://quashbugs.com/blog/hive-vs-drift-vs-floor-vs-isar-2025)
[10](https://www.reddit.com/r/FlutterDev/comments/1cj5dhf/isar_database_worth_it_at_this_point/)
[11](https://www.youtube.com/watch?v=jVgQ5esp-PE)
[12](https://github.com/isar/isar)
[13](https://pub.dev/packages/isar/versions)
[14](https://isar-community.dev)
[15](https://isar.dev)
[16](https://www.youtube.com/watch?v=f4hNdtmWRZQ)
[17](https://github.com/isar/isar/pull/1546)
[18](https://greenrobot.org/database/flutter-databases-overview/)
[19](https://www.reddit.com/r/FlutterDev/comments/185qpgh/advanced_isar_database_tutorial/)
[20](https://bettercoding.dev/isar-flutter-reactive-database/)

