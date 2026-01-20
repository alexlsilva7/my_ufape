// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_history_subject.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSchoolHistorySubjectCollection on Isar {
  IsarCollection<SchoolHistorySubject> get schoolHistorySubjects =>
      this.collection();
}

const SchoolHistorySubjectSchema = CollectionSchema(
  name: r'SchoolHistorySubject',
  id: 392177595400388220,
  properties: {
    r'absences': PropertySchema(
      id: 0,
      name: r'absences',
      type: IsarType.long,
    ),
    r'code': PropertySchema(
      id: 1,
      name: r'code',
      type: IsarType.string,
    ),
    r'credits': PropertySchema(
      id: 2,
      name: r'credits',
      type: IsarType.long,
    ),
    r'finalGrade': PropertySchema(
      id: 3,
      name: r'finalGrade',
      type: IsarType.double,
    ),
    r'name': PropertySchema(
      id: 4,
      name: r'name',
      type: IsarType.string,
    ),
    r'period': PropertySchema(
      id: 5,
      name: r'period',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 6,
      name: r'status',
      type: IsarType.string,
    ),
    r'workload': PropertySchema(
      id: 7,
      name: r'workload',
      type: IsarType.long,
    )
  },
  estimateSize: _schoolHistorySubjectEstimateSize,
  serialize: _schoolHistorySubjectSerialize,
  deserialize: _schoolHistorySubjectDeserialize,
  deserializeProp: _schoolHistorySubjectDeserializeProp,
  idName: r'id',
  indexes: {
    r'period': IndexSchema(
      id: -1253107732758621689,
      name: r'period',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'period',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _schoolHistorySubjectGetId,
  getLinks: _schoolHistorySubjectGetLinks,
  attach: _schoolHistorySubjectAttach,
  version: '3.3.0-dev.3',
);

int _schoolHistorySubjectEstimateSize(
  SchoolHistorySubject object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.code;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.name;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.period.length * 3;
  {
    final value = object.status;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _schoolHistorySubjectSerialize(
  SchoolHistorySubject object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.absences);
  writer.writeString(offsets[1], object.code);
  writer.writeLong(offsets[2], object.credits);
  writer.writeDouble(offsets[3], object.finalGrade);
  writer.writeString(offsets[4], object.name);
  writer.writeString(offsets[5], object.period);
  writer.writeString(offsets[6], object.status);
  writer.writeLong(offsets[7], object.workload);
}

SchoolHistorySubject _schoolHistorySubjectDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SchoolHistorySubject(
    period: reader.readString(offsets[5]),
  );
  object.absences = reader.readLongOrNull(offsets[0]);
  object.code = reader.readStringOrNull(offsets[1]);
  object.credits = reader.readLongOrNull(offsets[2]);
  object.finalGrade = reader.readDoubleOrNull(offsets[3]);
  object.id = id;
  object.name = reader.readStringOrNull(offsets[4]);
  object.status = reader.readStringOrNull(offsets[6]);
  object.workload = reader.readLongOrNull(offsets[7]);
  return object;
}

P _schoolHistorySubjectDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _schoolHistorySubjectGetId(SchoolHistorySubject object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _schoolHistorySubjectGetLinks(
    SchoolHistorySubject object) {
  return [];
}

void _schoolHistorySubjectAttach(
    IsarCollection<dynamic> col, Id id, SchoolHistorySubject object) {
  object.id = id;
}

extension SchoolHistorySubjectQueryWhereSort
    on QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QWhere> {
  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SchoolHistorySubjectQueryWhere
    on QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QWhereClause> {
  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterWhereClause>
      periodEqualTo(String period) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'period',
        value: [period],
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterWhereClause>
      periodNotEqualTo(String period) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'period',
              lower: [],
              upper: [period],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'period',
              lower: [period],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'period',
              lower: [period],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'period',
              lower: [],
              upper: [period],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SchoolHistorySubjectQueryFilter on QueryBuilder<SchoolHistorySubject,
    SchoolHistorySubject, QFilterCondition> {
  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> absencesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'absences',
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> absencesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'absences',
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> absencesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'absences',
        value: value,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> absencesGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'absences',
        value: value,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> absencesLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'absences',
        value: value,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> absencesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'absences',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> codeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'code',
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> codeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'code',
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> codeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> codeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> codeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> codeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'code',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> codeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> codeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
          QAfterFilterCondition>
      codeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
          QAfterFilterCondition>
      codeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'code',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> codeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'code',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> codeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'code',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> creditsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'credits',
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> creditsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'credits',
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> creditsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'credits',
        value: value,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> creditsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'credits',
        value: value,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> creditsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'credits',
        value: value,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> creditsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'credits',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> finalGradeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'finalGrade',
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> finalGradeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'finalGrade',
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> finalGradeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'finalGrade',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> finalGradeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'finalGrade',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> finalGradeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'finalGrade',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> finalGradeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'finalGrade',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> nameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> nameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> nameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> nameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
          QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
          QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> periodEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'period',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> periodGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'period',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> periodLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'period',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> periodBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'period',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> periodStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'period',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> periodEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'period',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
          QAfterFilterCondition>
      periodContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'period',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
          QAfterFilterCondition>
      periodMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'period',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> periodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'period',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> periodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'period',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> statusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'status',
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> statusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'status',
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> statusEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> statusGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> statusLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> statusBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
          QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
          QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> workloadIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'workload',
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> workloadIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'workload',
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> workloadEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'workload',
        value: value,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> workloadGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'workload',
        value: value,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> workloadLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'workload',
        value: value,
      ));
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject,
      QAfterFilterCondition> workloadBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'workload',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SchoolHistorySubjectQueryObject on QueryBuilder<SchoolHistorySubject,
    SchoolHistorySubject, QFilterCondition> {}

extension SchoolHistorySubjectQueryLinks on QueryBuilder<SchoolHistorySubject,
    SchoolHistorySubject, QFilterCondition> {}

extension SchoolHistorySubjectQuerySortBy
    on QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QSortBy> {
  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      sortByAbsences() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'absences', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      sortByAbsencesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'absences', Sort.desc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      sortByCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'code', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      sortByCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'code', Sort.desc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      sortByCredits() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credits', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      sortByCreditsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credits', Sort.desc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      sortByFinalGrade() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finalGrade', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      sortByFinalGradeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finalGrade', Sort.desc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      sortByPeriod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'period', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      sortByPeriodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'period', Sort.desc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      sortByWorkload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workload', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      sortByWorkloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workload', Sort.desc);
    });
  }
}

