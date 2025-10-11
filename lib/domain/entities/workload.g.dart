// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workload.dart';

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const WorkloadSchema = Schema(
  name: r'Workload',
  id: 1323946539091367615,
  properties: {
    r'extensao': PropertySchema(
      id: 0,
      name: r'extensao',
      type: IsarType.long,
    ),
    r'pratica': PropertySchema(
      id: 1,
      name: r'pratica',
      type: IsarType.long,
    ),
    r'teorica': PropertySchema(
      id: 2,
      name: r'teorica',
      type: IsarType.long,
    ),
    r'total': PropertySchema(
      id: 3,
      name: r'total',
      type: IsarType.long,
    )
  },
  estimateSize: _workloadEstimateSize,
  serialize: _workloadSerialize,
  deserialize: _workloadDeserialize,
  deserializeProp: _workloadDeserializeProp,
);

int _workloadEstimateSize(
  Workload object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _workloadSerialize(
  Workload object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.extensao);
  writer.writeLong(offsets[1], object.pratica);
  writer.writeLong(offsets[2], object.teorica);
  writer.writeLong(offsets[3], object.total);
}

Workload _workloadDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Workload();
  object.extensao = reader.readLongOrNull(offsets[0]);
  object.pratica = reader.readLongOrNull(offsets[1]);
  object.teorica = reader.readLongOrNull(offsets[2]);
  object.total = reader.readLongOrNull(offsets[3]);
  return object;
}

P _workloadDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension WorkloadQueryFilter
    on QueryBuilder<Workload, Workload, QFilterCondition> {
  QueryBuilder<Workload, Workload, QAfterFilterCondition> extensaoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'extensao',
      ));
    });
  }

  QueryBuilder<Workload, Workload, QAfterFilterCondition> extensaoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'extensao',
      ));
    });
  }

  QueryBuilder<Workload, Workload, QAfterFilterCondition> extensaoEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'extensao',
        value: value,
      ));
    });
  }

  QueryBuilder<Workload, Workload, QAfterFilterCondition> extensaoGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'extensao',
        value: value,
      ));
    });
  }

  QueryBuilder<Workload, Workload, QAfterFilterCondition> extensaoLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'extensao',
        value: value,
      ));
    });
  }

  QueryBuilder<Workload, Workload, QAfterFilterCondition> extensaoBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'extensao',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Workload, Workload, QAfterFilterCondition> praticaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pratica',
      ));
    });
  }

  QueryBuilder<Workload, Workload, QAfterFilterCondition> praticaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pratica',
      ));
    });
  }

  QueryBuilder<Workload, Workload, QAfterFilterCondition> praticaEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pratica',
        value: value,
      ));
    });
  }

  QueryBuilder<Workload, Workload, QAfterFilterCondition> praticaGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pratica',
        value: value,
      ));
    });
  }

  QueryBuilder<Workload, Workload, QAfterFilterCondition> praticaLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pratica',
        value: value,
      ));
    });
  }

  QueryBuilder<Workload, Workload, QAfterFilterCondition> praticaBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pratica',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Workload, Workload, QAfterFilterCondition> teoricaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'teorica',
      ));
    });
  }

  QueryBuilder<Workload, Workload, QAfterFilterCondition> teoricaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'teorica',
      ));
    });
  }

  QueryBuilder<Workload, Workload, QAfterFilterCondition> teoricaEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'teorica',
        value: value,
      ));
    });
  }

  QueryBuilder<Workload, Workload, QAfterFilterCondition> teoricaGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'teorica',
        value: value,
      ));
    });
  }

  QueryBuilder<Workload, Workload, QAfterFilterCondition> teoricaLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'teorica',
        value: value,
      ));
    });
  }

  QueryBuilder<Workload, Workload, QAfterFilterCondition> teoricaBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'teorica',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Workload, Workload, QAfterFilterCondition> totalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'total',
      ));
    });
  }

  QueryBuilder<Workload, Workload, QAfterFilterCondition> totalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'total',
      ));
    });
  }

  QueryBuilder<Workload, Workload, QAfterFilterCondition> totalEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'total',
        value: value,
      ));
    });
  }

  QueryBuilder<Workload, Workload, QAfterFilterCondition> totalGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'total',
        value: value,
      ));
    });
  }

  QueryBuilder<Workload, Workload, QAfterFilterCondition> totalLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'total',
        value: value,
      ));
    });
  }

  QueryBuilder<Workload, Workload, QAfterFilterCondition> totalBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'total',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WorkloadQueryObject
    on QueryBuilder<Workload, Workload, QFilterCondition> {}
