# Guia de Implementação de Links, Índices e Watchers no Isar

Este guia completo explica como implementar relacionamentos entre objetos, otimizar queries com índices e criar aplicações reativas usando watchers no Isar Database.[1][2][3]

## Links (Relacionamentos)

Links permitem expressar relacionamentos entre objetos, modelando relações `1:1`, `1:n` e `n:n`.[4][5][1]

### IsarLink (Relacionamento 1:1)

`IsarLink<T>` contém nenhum ou um objeto relacionado :[1]

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
  final teacher = IsarLink<Teacher>();
}
```

#### Criando e Salvando Links

Links são **lazy** (preguiçosos) e devem ser carregados ou salvos explicitamente :[6][1]

```dart
// Criar teacher e atribuir ao student
final mathTeacher = Teacher()..subject = 'Math';

final linda = Student()
  ..name = 'Linda'
  ..teacher.value = mathTeacher;

await isar.writeTxn(() async {
  await isar.students.put(linda);
  await isar.teachers.put(mathTeacher);
  await linda.teacher.save(); // salvar link manualmente
});
```

#### Carregando Links

```dart
final linda = await isar.students.where()
  .nameEqualTo('Linda')
  .findFirst();

final teacher = linda.teacher.value; // -> Teacher(subject: 'Math')
```

#### Versão Síncrona

Com operações síncronas, os links são salvos automaticamente :[1]

```dart
final englishTeacher = Teacher()..subject = 'English';

final david = Student()
  ..name = 'David'
  ..teacher.value = englishTeacher;

isar.writeTxnSync(() {
  isar.students.putSync(david); // salva automaticamente o link
});
```

### IsarLinks (Relacionamento 1:N)

`IsarLinks<T>` contém múltiplos objetos relacionados e estende `Set<T>` :[4][1]

```dart
@collection
class Student {
  Id? id;
  late String name;
  final teachers = IsarLinks<Teacher>();
}
```

#### Operações com IsarLinks

```dart
// Carregar dados existentes
final linda = await isar.students.where()
  .filter()
  .nameEqualTo('Linda')
  .findFirst();

print(linda.teachers); // {Teacher('Math')}

// Adicionar novo teacher
final biologyTeacher = Teacher()..subject = 'Biology';
linda.teachers.add(biologyTeacher);

await isar.writeTxn(() async {
  await linda.teachers.save();
});

print(linda.teachers); // {Teacher('Math'), Teacher('Biology')}
```

### Backlinks (Relacionamentos Reversos)

Backlinks são links na direção inversa, sem custo adicional de memória :[6][1]

```dart
@collection
class Teacher {
  Id? id;
  late String subject;
  
  @Backlink(to: 'teachers')
  final students = IsarLinks<Student>();
}
```

O parâmetro `to` especifica o link para o qual o backlink aponta :[4][1]

```dart
// Buscar todos os estudantes de um professor
final mathTeacher = await isar.teachers.where()
  .subjectEqualTo('Math')
  .findFirst();

await mathTeacher.students.load();
print(mathTeacher.students); // {Student('Linda'), ...}
```

### Inicialização de Links

Links devem ser inicializados no construtor e é recomendado torná-los `final` :[1]

```dart
@collection
class Student {
  Id? id;
  late String name;
  
  // Boas práticas: final e inicializado
  final teachers = IsarLinks<Teacher>();
}
```

### Queries em Links

Filtre objetos baseados em relacionamentos :[1]

```dart
// Estudantes com professores de Matemática ou Inglês
final result = await isar.students.filter()
  .teachers((q) {
    return q.subjectEqualTo('Math')
      .or()
      .subjectEqualTo('English');
  }).findAll();

// Estudantes sem professores
final noTeachers = await isar.students.filter()
  .teachersLengthEqualTo(0)
  .findAll();

// Alternativa
final noTeachers2 = await isar.students.filter()
  .teachersIsEmpty()
  .findAll();
```

## Índices

Índices são fundamentais para otimizar performance de queries no Isar.[2][7][8]

### O Que São Índices?

Índices são tabelas de pesquisa ordenadas que permitem queries muito mais rápidas :[2]

```dart
@collection
class Product {
  Id? id;
  late String name;
  
