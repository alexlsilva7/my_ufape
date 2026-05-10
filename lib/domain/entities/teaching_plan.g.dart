// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teaching_plan.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTeachingPlanCollection on Isar {
  IsarCollection<TeachingPlan> get teachingPlans => this.collection();
}

const TeachingPlanSchema = CollectionSchema(
  name: r'TeachingPlan',
  id: 733402356424074352,
  properties: {
    r'subjectCode': PropertySchema(
      id: 0,
      name: r'subjectCode',
      type: IsarType.string,
    ),
    r'topics': PropertySchema(
      id: 1,
      name: r'topics',
      type: IsarType.objectList,
      target: r'ClassTopic',
    ),
    r'uploadedAt': PropertySchema(
      id: 2,
      name: r'uploadedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _teachingPlanEstimateSize,
  serialize: _teachingPlanSerialize,
  deserialize: _teachingPlanDeserialize,
  deserializeProp: _teachingPlanDeserializeProp,
  idName: r'id',
  indexes: {
    r'subjectCode': IndexSchema(
      id: 6870012681451542085,
      name: r'subjectCode',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'subjectCode',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'ClassTopic': ClassTopicSchema},
  getId: _teachingPlanGetId,
  getLinks: _teachingPlanGetLinks,
  attach: _teachingPlanAttach,
  version: '3.3.0-dev.3',
);

int _teachingPlanEstimateSize(
  TeachingPlan object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.subjectCode.length * 3;
  bytesCount += 3 + object.topics.length * 3;
  {
    final offsets = allOffsets[ClassTopic]!;
    for (var i = 0; i < object.topics.length; i++) {
      final value = object.topics[i];
      bytesCount += ClassTopicSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _teachingPlanSerialize(
  TeachingPlan object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.subjectCode);
  writer.writeObjectList<ClassTopic>(
    offsets[1],
    allOffsets,
    ClassTopicSchema.serialize,
    object.topics,
  );
  writer.writeDateTime(offsets[2], object.uploadedAt);
}

TeachingPlan _teachingPlanDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TeachingPlan();
  object.id = id;
  object.subjectCode = reader.readString(offsets[0]);
  object.topics = reader.readObjectList<ClassTopic>(
        offsets[1],
        ClassTopicSchema.deserialize,
        allOffsets,
        ClassTopic(),
      ) ??
      [];
  object.uploadedAt = reader.readDateTime(offsets[2]);
  return object;
}

P _teachingPlanDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readObjectList<ClassTopic>(
            offset,
            ClassTopicSchema.deserialize,
            allOffsets,
            ClassTopic(),
          ) ??
          []) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _teachingPlanGetId(TeachingPlan object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _teachingPlanGetLinks(TeachingPlan object) {
  return [];
}

void _teachingPlanAttach(
    IsarCollection<dynamic> col, Id id, TeachingPlan object) {
  object.id = id;
}

extension TeachingPlanQueryWhereSort
    on QueryBuilder<TeachingPlan, TeachingPlan, QWhere> {
  QueryBuilder<TeachingPlan, TeachingPlan, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TeachingPlanQueryWhere
    on QueryBuilder<TeachingPlan, TeachingPlan, QWhereClause> {
  QueryBuilder<TeachingPlan, TeachingPlan, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterWhereClause> idBetween(
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

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterWhereClause>
      subjectCodeEqualTo(String subjectCode) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'subjectCode',
        value: [subjectCode],
      ));
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterWhereClause>
      subjectCodeNotEqualTo(String subjectCode) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectCode',
              lower: [],
              upper: [subjectCode],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectCode',
              lower: [subjectCode],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectCode',
              lower: [subjectCode],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectCode',
              lower: [],
              upper: [subjectCode],
              includeUpper: false,
            ));
      }
    });
  }
}

