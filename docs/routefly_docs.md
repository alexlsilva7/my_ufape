# Documentação do Pacote Routefly para Flutter

Routefly é um gerenciador de rotas baseado em pastas, inspirado no NextJS e criado pela comunidade Flutterando. Ele permite criar rotas automaticamente no seu aplicativo Flutter simplesmente organizando os arquivos de código em diretórios específicos.[1][2]

## Instalação e Inicialização

Para começar a usar o Routefly, siga estes passos:

- Adicione o pacote Routefly ao seu projeto Flutter:

  ```
  flutter pub add routefly
  ```

- Adicione a anotação `@Main()` ao widget principal (geralmente o que contém MaterialApp ou CupertinoApp). Use o Navigator 2.0 com o construtor `MaterialApp.router` ou `CupertinoApp.router`, configurando o `routerConfig` do Routefly.[2][1]

  Exemplo no arquivo `my_app.dart`:

  ```
  import 'package:routefly/routefly.dart';
  import 'my_app.route.dart'; // <- GERADO
  part 'my_app.g.dart'; // <- GERADO

  @Main('lib/app')
  class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return MaterialApp.router(
        routerConfig: Routefly.routerConfig(
          routes: routes, // GERADO
        ),
      );
    }
  }
  ```

  A anotação `@Main()` recebe como parâmetro a pasta base para buscar as páginas (padrão: `lib/app`).[1]

- Organize seu código criando pastas com arquivos `*_page.dart` para cada página. Exemplo de estrutura:

  ```
  .
  └── app/
      ├── product/
      │   └── product_page.dart  // Gera a rota /product
      └── user/
          └── user_page.dart     // Gera a rota /user
  ```

- Gere as rotas executando o comando:

  ```
  dart run routefly
  ```

  Execute esse comando toda vez que adicionar uma nova pasta com página. Use a flag `--watch` para gerar rotas automaticamente ao adicionar novas páginas.[3][2][1]

## Grupos de Rotas

Pastas aninhadas são mapeadas para caminhos de URL, mas você pode marcar uma pasta como um Grupo de Rota para que ela não seja incluída no caminho da URL. Crie um grupo envolvendo o nome da pasta em parênteses: `(nomeDaPasta)`.[1]

Exemplo:

```
.
└── app/
    └── (product)/
        └── home/
            └── home_page.dart  // Gera a rota /home
```

## Navegação

O Routefly oferece métodos simples de navegação:[2][3][1]

- `Routefly.navigate('path')`: Substitui toda a pilha de rotas pelo caminho solicitado.
- `Routefly.pushNavigate('path')`: Adiciona uma nova rota no topo da pilha existente.
- `Routefly.push('path')`: Adiciona uma rota à pilha.
- `Routefly.pop()`: Remove a rota do topo da pilha.
- `Routefly.replace('path')`: Substitui a última rota na pilha pelo caminho solicitado.

Use caminhos relativos ou a notação de objeto com `routePaths`.[3][1]

Exemplo:

```
// Notação de string
Routefly.navigate('/dashboard/users');

// Notação de objeto
Routefly.navigate(routePaths.dashboard.users);
```

Para rotas dinâmicas, use `changes()` para substituir parâmetros:

```
Routefly.navigate(routePaths.product.changes({'id': '1'}));
```

## Rotas Dinâmicas

Crie rotas dinâmicas usando segmentos em colchetes, como `[id]`. Exemplo: `lib/app/users/[id]/user_page.dart` gera `/users/[id]`.[2][3][1]

Navegue com: `Routefly.push('/users/2')`.

Acesse parâmetros com `Routefly.query['id']` ou `Routefly.query.params['search']` para queries.[3][1]

## Transições Personalizadas

Defina uma função `routeBuilder` na página para transições baseadas em `PageRouteBuilder`.[1][3]

Exemplo:

```
Route routeBuilder(BuildContext context, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,  // IMPORTANTE!
    pageBuilder: (_, a1, a2) => const UserPage(),
    transitionsBuilder: (_, a1, a2, child) {
      return FadeTransition(opacity: a1, child: child);
    },
  );
}
```

Para transições globais, configure no `routerConfig`.[1]

[1](https://pub.dev/packages/routefly)
[2](https://pub.dev/packages/routefly/example)
[3](https://www.youtube.com/watch?v=DmbIABioAME)
[4](https://translate.google.com/translate?u=https%3A%2F%2Fdocs.flutter.dev%2Fui%2Fnavigation&hl=pt&sl=en&tl=pt&client=srp)
[5](https://flutter.ducafecat.com/pt-br/pubs/routefly-package-info)
[6](https://pt.linkedin.com/posts/jacob-moura_eu-vou-tentar-de-novo-j%C3%A1-faz-alguns-anos-activity-7295600280929239041-CJEq)
[7](https://github.com/Flutterando/routefly/issues)
[8](https://translate.google.com/translate?u=https%3A%2F%2Fdocs.flutterflow.io%2Fresources%2Fui%2Fwidgets%2Fbuilt-in-widgets%2Fmarkdown%2F&hl=pt&sl=en&tl=pt&client=srp)
[9](https://docs.flutter.dev)