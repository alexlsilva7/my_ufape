# Documentação do Pacote Lucid Validation para Dart/Flutter

O Lucid Validation é um pacote Dart puro para criar regras de validação fortemente tipadas, inspirado no FluentValidation. Criado pela comunidade Flutterando, oferece uma API fluida e extensível para validações tanto no frontend (com Flutter) quanto no backend. É distribuído sob a licença MIT.[1]

## Recursos

- Regras de validação fortemente tipadas.
- API fluida para definir validações.
- Extensível com validadores personalizados.
- Uso consistente em backend e frontend (Flutter).[1]

## Instalação

Execute o comando para adicionar ao seu projeto:

```
dart pub add lucid_validation
```


## Uso Básico

Crie um modelo e um validador estendendo `LucidValidator`:

```
class UserModel {
  String email;
  String password;
  int age;
  DateTime dateOfBirth;

  UserModel({
    required this.email,
    required this.password,
    required this.age,
    required this.dateOfBirth,
  });
}
```

```
import 'package:lucid_validation/lucid_validation.dart';

class UserValidator extends LucidValidator<UserModel> {
  UserValidator() {
    final now = DateTime.now();
    ruleFor((user) => user.email, key: 'email')
      .notEmpty()
      .validEmail();

    ruleFor((user) => user.password, key: 'password')
      .notEmpty()
      .minLength(8, message: 'Must be at least 8 characters long')
      .mustHaveLowercase()
      .mustHaveUppercase()
      .mustHaveNumbers()
      .mustHaveSpecialCharacter();

    ruleFor((user) => user.age, key: 'age')
      .min(18, message: 'Minimum age is 18 years');

    ruleFor((user) => user.dateOfBirth, key: 'dateOfBirth')
      .lessThan(DateTime(now.year - 18, now.month, now.day));
  }
}
```

Valide o modelo:

```
void main() {
  final user = UserModel(email: 'test@example.com', password: 'Passw0rd!', age: 25, dateOfBirth: DateTime(1990, 1, 1));
  final validator = UserValidator();
  final result = validator.validate(user);

  if (result.isValid) {
    print('User is valid');
  } else {
    print('Validation errors: ${result.exceptions.map((e) => e.message).join(', ')}');
  }
}
```

O método `validate` retorna uma lista de exceções de validação.[1]

### Validações Disponíveis

- **must**: Validação personalizada.
- **mustWith**: Validação personalizada com entidade.
- **equalTo**: Verifica igualdade.
- **greaterThan**: Verifica se é maior que um valor.
- **lessThan**: Verifica se é menor que um valor.
- **notEmpty**: Verifica se não está vazio.
- **matchesPattern**: Verifica padrão (Regex).
- **range**: Verifica intervalo numérico.
- **validEmail**: Verifica e-mail válido.
- **minLength**: Verifica comprimento mínimo.
- **maxLength**: Verifica comprimento máximo.
- **mustHaveLowercase**: Deve ter letra minúscula.
- **mustHaveUppercase**: Deve ter letra maiúscula.
- **mustHaveNumbers**: Deve ter números.
- **mustHaveSpecialCharacter**: Deve ter caractere especial.
- **min**: Verifica mínimo (numérico).
- **max**: Verifica máximo (numérico).
- **isNull**: Verifica se é nulo.
- **isNotNull**: Verifica se não é nulo.
- **isEmpty**: Verifica se está vazio.
- **validCPF**: Verifica CPF válido (Brasil).
- **validCNPJ**: Verifica CNPJ válido (Brasil).
- **validCEP**: Verifica CEP válido (Brasil).
- **validCPFOrCNPJ**: Verifica CPF ou CNPJ (Brasil).
- **validCredCard**: Verifica cartão de crédito.
- **greaterThanOrEqualTo**: Verifica data maior ou igual.
- **lessThanOrEqualTo**: Verifica data menor ou igual.
- **inclusiveBetween**: Verifica data entre valores (inclusivo).
- **exclusiveBetween**: Verifica data entre valores (exclusivo).
- **validPhoneBR**: Verifica telefone brasileiro.
- **validPhoneWithCountryCodeBR**: Verifica telefone brasileiro com DDI.
- **hasNoSequentialRepeatedCharacters**: Sem caracteres repetidos sequenciais.
- **hasNoSequentialCharacters**: Sem caracteres sequenciais.

Muitos validadores têm equivalentes com sufixo `OrNull`.[1]

## Uso com Flutter

Integre com `TextFormField` usando `byField`:

```
import 'package:flutter/material.dart';
import 'package:lucid_validation/lucid_validation.dart';

class LoginForm extends StatelessWidget {
  final validator = CredentialsValidation();
  final credentials = CredentialsModel();

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(hintText: 'Email'),
            validator: validator.byField(credentials, 'email'),
          ),
          TextFormField(
            decoration: const InputDecoration(hintText: 'Password'),
            validator: validator.byField(credentials, 'password'),
            obscureText: true,
          ),
        ],
      ),
    );
  }
}
```


## Modo Cascade

Controla a execução de regras após falhas. Modos: `continueExecution` (padrão) ou `stopOnFirstFailure`:

```
ruleFor((user) => user.password, key: 'password')
  .notEmpty()
  .minLength(8)
  .cascade(CascadeMode.stopOnFirstFailure);
```


## Condição When

Aplica regras condicionalmente:

```
ruleFor((user) => user.phoneNumber, key: 'phoneNumber')
  .when((user) => user.requiresPhoneNumber)
  .notEmpty()
  .must((value) => value.length == 10, 'Phone number must be 10 digits', 'phone_length');
```


## Validações Complexas

Use `setValidator` para objetos aninhados e `setEach` para listas, com suporte a índices em erros.[1]

## Mensagens Padrão

Mensagens em inglês por padrão. Altere a cultura para internacionalização:

```
LucidValidation.global.culture = Culture('pt', 'BR');
```

Personalize com `LanguageManager`.[1]

## Configuração no Flutter

Crie um delegate para internacionalização automática em `MaterialApp`.[1]

## Criando Regras Personalizadas

Estenda com extensões:

```
extension CustomValidPasswordValidator on SimpleValidationBuilder<String> {
  SimpleValidationBuilder<String> customValidPassword() {
    return notEmpty()
      .minLength(8)
      .mustHaveLowercase()
      .mustHaveUppercase()
      .mustHaveNumbers()
      .mustHaveSpecialCharacter();
  }
}
```


## Contribuições

Abra issues ou pull requests no repositório GitHub.[1]

[1](https://pub.dev/packages/auto_injector)
[2](https://pub.dev/packages/lucid_validation)
[3](https://pub.dev/packages/lucid_validation/versions/0.0.7)
[4](https://www.youtube.com/watch?v=F_t0r-ZcMi8)
[5](https://docs.flutter.dev/cookbook/forms/validation)
[6](https://docs.flutter.dev/release/breaking-changes/form-field-autovalidation-api)
[7](https://blog.stackademic.com/building-custom-input-fields-with-validation-flutter-b1d5e8cf123f)
[8](https://stackoverflow.com/questions/53424916/textfield-validation-in-flutter)
[9](https://www.youtube.com/watch?v=BDIm5WAjKLY)