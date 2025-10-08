# Guia de Implementação de Queries e Transações no Isar

Este guia abrangente explica como implementar queries eficientes e transações seguras no Isar Database para Flutter.[1][2][3]

## Queries no Isar

O Isar oferece dois métodos principais para filtrar registros: **Filtros** e **Where Clauses**.[3][1]

### Filtros (Filters)

Os filtros avaliam expressões para cada objeto na coleção e incluem apenas aqueles que retornam `true`.[4][1]

#### Condições de Query Básicas

As condições disponíveis dependem do tipo de campo :[1]

| Condição | Descrição |
|---|---|
| `.equalTo(value)` | Valores iguais ao especificado |
| `.between(lower, upper)` | Valores entre os limites |
| `.greaterThan(bound)` | Valores maiores que o limite |
| `.lessThan(bound)` | Valores menores que o limite |
| `.isNull()` | Valores nulos |
| `.isNotNull()` | Valores não-nulos |
| `.length()` | Filtros baseados no tamanho de listas ou strings |

#### Exemplo Prático de Filtros

Considere a seguinte coleção :[1]

```dart
@collection
class Shoe {
  Id? id;
  int? size;
  late String model;
  late bool isUnisex;
}
```

Queries de exemplo :[3][1]

```dart
// Sapatos com tamanho menor que 40
isar.shoes.filter()
  .sizeLessThan(40)
  .findAll(); // -> [39, null]

// Incluindo o limite
isar.shoes.filter()
  .sizeLessThan(40, include: true)
  .findAll(); // -> [39, 40, null]

// Entre valores
isar.shoes.filter()
  .sizeBetween(39, 46, includeLower: false)
  .findAll(); // -> [40, 46]
```

### Operadores Lógicos

Combine múltiplos filtros usando operadores lógicos :[3][1]

| Operador | Descrição |
|---|---|
| `.and()` | Verdadeiro se ambas expressões forem verdadeiras |
| `.or()` | Verdadeiro se pelo menos uma expressão for verdadeira |
| `.xor()` | Verdadeiro se exatamente uma expressão for verdadeira |
| `.not()` | Nega o resultado da expressão |
| `.group()` | Agrupa condições e define ordem de avaliação |

#### Exemplos de Operadores Lógicos

```dart
// Sapatos tamanho 46 E unisex
final result = await isar.shoes.filter()
  .sizeEqualTo(46)
  .and() // Opcional - filtros são implicitamente combinados com AND
  .isUnisexEqualTo(true)
  .findAll();
```

Agrupamento de condições :[1]

```dart
// (size >= 43 AND size <= 46) AND (modelName contains 'Nike' OR isUnisex == false)
final result = await isar.shoes.filter()
  .sizeBetween(43, 46)
  .and()
  .group((q) => q
    .modelNameContains('Nike')
    .or()
    .isUnisexEqualTo(false)
  )
  .findAll();
```

Negação de condições :[1]

```dart
// size != 46 AND isUnisex != true
final result = await isar.shoes.filter()
  .not().sizeEqualTo(46)
  .and()
  .not().isUnisexEqualTo(true)
  .findAll();
```

### Condições para Strings

Strings possuem condições especiais similares a regex :[1]

| Condição | Descrição |
|---|---|
| `.startsWith(value)` | Strings que começam com o valor |
| `.contains(value)` | Strings que contêm o valor |
| `.endsWith(value)` | Strings que terminam com o valor |
| `.matches(wildcard)` | Strings que correspondem ao padrão wildcard |

Todas as operações possuem o parâmetro opcional `caseSensitive` (padrão: `true`).[3][1]

#### Wildcards

Os padrões wildcard usam caracteres especiais :[1]

- `*` - Corresponde a zero ou mais caracteres
- `?` - Corresponde a um único caractere

Exemplo: o padrão `"d?g"` corresponde a `"dog"`, `"dig"`, `"dug"`, mas não a `"ding"` ou `"dg"`.[1]

### Modificadores de Query

Modificadores permitem construir queries dinâmicas :[4][1]

| Modificador | Descrição |
|---|---|
| `.optional(cond, qb)` | Aplica a query apenas se a condição for verdadeira |
| `.anyOf(list, qb)` | Cria condições OR para cada valor da lista |
| `.allOf(list, qb)` | Cria condições AND para cada valor da lista |

#### Exemplo de Query Condicional

```dart
Future<List<Shoe>> findShoes(Id? sizeFilter) {
  return isar.shoes.filter()
    .optional(
      sizeFilter != null,
      (q) => q.sizeEqualTo(sizeFilter!),
    ).findAll();
}
```

#### Exemplo com anyOf