  @Index()
  late int price;
}
```

Sem índice, uma query deve percorrer todos os registros linearmente.[7][2]

**Exemplo de dados não indexados:**

| id | name | price |
|---|---|---|
| 1 | Book | 15 |
| 2 | Table | 55 |
| 3 | Chair | 25 |

**Índice gerado automaticamente:**

| price | id |
|---|---|
| 15 | 1 |
| 25 | 3 |
| 55 | 2 |

### Benefícios dos Índices

#### 1. Queries Mais Rápidas

```dart
// Query que usa o índice
final expensiveProducts = await isar.products.where()
  .priceGreaterThan(30)
  .findAll();
```

#### 2. Ordenação Gratuita

Resultados já vêm ordenados pelo índice :[7][2]

```dart
// Ordenação automática pelo índice
final cheapest = await isar.products.where()
  .anyPrice()
  .limit(4)
  .findAll();
```

Muito mais eficiente que ordenar na memória :[2]

```dart
// INEFICIENTE - ordena todos os objetos na memória
final cheapestSlow = await isar.products.filter()
  .sortByPrice()
  .limit(4)
  .findAll();
```

### Índices Únicos

Garantem que não haja valores duplicados :[7][2]

```dart
@collection
class User {
  Id? id;
  
  @Index(unique: true)
  late String username;
  
  late int age;
}
```

Tentativas de inserir duplicatas resultam em erro :[2]

```dart
final user1 = User()
  ..id = 1
  ..username = 'user1'
  ..age = 25;
await isar.users.put(user1); // -> ok

final user2 = User()
  ..id = 2
  ..username = 'user1' // username duplicado
  ..age = 30;
await isar.users.put(user2); // -> erro: unique constraint violated
```

### Índices de Substituição

Use `replace: true` para substituir objetos duplicados em vez de gerar erro :[2]

```dart
@collection
class User {
  Id? id;
  
  @Index(unique: true, replace: true)
  late String username;
}
```

Comportamento :[2]

```dart
final user1 = User()..id = 1..username = 'user1'..age = 25;
await isar.users.put(user1);
// -> [{id: 1, username: 'user1', age: 25}]

final user2 = User()..id = 2..username = 'user1'..age = 30;
await isar.users.put(user2);
// -> [{id: 2, username: 'user1', age: 30}]
```

#### Método putBy

Índices de substituição geram métodos `putBy()` para atualizar objetos :[2]

```dart
final user1 = User()..username = 'user1'..age = 25;
await isar.users.putByUsername(user1); // cria novo

final user2 = User()..username = 'user1'..age = 30;
await isar.users.putByUsername(user2); // atualiza, reutiliza ID
```

### Índices Case-Insensitive

Índices de strings podem ignorar maiúsculas/minúsculas :[2]

```dart
@collection
class Person {
  Id? id;
  
  @Index(caseSensitive: false)
  late String name;
  
  @Index(caseSensitive: false)
  late List<String> tags;
}
```

### Tipos de Índices

Três tipos disponíveis para otimização :[2]

| Tipo | Uso | Vantagens |
|---|---|---|
| `IndexType.value` | Padrão para todos os tipos | Máxima flexibilidade, suporta `startsWith()` |
| `IndexType.hash` | Strings e listas hashadas | Muito menos espaço, não suporta `startsWith()` |
| `IndexType.hashElements` | Elementos de listas hashados | Índice multi-entrada eficiente |

#### IndexType.value

```dart
@collection
class Product {
  Id? id;
  
  @Index(type: IndexType.value)
  late String name;
}
```

Use para primitivos, strings com `startsWith()`, e listas com busca por elementos.[2]

#### IndexType.hash

```dart
@collection
class Product {
  Id? id;
  
  @Index(type: IndexType.hash)
  late String description;
}
```

Economiza espaço mas não permite `startsWith()`.[2]

#### IndexType.hashElements

```dart
@collection
class Product {
  Id? id;
  
  @Index(type: IndexType.hashElements)
  late List<String> tags;
}
```

### Índices Compostos

Índices em até 3 propriedades combinadas :[9][2]

```dart
@collection
class Person {
  Id? id;
  late String name;
  
