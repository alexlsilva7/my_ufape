# Guia de Implementação de Schema no Isar Database

O schema no Isar define a estrutura das coleções (equivalente a tabelas) que armazenam os objetos Dart no banco de dados.[1][2]

## Anatomia de uma Coleção

### Definição Básica

Uma coleção é criada anotando uma classe com `@collection` ou `@Collection()` :[3][1]

```dart
import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id? id;
  String? firstName;
  String? lastName;
}
```

Todos os campos públicos são automaticamente persistidos no banco de dados.[4][1]

### Configurações Opcionais da Coleção

A anotação `@Collection()` aceita parâmetros de configuração :[1]

| Configuração | Descrição |
|---|---|
| `inheritance` | Controla se campos de classes pai e mixins serão armazenados (ativado por padrão) |
| `accessor` | Permite renomear o acessador padrão da coleção (ex: `isar.contacts` para a coleção `Contact`) |
| `ignore` | Permite ignorar propriedades específicas, respeitando também superclasses |

## Campo ID (Chave Primária)

### Definição do ID

Toda coleção deve ter um campo `Id` que identifica exclusivamente cada objeto :[2][1]

```dart
@collection
class User {
  Id? id; // Id é um alias para int
  String? firstName;
  String? lastName;
}
```

### Auto-incremento

O Isar pode gerar IDs automaticamente :[3][1]

```dart
@collection
class User {
  Id id = Isar.autoIncrement; // auto-incremento não-nulo
  String? firstName;
}
```

Quando o campo `id` é `null` e não-final, o Isar atribui um ID auto-incrementado.[2][1]

## Tipos de Dados Suportados

### Tipos Primitivos

O Isar suporta os seguintes tipos :[5][1]

- `bool`, `byte`, `short`, `int`, `float`, `double`
- `DateTime` (armazenado em UTC com precisão de microssegundos)
- `String`
- Listas de todos os tipos acima: `List<bool>`, `List<int>`, `List<String>`, etc.

### Tipos Numéricos Otimizados

Para economizar espaço e memória, o Isar oferece tipos numéricos menores :[1]

| Tipo | Bytes | Intervalo |
|---|---|---|
| `byte` | 1 | 0 a 255 |
| `short` | 4 | -2.147.483.647 a 2.147.483.647 |
| `int` | 8 | -9.223.372.036.854.775.807 a 9.223.372.036.854.775.807 |
| `float` | 4 | -3.4e38 a 3.4e38 |
| `double` | 8 | -1.7e308 a 1.7e308 |

Exemplo de implementação :[1]

```dart
@collection
class TestCollection {
  Id? id;
  late byte byteValue;
  short? shortValue;
  int? intValue;
  float? floatValue;
  double? doubleValue;
}
```

### Nullabilidade

Tipos numéricos não possuem representação dedicada de `null`, usando valores específicos :[1]

| Tipo | Valor para null |
|---|---|
| `short` | `-2147483648` |
| `int` | `int.MIN` |
| `float` | `double.NaN` |
| `double` | `double.NaN` |

Os tipos `bool`, `String` e `List` possuem representação separada de `null`.[2][1]

## Enums

### Estratégias de Armazenamento

O Isar oferece quatro estratégias para armazenar enums :[2][1]

| EnumType | Descrição |
|---|---|
| `ordinal` | Armazena o índice como `byte` (eficiente, mas não permite enums anuláveis) |
| `ordinal32` | Armazena o índice como `short` (4 bytes, permite nulls) |
| `name` | Armazena o nome do enum como `String` |
| `value` | Usa propriedade customizada para recuperar o valor |

### Exemplo de Implementação

```dart
@collection
class EnumCollection {
  Id? id;
  
  @enumerated // equivalente a EnumType.ordinal
  late TestEnum byteIndex; // não pode ser nullable
  
  @Enumerated(EnumType.ordinal32)
  TestEnum? shortIndex;
  
  @Enumerated(EnumType.name)
  TestEnum? name;
  
  @Enumerated(EnumType.value, 'myValue')
  TestEnum? myValue;
}

enum TestEnum {
  first(10),
  second(100),
  third(1000);
  
  const TestEnum(this.myValue);
  final short myValue;
}
```