extension TeachingPlanQueryFilter
    on QueryBuilder<TeachingPlan, TeachingPlan, QFilterCondition> {
  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition> idBetween(
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

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition>
      subjectCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition>
      subjectCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subjectCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition>
      subjectCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subjectCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition>
      subjectCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subjectCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition>
      subjectCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subjectCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition>
      subjectCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subjectCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition>
      subjectCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition>
      subjectCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition>
      subjectCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectCode',
        value: '',
      ));
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition>
      subjectCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectCode',
        value: '',
      ));
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition>
      topicsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topics',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition>
      topicsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topics',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition>
      topicsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topics',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition>
      topicsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topics',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition>
      topicsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topics',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition>
      topicsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topics',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition>
      uploadedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uploadedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition>
      uploadedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uploadedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition>
      uploadedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uploadedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition>
      uploadedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uploadedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TeachingPlanQueryObject
    on QueryBuilder<TeachingPlan, TeachingPlan, QFilterCondition> {
  QueryBuilder<TeachingPlan, TeachingPlan, QAfterFilterCondition> topicsElement(
      FilterQuery<ClassTopic> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'topics');
    });
  }
}

extension TeachingPlanQueryLinks
    on QueryBuilder<TeachingPlan, TeachingPlan, QFilterCondition> {}

extension TeachingPlanQuerySortBy
    on QueryBuilder<TeachingPlan, TeachingPlan, QSortBy> {
  QueryBuilder<TeachingPlan, TeachingPlan, QAfterSortBy> sortBySubjectCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectCode', Sort.asc);
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterSortBy>
      sortBySubjectCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectCode', Sort.desc);
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterSortBy> sortByUploadedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadedAt', Sort.asc);
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterSortBy>
      sortByUploadedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadedAt', Sort.desc);
    });
  }
}

extension TeachingPlanQuerySortThenBy
    on QueryBuilder<TeachingPlan, TeachingPlan, QSortThenBy> {
  QueryBuilder<TeachingPlan, TeachingPlan, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterSortBy> thenBySubjectCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectCode', Sort.asc);
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterSortBy>
      thenBySubjectCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectCode', Sort.desc);
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterSortBy> thenByUploadedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadedAt', Sort.asc);
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QAfterSortBy>
      thenByUploadedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadedAt', Sort.desc);
    });
  }
}

extension TeachingPlanQueryWhereDistinct
    on QueryBuilder<TeachingPlan, TeachingPlan, QDistinct> {
  QueryBuilder<TeachingPlan, TeachingPlan, QDistinct> distinctBySubjectCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TeachingPlan, TeachingPlan, QDistinct> distinctByUploadedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uploadedAt');
    });
  }
}

extension TeachingPlanQueryProperty
    on QueryBuilder<TeachingPlan, TeachingPlan, QQueryProperty> {
  QueryBuilder<TeachingPlan, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TeachingPlan, String, QQueryOperations> subjectCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectCode');
    });
  }

  QueryBuilder<TeachingPlan, List<ClassTopic>, QQueryOperations>
      topicsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topics');
    });
  }

  QueryBuilder<TeachingPlan, DateTime, QQueryOperations> uploadedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uploadedAt');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const ClassTopicSchema = Schema(
  name: r'ClassTopic',
  id: -6046046072227219083,
  properties: {
    r'content': PropertySchema(
      id: 0,
      name: r'content',
      type: IsarType.string,
    ),
    r'date': PropertySchema(
      id: 1,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'type': PropertySchema(
      id: 2,
      name: r'type',
      type: IsarType.string,
    )
  },
  estimateSize: _classTopicEstimateSize,
  serialize: _classTopicSerialize,
  deserialize: _classTopicDeserialize,
  deserializeProp: _classTopicDeserializeProp,
);

int _classTopicEstimateSize(
  ClassTopic object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.content.length * 3;
  {
    final value = object.type;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _classTopicSerialize(
  ClassTopic object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.content);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeString(offsets[2], object.type);
}

ClassTopic _classTopicDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ClassTopic();
  object.content = reader.readString(offsets[0]);
  object.date = reader.readDateTimeOrNull(offsets[1]);
  object.type = reader.readStringOrNull(offsets[2]);
  return object;
}

P _classTopicDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension ClassTopicQueryFilter
    on QueryBuilder<ClassTopic, ClassTopic, QFilterCondition> {
  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> contentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition>
      contentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> contentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> contentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'content',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> contentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> contentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> contentContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> contentMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'content',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition>
      contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> dateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'date',
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> dateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'date',
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> dateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> dateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> dateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> dateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> typeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'type',
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> typeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'type',
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> typeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> typeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> typeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> typeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> typeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> typeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassTopic, ClassTopic, QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }
}

extension ClassTopicQueryObject
    on QueryBuilder<ClassTopic, ClassTopic, QFilterCondition> {}
