# Guia de Implementação CRUD com Isar Database

O Isar oferece operações completas de CRUD (Create, Read, Update, Delete) para manipular dados no banco de dados de forma eficiente e segura.[1][2]

## Abrindo a Instância Isar

### Configuração Básica

Antes de realizar qualquer operação, é necessário abrir uma instância do Isar :[3][1]

```dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

final dir = await getApplicationDocumentsDirectory();
final isar = await Isar.open(
  [RecipeSchema],
  directory: dir.path,
);
```

### Parâmetros de Configuração

A instância pode ser customizada com diversos parâmetros :[1]

| Configuração | Descrição |
|---|---|
| `name` | Define o nome da instância (padrão: `"default"`) |
| `directory` | Local de armazenamento do banco de dados |
| `relaxedDurability` | Reduz a garantia de durabilidade para aumentar a performance |
| `compactOnLaunch` | Define condições para compactação automática na abertura |
| `inspector` | Habilita o inspector em modo debug |

O arquivo do banco de dados será armazenado em `directory/name.isar`.[4][1]

## Operações de Leitura (Read)

### Obter Coleção

Acesse uma coleção através da instância Isar :[1]

```dart
final recipes = isar.recipes;
```

Ou usando o método genérico :[1]

```dart
final recipes = isar.collection<Recipe>();
```

### Obter Objeto por ID

Use `get()` para buscar um objeto pelo ID :[5][1]

```dart
// Assíncrono
final recipe = await isar.recipes.get(123);

// Síncrono
final recipe = isar.recipes.getSync(123);
```

O método retorna `null` se o objeto não existir.[2][1]

### Obter Múltiplos Objetos

Use `getAll()` para buscar vários objetos simultaneamente :[1]

```dart
final recipes = await isar.recipes.getAll([1, 2, 3]);
```

### Consultar Objetos com Filtros

Use `.where()` e `.filter()` para buscar objetos que atendam condições específicas :[6][1]

```dart
// Buscar todos os registros
final allRecipes = await isar.recipes.where().findAll();

// Filtrar por condição
final favorites = await isar.recipes.filter()
  .isFavoriteEqualTo(true)
  .findAll();
```

#### Condições de Filtro Disponíveis

O Isar oferece diversas condições para filtros :[6]

| Condição | Descrição |
|---|---|
| `.equalTo(value)` | Valores iguais ao especificado |
| `.between(lower, upper)` | Valores entre os limites |
| `.greaterThan(bound)` | Valores maiores que o limite |
| `.lessThan(bound)` | Valores menores que o limite |
| `.isNull()` | Valores nulos |
| `.isNotNull()` | Valores não-nulos |
| `.length()` | Filtros baseados no tamanho de listas ou strings |

Exemplo prático :[6]

```dart
isar.shoes.filter()
  .sizeLessThan(40)
  .findAll(); // -> [39, null]

isar.shoes.filter()
  .sizeBetween(39, 46, includeLower: false)
  .findAll(); // -> [40, 46]
```

## Operações de Escrita (Create, Update, Delete)

### Transações de Escrita

Todas as operações de modificação devem ser envolvidas em uma transação de escrita usando `writeTxn()` :[7][1]

```dart
await isar.writeTxn(() async {
  // operações de escrita aqui
});
```

As transações garantem consistência ACID e são automaticamente revertidas em caso de erro.[8][7]

### Inserir Objeto (Create)

Use `put()` para inserir ou atualizar objetos :[5][1]

```dart
final pancakes = Recipe()
  ..name = 'Pancakes'
  ..lastCooked = DateTime.now()
  ..isFavorite = true;

await isar.writeTxn(() async {
  await isar.recipes.put(pancakes);
});
```

Se o campo `id` for `null` ou `Isar.autoIncrement`, o Isar atribuirá um ID automaticamente.[5][1]

### Inserir Múltiplos Objetos

Use `putAll()` para inserir vários objetos de uma vez :[1]

```dart
await isar.writeTxn(() async {
  await isar.recipes.putAll([pancakes, pizza]);
});
```

### Atualizar Objeto (Update)

A atualização usa o mesmo método `put()` :[9][1]

```dart
await isar.writeTxn(() async {
  pancakes.isFavorite = false;
  await isar.recipes.put(pancakes);
});
```

Se o ID existir, o objeto é atualizado; caso contrário, é inserido.[2][1]

### Deletar Objeto (Delete)

Use `delete()` para remover um objeto pelo ID :[1]

```dart
await isar.writeTxn(() async {
  final success = await isar.recipes.delete(123);
  print('Receita apagada: $success');
});
```