  @Index(composite: [CompositeIndex('name')])
  late int age;
  
  late String hometown;
}
```

**Dados:**

| id | name | age | hometown |
|---|---|---|---|
| 1 | Daniel | 20 | Berlin |
| 2 | Anne | 20 | Paris |
| 3 | Carl | 24 | San Diego |
| 4 | Carl | 24 | London |

**Índice composto gerado:**

| age | name | id |
|---|---|---|
| 20 | Anne | 2 |
| 20 | Daniel | 1 |
| 24 | Carl | 3 |
| 24 | Carl | 4 |

#### Queries com Índices Compostos

```dart
// Query exata em ambos os campos
final result = await isar.persons.where()
  .ageNameEqualTo(24, 'Carl')
  .hometownProperty()
  .findAll(); // -> ['San Diego', 'London']

// Usar prefixo do índice
final result2 = await isar.persons.where()
  .ageEqualTo(20)
  .findAll(); // -> [Anne, Daniel]

// Condições na última propriedade
final result3 = await isar.persons.where()
  .ageEqualToNameStartsWith(20, 'Da')
  .findAll(); // -> [Daniel]
```

### Índices Multi-Entrada

Indexam cada elemento de uma lista individualmente :[2]

```dart
@collection
class Product {
  Id? id;
  late String description;
  
  @Index(type: IndexType.value, caseSensitive: false)
  List<String> get descriptionWords => Isar.splitWords(description);
}
```

`Isar.splitWords()` divide strings de acordo com Unicode Annex #29.[2]

**Dados:**

| id | description | descriptionWords |
|---|---|---|
| 1 | comfortable blue t-shirt | [comfortable, blue, t-shirt] |
| 2 | comfortable, red pullover | [comfortable, red, pullover] |
| 3 | plain red t-shirt | [plain, red, t-shirt] |

**Índice multi-entrada gerado:**

| descriptionWords | id |
|---|---|
| blue | [1] |
| comfortable | [1][2] |
| plain | [3] |
| pullover | [2] |
| red | [2][3] |
| t-shirt | [1][3] |

Query em palavras individuais :[2]

```dart
final products = await isar.products.where()
  .descriptionWordsElementStartsWith('comf')
  .findAll(); // -> [1, 2]
```

## Watchers (Observadores Reativos)

Watchers permitem reagir a mudanças no banco de dados em tempo real.[3][10][11]

### Observar Objetos Individuais

Monitore criação, atualização ou deleção de um objeto específico :[10][3]

```dart
Stream<User> userChanged = isar.users.watchObject(5);

userChanged.listen((newUser) {
  print('User changed: ${newUser?.name}');
});

final user = User(id: 5)..name = 'David';
await isar.users.put(user);
// prints: User changed: David

final user2 = User(id: 5)..name = 'Mark';
await isar.users.put(user2);
// prints: User changed: Mark

await isar.users.delete(5);
// prints: User changed: null
```

O objeto não precisa existir para ser observado.[3][10]

#### Parâmetro fireImmediately

Emita o valor atual imediatamente :[3]

```dart
Stream<User?> userChanged = isar.users.watchObject(
  5,
  fireImmediately: true,
);
```

### Lazy Watching de Objetos

Notificação sem buscar o objeto :[10][3]

```dart
Stream<void> userChanged = isar.users.watchObjectLazy(5);

userChanged.listen(() {
  print('User 5 changed');
});

final user = User(id: 5)..name = 'David';
await isar.users.put(user);
// prints: User 5 changed
```

Economiza recursos ao não buscar o objeto completo.[3]

### Observar Coleções Inteiras

Monitore qualquer mudança em uma coleção :[10][3]

```dart
Stream<void> usersChanged = isar.users.watchLazy();

usersChanged.listen(() {
  print('A User changed');
});

final user = User()..name = 'David';
await isar.users.put(user);
// prints: A User changed
```

### Observar Queries

Observe resultados de queries complexas :[10][3]

```dart
Query<User> usersWithA = isar.users.filter()
  .nameStartsWith('A')
  .build();