extension SchoolHistorySubjectQuerySortThenBy
    on QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QSortThenBy> {
  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      thenByAbsences() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'absences', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      thenByAbsencesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'absences', Sort.desc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      thenByCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'code', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      thenByCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'code', Sort.desc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      thenByCredits() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credits', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      thenByCreditsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credits', Sort.desc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      thenByFinalGrade() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finalGrade', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      thenByFinalGradeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finalGrade', Sort.desc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      thenByPeriod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'period', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      thenByPeriodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'period', Sort.desc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      thenByWorkload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workload', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QAfterSortBy>
      thenByWorkloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workload', Sort.desc);
    });
  }
}

extension SchoolHistorySubjectQueryWhereDistinct
    on QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QDistinct> {
  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QDistinct>
      distinctByAbsences() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'absences');
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QDistinct>
      distinctByCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'code', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QDistinct>
      distinctByCredits() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'credits');
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QDistinct>
      distinctByFinalGrade() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'finalGrade');
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QDistinct>
      distinctByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QDistinct>
      distinctByPeriod({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'period', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SchoolHistorySubject, SchoolHistorySubject, QDistinct>
      distinctByWorkload() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'workload');
    });
  }
}

extension SchoolHistorySubjectQueryProperty on QueryBuilder<
    SchoolHistorySubject, SchoolHistorySubject, QQueryProperty> {
  QueryBuilder<SchoolHistorySubject, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SchoolHistorySubject, int?, QQueryOperations>
      absencesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'absences');
    });
  }

  QueryBuilder<SchoolHistorySubject, String?, QQueryOperations> codeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'code');
    });
  }

  QueryBuilder<SchoolHistorySubject, int?, QQueryOperations> creditsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'credits');
    });
  }

  QueryBuilder<SchoolHistorySubject, double?, QQueryOperations>
      finalGradeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'finalGrade');
    });
  }

  QueryBuilder<SchoolHistorySubject, String?, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<SchoolHistorySubject, String, QQueryOperations>
      periodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'period');
    });
  }

  QueryBuilder<SchoolHistorySubject, String?, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<SchoolHistorySubject, int?, QQueryOperations>
      workloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'workload');
    });
  }
}
