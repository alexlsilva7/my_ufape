enum CourseType {
  obrigatorio,
  optativo,
  eletivo,
  desconhecido;

  static CourseType fromString(String type) {
    switch (type.toUpperCase()) {
      case 'OBRIGATÓRIO':
        return CourseType.obrigatorio;
      case 'OPTATIVO':
        return CourseType.optativo;
      case 'ELETIVO':
        return CourseType.eletivo;
      default:
        return CourseType.desconhecido;
    }
  }

  @override
  String toString() {
    switch (this) {
      case CourseType.obrigatorio:
        return 'Obrigatório';
      case CourseType.optativo:
        return 'Optativo';
      case CourseType.eletivo:
        return 'Eletivo';
      case CourseType.desconhecido:
        return 'Desconhecido';
    }
  }
}