Stream<List<User>> queryChanged = usersWithA.watch(
  fireImmediately: true,
);

queryChanged.listen((users) {
  print('Users with A are: $users');
});

// prints: Users with A are: []

await isar.users.put(User()..name = 'Albert');
// prints: Users with A are: [User(name: Albert)]

await isar.users.put(User()..name = 'Monika');
// no print (não começa com A)

await isar.users.put(User()..name = 'Antonia');
// prints: Users with A are: [User(name: Albert), User(name: Antonia)]
```

O Isar notifica apenas quando os resultados da query realmente mudam.[3][10]

#### Lazy Watching de Queries

```dart
Query<User> usersWithA = isar.users.filter()
  .nameStartsWith('A')
  .build();

Stream<void> queryChanged = usersWithA.watchLazy();

queryChanged.listen(() {
  print('Query results changed');
});
```

### Considerações de Performance

**Importante:** Reexecutar queries a cada mudança é ineficiente :[10][3]

```dart
// INEFICIENTE - reexecuta query inteira a cada mudança
isar.users.filter()
  .ageGreaterThan(18)
  .build()
  .watch()
  .listen((users) {
    // processa todos os usuários
  });

// EFICIENTE - apenas notificação
isar.users.watchLazy().listen(() {
  // busca dados apenas quando necessário
});
```

### Watchers e Links

Watchers de queries **não** são notificados quando apenas links mudam :[3]

```dart
// Use collection watcher para mudanças em links
isar.students.watchLazy().listen(() {
  print('Student or their links changed');
});
```

## Exemplo Completo Integrando Todos os Conceitos

```dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

part 'models.g.dart';

// ========== MODELS ==========

@collection
class Course {
  Id? id;
  
  @Index(unique: true, replace: true)
  late String code;
  
  late String name;
  
  @Backlink(to: 'courses')
  final students = IsarLinks<Student>();
}

@collection
class Student {
  Id? id;
  
  @Index(unique: true)
  late String email;
  
  @Index(caseSensitive: false)
  late String name;
  
  @Index(composite: [CompositeIndex('name')])
  late int age;
  
  final courses = IsarLinks<Course>();
}

// ========== SETUP ==========

Future<Isar> setupIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return await Isar.open(
    [StudentSchema, CourseSchema],
    directory: dir.path,
  );
}

// ========== OPERATIONS ==========

class StudentRepository {
  final Isar isar;
  
  StudentRepository(this.isar);
  
  // Criar estudante com cursos
  Future<void> createStudent(
    String name,
    String email,
    int age,
    List<Course> courses,
  ) async {
    final student = Student()
      ..name = name
      ..email = email
      ..age = age;
    
    student.courses.addAll(courses);
    
    await isar.writeTxn(() async {
      await isar.students.put(student);
      await isar.courses.putAll(courses);
      await student.courses.save();
    });
  }
  
  // Buscar estudantes por idade usando índice composto
  Future<List<Student>> findStudentsByAge(int age) async {
    return await isar.students.where()
      .ageEqualTo(age)
      .findAll();
  }
  
  // Buscar por nome (case-insensitive)
  Future<List<Student>> searchByName(String query) async {
    return await isar.students.where()
      .nameStartsWith(query, caseSensitive: false)
      .findAll();
  }
  
  // Buscar estudantes de um curso específico
  Future<List<Student>> findStudentsByCourse(String courseCode) async {
    final course = await isar.courses.where()
      .codeEqualTo(courseCode)
      .findFirst();
    
    if (course == null) return [];
    
    await course.students.load();
    return course.students.toList();
  }
  
  // Observar mudanças em um estudante
  Stream<Student?> watchStudent(int id) {
    return isar.students.watchObject(id, fireImmediately: true);
  }
  
  // Observar query de estudantes maiores de idade
  Stream<List<Student>> watchAdultStudents() {
    final query = isar.students.filter()
      .ageGreaterThan(17)
      .build();
    
    return query.watch(fireImmediately: true);
  }
  
  // Observar mudanças na coleção (lazy)
  Stream<void> watchStudentChanges() {
    return isar.students.watchLazy();
  }
}

