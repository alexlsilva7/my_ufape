# My UFAPE - Seu Assistente Acadêmico

<img src="assets/images/my_ufape_logo.png" alt="My UFAPE Logo" width="200"/>

**My UFAPE** é um aplicativo não oficial, construído com Flutter, projetado para oferecer aos estudantes da Universidade Federal do Agreste de Pernambuco (UFAPE) uma experiência móvel moderna e eficiente para acessar suas informações acadêmicas.

O aplicativo se integra ao portal SIGA (Sistema Integrado de Gestão de Atividades Acadêmicas), extraindo dados de forma segura e apresentando-os em uma interface nativa, rápida e intuitiva, com funcionalidades offline.

[![Flutter Version](https://img.shields.io/badge/Flutter-3.35.x-blue.svg)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Android-green.svg)](https://flutter.dev)

---

## ✨ Funcionalidades Principais

- **🎓 Histórico de Notas Detalhado:** Acompanhe seu desempenho acadêmico com todas as notas, faltas e situação em cada disciplina, agrupadas por período.
- **📅 Grade de Horário:** Visualize sua grade de horários semanal de forma clara e organizada.
- **🗺️ Perfil Curricular Completo:** Explore a estrutura do seu curso, veja todas as disciplinas (obrigatórias, optativas, eletivas), seus pré-requisitos, ementas e carga horária.
- **📈 Análise de Desempenho:** Gráficos interativos para visualizar sua evolução, média geral, taxa de aprovação, distribuição de notas e muito mais.
- **🚀 Acesso Offline:** Após a primeira sincronização, todos os seus dados acadêmicos ficam disponíveis offline, para acesso a qualquer momento.
- **🔄 Sincronização com o SIGA:** Mantenha seus dados atualizados com uma sincronização segura e em segundo plano diretamente do portal SIGA.
- **🎨 Tema Claro e Escuro:** Escolha o tema que mais lhe agrada.

---

## 📸 Screenshots

| Login                                    | Home                                 | Notas                                 |
| ---------------------------------------- | ------------------------------------ | ------------------------------------- |
| ![Login Screen Placeholder](./docs/images/login.png) | ![Home Screen Placeholder](./docs/images/home.jpeg) | ![Grades Screen Placeholder](./docs/images/notas.png) |
| **Gráficos**                               | **Perfil Curricular**                | **Grade Horária**                     |
| ![Charts Screen Placeholder](./docs/images/graficos.png) | ![Profile Screen Placeholder](./docs/images/perfil.png) | ![Timetable Screen Placeholder](./docs/images/grade.png) |

---

## 🏛️ Arquitetura e Tech Stack

Este projeto foi construído com foco em escalabilidade, manutenibilidade e boas práticas de desenvolvimento, seguindo os princípios da **Clean Architecture** e o padrão **MVVM (Model-View-ViewModel)**.

- **Arquitetura:**
  - **Camada de Domínio:** Contém as entidades, regras de negócio e contratos (interfaces) dos repositórios.
  - **Camada de Dados:** Implementa os repositórios e serviços que se comunicam com as fontes de dados (Isar e SIGA).
  - **Camada de UI (Apresentação):** Utiliza o padrão MVVM para separar a lógica de apresentação (ViewModel) da interface do usuário (View).

- **Principais Tecnologias e Pacotes:**
  - **Framework:** [Flutter](https://flutter.dev/)
  - **Banco de Dados Local:** [Isar](https://isar.dev/) (Rápido, NoSQL e otimizado para Flutter)
  - **Injeção de Dependência:** [auto_injector](https://pub.dev/packages/auto_injector)
  - **Gerenciamento de Rotas:** [routefly](https://pub.dev/packages/routefly)
  - **Tratamento de Erros:** [result_dart](https://pub.dev/packages/result_dart)
  - **Web Scraping (SIGA):** [webview_flutter](https://pub.dev/packages/webview_flutter)
  - **Visualização de Gráficos:** [fl_chart](https://pub.dev/packages/fl_chart)
  - **Armazenamento Seguro:** [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)

---

## 🚀 Como Executar o Projeto

Siga os passos abaixo para configurar e rodar o projeto localmente.

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versão 3.35.5 ou superior)

### Passos para Configuração

1.  **Clone o repositório:**
    ```bash
    git clone https://github.com/seu-usuario/my_ufape.git
    cd my_ufape
    ```

2.  **Instale as dependências:**
    ```bash
    flutter pub get
    ```

3.  **Gere os arquivos de código (Isar e Routefly):**
    Este passo é crucial e deve ser executado sempre que você alterar modelos de dados ou a estrutura de pastas das páginas.
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    dart run routefly
    ```

4.  **Execute o aplicativo em modo de desenvolvimento:**
    ```bash
    flutter run
    ```
---

## 📁 Estrutura do Projeto

A estrutura de pastas do projeto segue os princípios da Clean Architecture:

```
lib/
├── config/
│   └── dependencies.dart     # Configuração da Injeção de Dependência
├── core/
│   ├── database/             # Configuração do Isar
│   └── ui/                   # Configurações de UI (temas, etc.)
├── data/
│   ├── models/               # Modelos específicos de fontes de dados (ex: JSON)
│   ├── parsers/              # Lógica de parsing de HTML (web scraping)
│   ├── repositories/         # Implementação dos contratos do domínio
│   └── services/             # Comunicação com fontes de dados (Isar, SIGA)
├── domain/
│   ├── entities/             # Modelos de dados puros do negócio (anotados para o Isar)
│   └── repositories/         # Contratos (interfaces) dos repositórios
└── ui/
    ├── pages/                # Telas da aplicação (Views)
    ├── viewmodels/           # Lógica de apresentação e estado da UI
    └── widgets/              # Componentes de UI reutilizáveis
```

---

## 🚧 To-Do / Próximas Funcionalidades

- [ ] Notificações sobre próximas aulas.
- [ ] Implementar mais análises e gráficos de desempenho.
- [ ] Testes unitários e de widget.
- [ ] Otimizações de performance no web scraping.

---

## 🤝 Contribuições

Contribuições são bem-vindas! Se você tiver ideias, sugestões ou encontrar bugs, sinta-se à vontade para abrir uma **Issue** ou enviar um **Pull Request**.