O método retorna `true` se o objeto foi encontrado e deletado.[5][1]

### Deletar Múltiplos Objetos

Use `deleteAll()` para remover vários objetos :[1]

```dart
await isar.writeTxn(() async {
  final count = await isar.recipes.deleteAll([1, 2, 3]);
  print('Apagamos $count receitas');
});
```

### Deletar com Filtros

Combine queries com deleção para remover objetos baseados em condições :[1]

```dart
await isar.writeTxn(() async {
  final count = await isar.recipes.filter()
    .isFavoriteEqualTo(false)
    .deleteAll();
  print('Apagamos $count receitas');
});
```

## Boas Práticas

### Agrupamento de Operações

Agrupe múltiplas operações em uma única transação para melhor performance :[7][8]

```dart
// BOM - todas as operações em uma transação
await isar.writeTxn(() async {
  for (var contact in getContacts()) {
    await isar.contacts.put(contact);
  }
});

// RUIM - múltiplas transações
for (var contact in getContacts()) {
  await isar.writeTxn(() async {
    await isar.contacts.put(contact);
  });
}
```

### Operações Síncronas vs Assíncronas

O Isar oferece versões síncronas e assíncronas de todas as operações :[7][1]

| Tipo | Leitura | Escrita |
|---|---|---|
| Síncrona | `.txnSync()` | `.writeTxnSync()` |
| Assíncrona | `.txn()` | `.writeTxn()` |

Use operações assíncronas no isolate de UI por padrão.[7][1]

### Tratamento de Erros

Se uma operação falhar dentro de uma transação, ela é automaticamente abortada e não deve mais ser usada :[8][7]

```dart
await isar.writeTxn(() async {
  final recipe = await isar.recipes.get(123);
  recipe.isFavorite = false;
  await isar.recipes.put(recipe);
  await isar.recipes.delete(123);
});
```

## Exemplo Completo de CRUD

```dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

part 'recipe.g.dart';

@collection
class Recipe {
  Id? id;
  String? name;
  DateTime? lastCooked;
  bool? isFavorite;
}

// Inicialização
Future<Isar> setupIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return await Isar.open(
    [RecipeSchema],
    directory: dir.path,
  );
}

// CREATE
Future<void> createRecipe(Isar isar) async {
  final recipe = Recipe()
    ..name = 'Pancakes'
    ..isFavorite = true;
  
  await isar.writeTxn(() async {
    await isar.recipes.put(recipe);
  });
}

// READ
Future<Recipe?> readRecipe(Isar isar, int id) async {
  return await isar.recipes.get(id);
}

// UPDATE
Future<void> updateRecipe(Isar isar, Recipe recipe) async {
  await isar.writeTxn(() async {
    recipe.isFavorite = false;
    await isar.recipes.put(recipe);
  });
}

// DELETE
Future<void> deleteRecipe(Isar isar, int id) async {
  await isar.writeTxn(() async {
    await isar.recipes.delete(id);
  });
}
```

Este exemplo demonstra as operações básicas de CRUD com Isar de forma prática e eficiente.[10][3]

[1](https://isar-community.dev/v3/pt/crud.html)
[2](https://isar.dev/crud.html)
[3](https://www.freecodecamp.org/news/store-data-locally-with-isar-in-flutter/)
[4](https://www.dhiwise.com/post/isar-database-flutter-guide)
[5](https://isar-community.dev/v3/crud.html)
[6](https://isar.dev/queries.html)
[7](https://isar.dev/transactions.html)
[8](https://isar.dev/pt/transactions.html)
[9](https://www.dhiwise.com/post/exploring-isar-flutter-a-powerful-database-for-flutter)
[10](https://atuoha.hashnode.dev/implementing-isar-database-in-your-flutter-project-a-comprehensive-guide)
[11](https://www.youtube.com/watch?v=jVgQ5esp-PE)
[12](https://github.com/isar/isar)
[13](https://stackoverflow.com/questions/78170325/how-to-filter-with-a-query-group-using-isar-link)
[14](https://isar-community.dev/v3/tutorials/quickstart.html)
[15](https://isar.dev/recipes/full_text_search.html)
[16](https://github.com/isar/isar/discussions/655)
[17](https://www.youtube.com/watch?v=R3FvZ8L25Mw)
[18](https://docs.sentry.io/platforms/dart/guides/flutter/integrations/isar-instrumentation/)
[19](https://pub.dev/documentation/isar/latest/isar/QueryBuilder-class.html)
[20](https://pub.dev/documentation/isar/latest/)
[21](https://www.reddit.com/r/FlutterDev/comments/1jr2y7v/tutorial_how_i_built_a_query_system_in_flutter/)