// ========== USAGE EXAMPLE ==========

void main() async {
  final isar = await setupIsar();
  final repo = StudentRepository(isar);
  
  // Criar cursos
  final mathCourse = Course()..code = 'MATH101'..name = 'Calculus';
  final csCourse = Course()..code = 'CS101'..name = 'Programming';
  
  // Criar estudante
  await repo.createStudent(
    'Alice Silva',
    'alice@example.com',
    20,
    [mathCourse, csCourse],
  );
  
  // Buscar usando índice
  final students20 = await repo.findStudentsByAge(20);
  print('Students aged 20: ${students20.length}');
  
  // Buscar por nome (case-insensitive)
  final aliceStudents = await repo.searchByName('ali');
  print('Found: ${aliceStudents.first.name}');
  
  // Observar mudanças
  repo.watchStudent(1).listen((student) {
    print('Student updated: ${student?.name}');
  });
  
  // Observar query reativa
  repo.watchAdultStudents().listen((adults) {
    print('Total adult students: ${adults.length}');
  });
  
  // Observar coleção (lazy)
  repo.watchStudentChanges().listen((_) {
    print('Student collection changed!');
  });
}
```

## Boas Práticas

### Links

1. Sempre torne propriedades de link `final`[1]
2. Use objetos embutidos quando possível para melhor performance[1]
3. Carregue links apenas quando necessário (lazy loading)[1]
4. Nunca mova um link para outro objeto[1]

### Índices

1. Índices aceleram queries mas ocupam espaço - use com moderação[7][2]
2. Use índices compostos para queries com múltiplos campos[2]
3. Prefira `IndexType.hash` para strings quando não precisar de `startsWith()`[2]
4. Use índices multi-entrada para busca textual[2]
5. Sempre teste performance com dados reais[8]

### Watchers

1. Use lazy watching quando não precisar dos dados completos[10][3]
2. Evite reexecutar queries complexas em cada mudança[3]
3. Use collection watchers para observar mudanças em links[3]
4. Sempre cancele subscriptions quando não forem mais necessárias[11]

Este guia fornece uma base completa para implementar relacionamentos complexos, otimizar performance com índices e criar aplicações reativas com watchers no Isar Database.[12][13][11]

[1](https://isar-community.dev/v3/pt/links.html)
[2](https://isar-community.dev/v3/pt/indexes.html)
[3](https://isar-community.dev/v3/pt/watchers.html)
[4](https://isar.dev/links.html)
[5](https://www.youtube.com/watch?v=14kKDmIdPPo)
[6](https://isar.dev/pt/links.html)
[7](https://isar.dev/indexes.html)
[8](https://devblogs.microsoft.com/cosmosdb/query-performance-indexing-metrics/)
[9](https://dev.to/leapcell/sql-composite-indexes-when-to-use-15k0)
[10](https://isar.dev/watchers.html)
[11](https://bettercoding.dev/isar-flutter-reactive-database/)
[12](https://www.freecodecamp.org/news/store-data-locally-with-isar-in-flutter/)
[13](https://atuoha.hashnode.dev/implementing-isar-database-in-your-flutter-project-a-comprehensive-guide)
[14](https://stackoverflow.com/questions/79207750/how-to-work-with-relations-between-collections-in-isar-flutter)
[15](https://www.reddit.com/r/FlutterDev/comments/1lwdj9s/reaxdb_a_highperformance_nosql_database_for/)
[16](https://github.com/isar/isar/discussions/71)
[17](https://isar.dev/pt/queries.html)
[18](https://www.reddit.com/r/FlutterDev/comments/185qpgh/advanced_isar_database_tutorial/)
[19](https://www.powersync.com/blog/flutter-database-comparison-sqlite-async-sqflite-objectbox-isar)
[20](https://www.youtube.com/watch?v=R3FvZ8L25Mw)
[21](https://pub.dev/documentation/isar/latest/)
[22](https://2024.sci-hub.se/7551/73c03be8af98e68f2ab9ae12678045e5/rong2019.pdf)
[23](https://isar-community.dev/v3/crud.html)
[24](https://www.sciencedirect.com/science/article/abs/pii/S1051200424001040)