Enums também podem ser usados em listas.[6][1]

## Objetos Embutidos (Embedded Objects)

### Definição e Uso

Objetos embutidos permitem criar estruturas aninhadas sem limites de profundidade :[7][1]

```dart
@collection
class Email {
  Id? id;
  String? title;
  Recipient? recipient;
}

@embedded
class Recipient {
  String? name;
  String? address;
}
```

### Requisitos

Objetos embutidos devem :[8][1]

- Ser anotados com `@embedded`
- Ter um construtor padrão sem parâmetros obrigatórios
- Podem ser anuláveis e herdar de outras classes

### Consultas em Objetos Embutidos

Objetos embutidos podem ser consultados eficientemente :[8]

```dart
final germanCars = await isar.cars.filter()
  .brand((q) => q
    .nameEqualTo('BMW')
    .and()
    .countryEqualTo('Germany')
  ).findAll();
```

## Renomear Coleções e Campos

Use a anotação `@Name` para customizar nomes no banco de dados :[1]

```dart
@collection
@Name("User")
class MyUserClass1 {
  @Name("id")
  Id myObjectId;
  
  @Name("firstName")
  String theFirstName;
  
  @Name("lastName")
  String familyNameOrWhatever;
}
```

Isso é especialmente útil para renomear campos sem perder dados existentes.[9][1]

## Ignorar Campos

### Usando @ignore

Campos podem ser excluídos da persistência com `@ignore` :[1]

```dart
@collection
class User {
  Id? id;
  String? firstName;
  
  @ignore
  String? password;
}
```

### Propriedade ignore da Coleção

Para classes com herança, use a propriedade `ignore` :[1]

```dart
@collection
class User {
  Image? profilePicture;
}

@Collection(ignore: {'profilePicture'})
class Member extends User {
  Id? id;
  String? firstName;
  String? lastName;
}
```

Campos de tipos não suportados pelo Isar devem ser ignorados.[5][1]

## Gerar Schema

Após definir as coleções, execute o gerador de código :[4][3]

```bash
dart run build_runner build
```

Ou para Flutter:

```bash
flutter pub run build_runner build
```

Isso criará os arquivos `*.g.dart` com os schemas necessários.[9][3]

[1](https://isar-community.dev/v3/pt/schema.html)
[2](https://isar.dev/schema.html)
[3](https://www.freecodecamp.org/news/store-data-locally-with-isar-in-flutter/)
[4](https://atuoha.hashnode.dev/implementing-isar-database-in-your-flutter-project-a-comprehensive-guide)
[5](https://www.dhiwise.com/post/isar-database-flutter-guide)
[6](https://pub.dev/documentation/isar/latest/isar/EnumType.html)
[7](https://pub.dev/documentation/isar/latest/isar/Embedded-class.html)
[8](https://isar-community.dev/v3/queries.html)
[9](https://stackoverflow.com/questions/71062256/flutter-isar-schema-is-not-defined)
[10](https://www.youtube.com/watch?v=jVgQ5esp-PE)
[11](https://pub.dev/documentation/isar/latest/isar/IndexType.html)
[12](https://isar.dev/pt/tutorials/quickstart.html)
[13](https://stackoverflow.com/questions/77495674/isar-embedded-objects-not-being-loaded)
[14](https://stackoverflow.com/questions/73903629/flutter-isar-enumerated-not-working-on-isar-3-0-0)
[15](https://github.com/isar/isar/discussions/781)
[16](https://github.com/isar/isar)
[17](https://www.youtube.com/watch?v=R3FvZ8L25Mw)
[18](https://www.dhiwise.com/post/exploring-isar-flutter-a-powerful-database-for-flutter)
[19](https://www.reddit.com/r/flutterhelp/comments/z7nl0v/isar_embedded_objects/)
[20](https://blog.stackademic.com/isar-flutter-database-a-lifesaver-for-my-project-7ab6d4f1b5ce)
[21](https://isar.dev/links.html)