```dart
// Buscar sapatos de tamanhos 38, 40 ou 42
final shoes1 = await isar.shoes.filter()
  .sizeEqualTo(38)
  .or()
  .sizeEqualTo(40)
  .or()
  .sizeEqualTo(42)
  .findAll();

// Equivalente usando anyOf
final shoes2 = await isar.shoes.filter()
  .anyOf(
    [38, 40, 42],
    (q, int size) => q.sizeEqualTo(size)
  ).findAll();
```

### Queries em Listas

Filtre objetos baseados em propriedades de lista :[1]

```dart
@collection
class Tweet {
  Id? id;
  String? text;
  List<String> hashtags = [];
}
```

Exemplos de queries em listas :[1]

```dart
// Tweets sem hashtags
final tweetsWithoutHashtags = await isar.tweets.filter()
  .hashtagsIsEmpty()
  .findAll();

// Tweets com muitas hashtags
final tweetsWithManyHashtags = await isar.tweets.filter()
  .hashtagsLengthGreaterThan(5)
  .findAll();

// Tweets contendo hashtag específica
final flutterTweets = await isar.tweets.filter()
  .hashtagsElementEqualTo('flutter')
  .findAll();
```

### Objetos Embutidos (Embedded Objects)

Objetos embutidos podem ser consultados eficientemente :[4][1]

```dart
@collection
class Car {
  Id? id;
  Brand? brand;
}

@embedded
class Brand {
  String? name;
  String? country;
}
```

Query em objetos embutidos :[1]

```dart
// Carros BMW da Alemanha
final germanCars = await isar.cars.filter()
  .brand((q) => q
    .nameEqualTo('BMW')
    .and()
    .countryEqualTo('Germany')
  ).findAll();
```

Sempre agrupe queries aninhadas para melhor performance.[1]

### Queries em Links

Filtre objetos baseados em relacionamentos :[1]

```dart
@collection
class Teacher {
  Id? id;
  late String subject;
}

@collection
class Student {
  Id? id;
  late String name;
  final teachers = IsarLinks<Teacher>();
}
```

Exemplo de query com links :[1]

```dart
// Estudantes com professores de Matemática ou Inglês
final result = await isar.students.filter()
  .teachers((q) {
    return q.subjectEqualTo('Math')
      .or()
      .subjectEqualTo('English');
  }).findAll();

// Estudantes sem professores
final result = await isar.students.filter()
  .teachersLengthEqualTo(0)
  .findAll();
```

## Where Clauses (Cláusulas Where)

Where clauses usam índices definidos no schema para queries muito mais rápidas.[5][3][1]

### Definindo Índices

```dart
@collection
class Shoe {
  Id? id;
  
  @Index()
  int? size;
  
  late String model;
  
  @Index(composite: [CompositeIndex('size')])
  late bool isUnisex;
}
```

Este exemplo cria dois índices :[5][1]

1. Índice simples em `size`
2. Índice composto em `isUnisex` e `size`

### Usando Where Clauses

```dart
// Query usando índice composto - muito mais rápida
final result = await isar.shoes.where()
  .isUnisexSizeEqualTo(true, 46)
  .findAll();
```

### Índices Compostos

Índices compostos podem ter até 3 propriedades e são ordenados por todas elas :[6][5]

```dart
@collection
class Person {
  late int id;
  late String name;
  
  @Index(composite: [CompositeIndex('name')])
  late int age;
  
  late String hometown;
}
```

Query usando índice composto :[5]

```dart
// Buscar pessoas de 24 anos chamadas Carl
final result = await isar.persons.where()
  .ageNameEqualTo(24, 'Carl')
  .hometownProperty()
  .findAll(); // -> ['San Diego', 'London']

// Usar prefixos do índice
final result = await isar.persons.where()
  .ageEqualToNameStartsWith(20, 'Da')
  .findAll(); // -> [Daniel, David]
```

### Combinando Where Clauses e Filtros

Combine where clauses com filtros para máxima eficiência :[3][1]

```dart
final result = await isar.shoes.where()
  .isUnisexEqualTo(true) // where clause - usa índice
  .filter()
  .modelContains('Nike') // filter - processa apenas resultados do where
  .findAll();
```

A where clause reduz os objetos primeiro, depois o filtro processa apenas o subconjunto.[1]

## Ordenação (Sorting)

### Ordenação com Métodos Sort

Use `.sortBy()`, `.sortByDesc()`, `.thenBy()` e `.thenByDesc()` :[1]

```dart
// Ordenar por modelo e depois por tamanho
final sortedShoes = await isar.shoes.filter()
  .sortByModel()
  .thenBySizeDesc()
  .findAll();
```

Esta ordenação não usa índices e pode ser lenta para muitos resultados.[7][1]

### Ordenação com Where Clause

Queries com uma única where clause retornam resultados já ordenados pelo índice :[1]

