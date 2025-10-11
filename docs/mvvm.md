# Guia de Arquitetura de Software para Projetos Flutter

Este documento descreve uma arquitetura de software escalável e manutenível para projetos Flutter, baseada nos princípios da **Clean Architecture** e no padrão **MVVM (Model-View-ViewModel)** para a camada de apresentação.

## Filosofia Principal

A arquitetura é dividida em camadas com responsabilidades bem definidas. A regra fundamental é a **Direção da Dependência**: as camadas mais internas (Domínio) não devem conhecer as camadas mais externas (Dados, UI). Isso garante que a lógica de negócio seja independente de detalhes de implementação, como o banco de dados utilizado ou o framework de interface.

## Estrutura das Camadas

O projeto é organizado em três camadas principais:

1.  **Camada de Domínio (`lib/domain`)**
2.  **Camada de Dados (`lib/data`)**
3.  **Camada de Apresentação/UI (`lib/presentation` ou `lib/ui`)**

---

### 1. Camada de Domínio (`lib/domain`)

Esta é a camada central e mais importante da aplicação. Ela contém as regras de negócio e é totalmente agnóstica a qualquer tecnologia externa.

*   **`entities`**: Contém os modelos de dados puros do seu negócio (ex: `Product`, `Order`, `UserProfile`). São classes Dart simples que representam os conceitos fundamentais da sua aplicação.

*   **`repositories` (Interfaces/Contratos)**: Define as abstrações (`abstract class`) para o acesso a dados. O domínio dita *o que* a aplicação precisa fazer (ex: "buscar um produto por ID"), mas não se importa com *como* isso será feito (seja de um banco de dados local ou de uma API REST).

*   **`usecases` (ou `interactors`)**: Encapsula uma única regra de negócio ou caso de uso do sistema (ex: `LoginUserUseCase`, `CheckoutCartUseCase`). Os casos de uso orquestram a lógica, utilizando os repositórios para obter ou manipular os dados necessários.

*   **`validators`**: Classes responsáveis por validar as entidades de acordo com as regras de negócio. Por exemplo, um `UserValidator` pode verificar se uma senha atende aos critérios de segurança.

---

### 2. Camada de Dados (`lib/data`)

Esta camada é responsável pela implementação concreta do acesso a dados. Ela implementa os contratos definidos na camada de Domínio.

*   **`repositories` (Implementações)**: Classes concretas que implementam as interfaces de repositório da camada de Domínio. Elas atuam como um intermediário, decidindo de qual fonte de dados obter as informações.

*   **`datasources` (ou `services`)**: Classes que interagem diretamente com uma fonte de dados específica. É comum dividi-las em:
    *   **`local`**: Para comunicação com bancos de dados locais (Isar, Hive, SQLite).
    *   **`remote`**: Para comunicação com fontes externas, como APIs REST ou Firebase.

*   **`models`**: Representações dos dados que são específicas da fonte de dados (ex: classes que sabem como se converter de/para JSON). Muitas vezes, um `Model` na camada de dados é convertido para uma `Entity` da camada de Domínio antes de ser entregue às camadas superiores.

---

### 3. Camada de Apresentação/UI (`lib/presentation` ou `lib/ui`)

Esta é a camada responsável por exibir a interface gráfica e capturar as interações do usuário. Ela utiliza o padrão **MVVM**.

*   **`pages` (ou `views`)**: Widgets que representam as telas da aplicação. Devem ser "burros", ou seja, sua única responsabilidade é exibir o estado fornecido pelo `ViewModel` e notificar o `ViewModel` sobre as ações do usuário.

*   **`viewmodels`**: Classes que contêm o estado da UI e a lógica de apresentação. Elas se comunicam com a camada de Domínio (geralmente através de `usecases` ou `repositories`) para obter e processar dados. A View "escuta" as mudanças no ViewModel e se reconstrói quando o estado é alterado.

*   **`widgets`**: Componentes de UI reutilizáveis que podem ser usados em várias telas (ex: `CustomButton`, `LogoWidget`).

---

### Fluxo de Dados Típico

Um fluxo de interação comum segue os seguintes passos:

1.  Um evento ocorre na **View** (ex: usuário clica em um botão).
2.  A View chama um método no **ViewModel**.
3.  O ViewModel executa a lógica de apresentação e chama um **UseCase** (ou Repositório) da camada de Domínio.
4.  O UseCase/Repositório (contrato no Domínio) é resolvido pela sua implementação na camada de **Dados**.
5.  O Repositório (implementação) solicita os dados ao **Datasource** apropriado (local ou remoto).
6.  O Datasource obtém os dados e os retorna.
7.  Os dados fluem de volta pela mesma cadeia: `Datasource` -> `Repository` -> `UseCase` -> `ViewModel`.
8.  O **ViewModel** atualiza seu estado com os novos dados e notifica a **View**.
9.  A View se reconstrói para exibir o novo estado ao usuário.

---

### Pacotes Essenciais para a Arquitetura

*   **Injeção de Dependência (`auto_injector` ou `get_it`)**:
    *   **Função:** Gerencia a criação e o fornecimento de instâncias (ViewModels, Repositories), desacoplando as camadas. Permite que uma classe receba suas dependências sem precisar criá-las.

*   **Gerenciamento de Rotas (`routefly` ou `go_router`)**:
    *   **Função:** Centraliza e gerencia a navegação do aplicativo. Soluções baseadas em geração de código (como `routefly`) oferecem navegação com tipagem forte, evitando erros.

*   **Tratamento de Erros (`result_dart` e `result_command`)**:
    *   **Função:** Implementa o tipo `Result` um tratamento de erros explícito e funcional. Evita exceções não capturadas e torna o código mais robusto, forçando o tratamento de cenários de sucesso e falha.

*   **Banco de Dados Local (`isar` ou `hive`)**:
    *   **Função:** Fornece uma solução de persistência de dados rápida e eficiente no dispositivo, sendo a base para a `local_datasource`.

*   **Armazenamento Seguro (`flutter_secure_storage`)**:
    *   **Função:** Essencial para armazenar dados sensíveis como tokens de autenticação, chaves de API ou informações do usuário que não devem ser expostas.

*   **Armazenamento Simples (`shared_preferences`)**:
    *   **Função:** Perfeito para salvar configurações simples do usuário, como a preferência de tema (claro/escuro) ou flags de configuração.

*   **Validação (`lucid_validation`)**:
    *   **Função:** Permite definir regras de validação para as entidades do domínio de forma declarativa e centralizada, mantendo a lógica de negócio limpa e reutilizável.