// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_history.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSchoolHistoryCollection on Isar {
  IsarCollection<SchoolHistory> get schoolHistorys => this.collection();
}

const SchoolHistorySchema = CollectionSchema(
  name: r'SchoolHistory',
  id: -7747587019575431919,
  properties: {
    r'period': PropertySchema(
      id: 0,
      name: r'period',
      type: IsarType.string,
    ),
    r'periodAverage': PropertySchema(
      id: 1,
      name: r'periodAverage',
      type: IsarType.double,
    ),
    r'periodCoefficient': PropertySchema(
      id: 2,
      name: r'periodCoefficient',
      type: IsarType.double,
    )
  },
  estimateSize: _schoolHistoryEstimateSize,
  serialize: _schoolHistorySerialize,
  deserialize: _schoolHistoryDeserialize,
  deserializeProp: _schoolHistoryDeserializeProp,
  idName: r'id',
  indexes: {
    r'period': IndexSchema(
      id: -1253107732758621689,
      name: r'period',
      unique: true,
      replace: true,
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
  getId: _schoolHistoryGetId,
  getLinks: _schoolHistoryGetLinks,
  attach: _schoolHistoryAttach,
  version: '3.3.0',
);

int _schoolHistoryEstimateSize(
  SchoolHistory object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.period.length * 3;
  return bytesCount;
}

void _schoolHistorySerialize(
  SchoolHistory object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.period);
  writer.writeDouble(offsets[1], object.periodAverage);
  writer.writeDouble(offsets[2], object.periodCoefficient);
}

SchoolHistory _schoolHistoryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SchoolHistory(
    period: reader.readString(offsets[0]),
  );
  object.id = id;
  object.periodAverage = reader.readDoubleOrNull(offsets[1]);
  object.periodCoefficient = reader.readDoubleOrNull(offsets[2]);
  return object;
}

P _schoolHistoryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _schoolHistoryGetId(SchoolHistory object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _schoolHistoryGetLinks(SchoolHistory object) {
  return [];
}

void _schoolHistoryAttach(
    IsarCollection<dynamic> col, Id id, SchoolHistory object) {
  object.id = id;
}

extension SchoolHistoryByIndex on IsarCollection<SchoolHistory> {
  Future<SchoolHistory?> getByPeriod(String period) {
    return getByIndex(r'period', [period]);
  }

  SchoolHistory? getByPeriodSync(String period) {
    return getByIndexSync(r'period', [period]);
  }

  Future<bool> deleteByPeriod(String period) {
    return deleteByIndex(r'period', [period]);
  }

  bool deleteByPeriodSync(String period) {
    return deleteByIndexSync(r'period', [period]);
  }

  Future<List<SchoolHistory?>> getAllByPeriod(List<String> periodValues) {
    final values = periodValues.map((e) => [e]).toList();
    return getAllByIndex(r'period', values);
  }

  List<SchoolHistory?> getAllByPeriodSync(List<String> periodValues) {
    final values = periodValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'period', values);
  }

  Future<int> deleteAllByPeriod(List<String> periodValues) {
    final values = periodValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'period', values);
  }

  int deleteAllByPeriodSync(List<String> periodValues) {
    final values = periodValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'period', values);
  }

  Future<Id> putByPeriod(SchoolHistory object) {
    return putByIndex(r'period', object);
  }

  Id putByPeriodSync(SchoolHistory object, {bool saveLinks = true}) {
    return putByIndexSync(r'period', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPeriod(List<SchoolHistory> objects) {
    return putAllByIndex(r'period', objects);
  }

  List<Id> putAllByPeriodSync(List<SchoolHistory> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'period', objects, saveLinks: saveLinks);
  }
}