```dart
// Resultados automaticamente ordenados por size
final bigShoes = await isar.shoes.where()
  .sizeGreaterThan(42)
  .findAll(); // -> [43, 45, 48]

// Ordem reversa
final bigShoesDesc = await isar.shoes.where(sort: Sort.desc)
  .sizeGreaterThan(42)
  .findAll(); // -> [48, 45, 43]

// Ordenar por qualquer índice usando anySize()
final shoes = await isar.shoes.where()
  .anySize()
  .findAll(); // -> [39, 40, 42, 43, 45, 48]
```

## Valores Únicos (Distinct)

### Distinct Básico

Retorne apenas valores únicos :[1]

```dart
// Modelos distintos
final shoes = await isar.shoes.filter()
  .distinctByModel()
  .findAll();

// Combinações modelo-tamanho distintas
final shoes = await isar.shoes.filter()
  .distinctByModel()
  .distinctBySize()
  .findAll();
```

### Where Clause Distinct

Use índices para operações distinct mais eficientes :[1]

```dart
final shoes = await isar.shoes.where(distinct: true)
  .anySize()
  .findAll();
```

## Offset e Limit

Pagine resultados com `offset()` e `limit()` :[1]

```dart
// Primeiros 10 sapatos
final firstTenShoes = await isar.shoes.where()
  .limit(10)
  .findAll();

// Paginação - itens 21 a 30
final page3 = await isar.shoes.where()
  .offset(20)
  .limit(10)
  .findAll();
```

## Operações de Query

Operações disponíveis além de `findAll()` :[1]

| Operação | Descrição |
|---|---|
| `.findFirst()` | Retorna apenas o primeiro objeto ou `null` |
| `.findAll()` | Retorna todos os objetos correspondentes |
| `.count()` | Conta quantos objetos correspondem |
| `.deleteFirst()` | Deleta o primeiro objeto correspondente |
| `.deleteAll()` | Deleta todos os objetos correspondentes |
| `.build()` | Compila a query para reutilização |

Exemplos :[1]

```dart
// Contar registros
final count = await isar.shoes.filter()
  .sizeEqualTo(42)
  .count();

// Deletar com query
await isar.writeTxn(() async {
  await isar.shoes.filter()
    .sizeEqualTo(42)
    .deleteAll();
});
```

## Property Queries

Selecione apenas valores de uma propriedade :[1]

```dart
List<String> models = await isar.shoes.where()
  .modelProperty()
  .findAll();

List<int> sizes = await isar.shoes.where()
  .sizeProperty()
  .findAll();
```

Economiza tempo de desserialização e funciona com objetos embutidos e listas.[1]

## Agregação

Operações de agregação disponíveis :[1]

| Operação | Descrição |
|---|---|
| `.min()` | Valor mínimo ou `null` |
| `.max()` | Valor máximo ou `null` |
| `.sum()` | Soma de todos os valores |
| `.average()` | Média de todos os valores ou `NaN` |

Exemplo:

```dart
final avgSize = await isar.shoes.where()
  .sizeProperty()
  .average();

final maxSize = await isar.shoes.where()
  .sizeProperty()
  .max();
```

## Transações no Isar

O Isar implementa transações ACID (Atomicity, Consistency, Isolation, Durability) para garantir integridade dos dados.[2][8][9]

### Propriedades ACID

As transações no Isar garantem :[9][10]

- **Atomicidade**: Todas as operações são executadas ou nenhuma é
- **Consistência**: Dados permanecem em estado válido
- **Isolamento**: Transações concorrentes não interferem entre si
- **Durabilidade**: Alterações confirmadas são persistidas

### Tipos de Transações

O Isar oferece transações síncronas e assíncronas :[8][2]

| Tipo | Leitura | Escrita |
|---|---|---|
| Síncrona | `.txnSync()` | `.writeTxnSync()` |
| Assíncrona | `.txn()` | `.writeTxn()` |

### Transações de Leitura

Transações de leitura são opcionais mas garantem snapshot consistente :[2][8]

```dart
final user = await isar.txn(() async {
  return await isar.users.get(userId);
});
```

Transações de leitura assíncronas executam em paralelo com outras transações.[8][2]

### Transações de Escrita

Todas as operações de escrita devem estar em uma transação explícita :[2][8]

```dart
await isar.writeTxn(() async {
  final user = User()
    ..name = 'John'
    ..age = 25;
  await isar.users.put(user);
});
```

Se ocorrer erro, a transação é revertida automaticamente.[8][2]

### Boas Práticas de Transações

#### Agrupar Operações

Sempre agrupe múltiplas operações em uma única transação :[2][8]

```dart
// BOM - todas as operações em uma transação
await isar.writeTxn(() async {
  for (var contact in getContacts()) {
    await isar.contacts.put(contact);
  }
});

// RUIM - múltiplas transações (muito lento)
for (var contact in getContacts()) {
  await isar.writeTxn(() async {
    await isar.contacts.put(contact);
  });
}
```

#### Minimizar Duração

Evite operações longas dentro de transações :[8][2]

```dart
// BOM
final data = await fetchDataFromAPI();
await isar.writeTxn(() async {
  await isar.items.putAll(data);
});

// RUIM - chamada de rede dentro da transação
await isar.writeTxn(() async {
  final data = await fetchDataFromAPI(); // NÃO FAÇA ISSO
  await isar.items.putAll(data);
});
```

#### Tratamento de Erros

Se uma operação falhar, a transação é abortada e não deve mais ser usada :[2][8]

```dart
try {
  await isar.writeTxn(() async {
    await isar.users.put(user);
    // Se houver erro aqui, tudo é revertido
    await isar.posts.putAll(posts);
  });
} catch (e) {
  print('Transação falhou: $e');
  // A transação já foi revertida automaticamente
}
```

## Ordem de Execução

O Isar sempre executa queries na seguinte ordem :[1]

1. Percorrer índice para encontrar objetos (where clauses)
2. Filtrar objetos (filters)
3. Ordenar resultados (sort)
4. Aplicar distinct
5. Aplicar offset e limit
6. Retornar resultados

## Exemplo Completo

```dart
import 'package:isar/isar.dart';

part 'shoe.g.dart';

@collection
class Shoe {
  Id? id;
  
  @Index()
  int? size;
  
  @Index(type: IndexType.value)
  late String model;
  
  @Index(composite: [CompositeIndex('size')])
  late bool isUnisex;
}

// Query complexa combinando where clauses, filtros e ordenação
Future<List<Shoe>> findNikeShoes(Isar isar) async {
  return await isar.shoes.where()
    .isUnisexEqualTo(true) // usa índice composto
    .filter()
    .modelContains('Nike', caseSensitive: false) // filtra resultados
    .sortBySize() // ordena
    .offset(0)
    .limit(20) // pagina
    .findAll();
}

// Transação de escrita com múltiplas operações
Future<void> addShoes(Isar isar, List<Shoe> shoes) async {
  await isar.writeTxn(() async {
    await isar.shoes.putAll(shoes);
  });
}

// Property query com agregação
Future<double> getAverageShoeSize(Isar isar) async {
  return await isar.shoes.where()
    .sizeProperty()
    .average();
}

// Query condicional com modificadores
Future<List<Shoe>> searchShoes({
  int? minSize,
  int? maxSize,
  bool? unisex,
  String? modelFilter,
}) async {
  final isar = Isar.getInstance()!;
  
  return await isar.shoes.filter()
    .optional(
      minSize != null,
      (q) => q.sizeGreaterThan(minSize! - 1),
    )
    .optional(
      maxSize != null,
      (q) => q.sizeLessThan(maxSize! + 1),
    )
    .optional(
      unisex != null,
      (q) => q.isUnisexEqualTo(unisex!),
    )
    .optional(
      modelFilter != null,
      (q) => q.modelContains(modelFilter!, caseSensitive: false),
    )
    .findAll();
}
```

Este guia cobre todos os aspectos essenciais de queries e transações no Isar, permitindo criar aplicações Flutter com operações de banco de dados eficientes, seguras e de alta performance.[11][4]

[1](https://isar-community.dev/v3/pt/queries.html)
[2](https://isar-community.dev/v3/pt/transactions.html)
[3](https://isar.dev/queries.html)
[4](https://www.dhiwise.com/post/isar-database-flutter-guide)
[5](https://isar.dev/indexes.html)
[6](https://dev.to/leapcell/sql-composite-indexes-when-to-use-15k0)
[7](https://stackoverflow.com/questions/77124109/build-dynamic-queries-with-isar)
[8](https://isar.dev/transactions.html)
[9](https://www.databricks.com/glossary/acid-transactions)
[10](https://www.mongodb.com/resources/basics/databases/acid-transactions)
[11](https://academy.droidcon.com/course/master-isar-database-in-flutter-a-powerful-nosql-local-storage-solution-for-your-flutter-apps)
[12](https://flutterdevelop.blog/en/isar_crud/)
[13](https://www.youtube.com/watch?v=jVgQ5esp-PE)
[14](https://isar.dev/faq.html)
[15](https://www.youtube.com/watch?v=oGmxzUBCYtY)
[16](https://www.dhiwise.com/post/exploring-isar-flutter-a-powerful-database-for-flutter)
[17](https://www.reddit.com/r/FlutterDev/comments/185qpgh/advanced_isar_database_tutorial/)
[18](https://itnext.io/a-minimalist-guide-to-isar-ee43c1e51a85)
[19](https://github.com/isar/isar)
[20](https://blog.algomaster.io/p/what-are-acid-transactions-in-databases)
[21](https://github.com/isar/isar/discussions/371)
[22](https://github.com/isar/isar/discussions/655)