extension SchoolHistoryQueryWhereSort
    on QueryBuilder<SchoolHistory, SchoolHistory, QWhere> {
  QueryBuilder<SchoolHistory, SchoolHistory, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SchoolHistoryQueryWhere
    on QueryBuilder<SchoolHistory, SchoolHistory, QWhereClause> {
  QueryBuilder<SchoolHistory, SchoolHistory, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterWhereClause> idBetween(
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

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterWhereClause> periodEqualTo(
      String period) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'period',
        value: [period],
      ));
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterWhereClause>
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

extension SchoolHistoryQueryFilter
    on QueryBuilder<SchoolHistory, SchoolHistory, QFilterCondition> {
  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition>
      periodEqualTo(
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

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition>
      periodGreaterThan(
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

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition>
      periodLessThan(
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

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition>
      periodBetween(
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

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition>
      periodStartsWith(
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

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition>
      periodEndsWith(
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

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition>
      periodContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'period',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition>
      periodMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'period',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition>
      periodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'period',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition>
      periodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'period',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition>
      periodAverageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'periodAverage',
      ));
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition>
      periodAverageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'periodAverage',
      ));
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition>
      periodAverageEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'periodAverage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition>
      periodAverageGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'periodAverage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition>
      periodAverageLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'periodAverage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition>
      periodAverageBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'periodAverage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition>
      periodCoefficientIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'periodCoefficient',
      ));
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition>
      periodCoefficientIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'periodCoefficient',
      ));
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition>
      periodCoefficientEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'periodCoefficient',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition>
      periodCoefficientGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'periodCoefficient',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition>
      periodCoefficientLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'periodCoefficient',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterFilterCondition>
      periodCoefficientBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'periodCoefficient',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension SchoolHistoryQueryObject
    on QueryBuilder<SchoolHistory, SchoolHistory, QFilterCondition> {}

extension SchoolHistoryQueryLinks
    on QueryBuilder<SchoolHistory, SchoolHistory, QFilterCondition> {}

extension SchoolHistoryQuerySortBy
    on QueryBuilder<SchoolHistory, SchoolHistory, QSortBy> {
  QueryBuilder<SchoolHistory, SchoolHistory, QAfterSortBy> sortByPeriod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'period', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterSortBy> sortByPeriodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'period', Sort.desc);
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterSortBy>
      sortByPeriodAverage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodAverage', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterSortBy>
      sortByPeriodAverageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodAverage', Sort.desc);
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterSortBy>
      sortByPeriodCoefficient() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodCoefficient', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterSortBy>
      sortByPeriodCoefficientDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodCoefficient', Sort.desc);
    });
  }
}

extension SchoolHistoryQuerySortThenBy
    on QueryBuilder<SchoolHistory, SchoolHistory, QSortThenBy> {
  QueryBuilder<SchoolHistory, SchoolHistory, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterSortBy> thenByPeriod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'period', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterSortBy> thenByPeriodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'period', Sort.desc);
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterSortBy>
      thenByPeriodAverage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodAverage', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterSortBy>
      thenByPeriodAverageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodAverage', Sort.desc);
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterSortBy>
      thenByPeriodCoefficient() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodCoefficient', Sort.asc);
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QAfterSortBy>
      thenByPeriodCoefficientDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodCoefficient', Sort.desc);
    });
  }
}

extension SchoolHistoryQueryWhereDistinct
    on QueryBuilder<SchoolHistory, SchoolHistory, QDistinct> {
  QueryBuilder<SchoolHistory, SchoolHistory, QDistinct> distinctByPeriod(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'period', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QDistinct>
      distinctByPeriodAverage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'periodAverage');
    });
  }

  QueryBuilder<SchoolHistory, SchoolHistory, QDistinct>
      distinctByPeriodCoefficient() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'periodCoefficient');
    });
  }
}

extension SchoolHistoryQueryProperty
    on QueryBuilder<SchoolHistory, SchoolHistory, QQueryProperty> {
  QueryBuilder<SchoolHistory, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SchoolHistory, String, QQueryOperations> periodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'period');
    });
  }

  QueryBuilder<SchoolHistory, double?, QQueryOperations>
      periodAverageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'periodAverage');
    });
  }

  QueryBuilder<SchoolHistory, double?, QQueryOperations>
      periodCoefficientProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'periodCoefficient');
    });
  }
}
