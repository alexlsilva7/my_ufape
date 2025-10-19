// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academic_achievement.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAcademicAchievementCollection on Isar {
  IsarCollection<AcademicAchievement> get academicAchievements =>
      this.collection();
}

const AcademicAchievementSchema = CollectionSchema(
  name: r'AcademicAchievement',
  id: -7570731493015278759,
  properties: {
    r'componentSummary': PropertySchema(
      id: 0,
      name: r'componentSummary',
      type: IsarType.objectList,
      target: r'ComponentSummaryItem',
    ),
    r'pendingSubjects': PropertySchema(
      id: 1,
      name: r'pendingSubjects',
      type: IsarType.objectList,
      target: r'PendingSubject',
    ),
    r'totalPendingHours': PropertySchema(
      id: 2,
      name: r'totalPendingHours',
      type: IsarType.long,
    ),
    r'workloadSummary': PropertySchema(
      id: 3,
      name: r'workloadSummary',
      type: IsarType.objectList,
      target: r'WorkloadSummaryItem',
    )
  },
  estimateSize: _academicAchievementEstimateSize,
  serialize: _academicAchievementSerialize,
  deserialize: _academicAchievementDeserialize,
  deserializeProp: _academicAchievementDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {
    r'WorkloadSummaryItem': WorkloadSummaryItemSchema,
    r'ComponentSummaryItem': ComponentSummaryItemSchema,
    r'PendingSubject': PendingSubjectSchema
  },
  getId: _academicAchievementGetId,
  getLinks: _academicAchievementGetLinks,
  attach: _academicAchievementAttach,
  version: '3.3.0-dev.3',
);

int _academicAchievementEstimateSize(
  AcademicAchievement object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.componentSummary.length * 3;
  {
    final offsets = allOffsets[ComponentSummaryItem]!;
    for (var i = 0; i < object.componentSummary.length; i++) {
      final value = object.componentSummary[i];
      bytesCount +=
          ComponentSummaryItemSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.pendingSubjects.length * 3;
  {
    final offsets = allOffsets[PendingSubject]!;
    for (var i = 0; i < object.pendingSubjects.length; i++) {
      final value = object.pendingSubjects[i];
      bytesCount +=
          PendingSubjectSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.workloadSummary.length * 3;
  {
    final offsets = allOffsets[WorkloadSummaryItem]!;
    for (var i = 0; i < object.workloadSummary.length; i++) {
      final value = object.workloadSummary[i];
      bytesCount +=
          WorkloadSummaryItemSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _academicAchievementSerialize(
  AcademicAchievement object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<ComponentSummaryItem>(
    offsets[0],
    allOffsets,
    ComponentSummaryItemSchema.serialize,
    object.componentSummary,
  );
  writer.writeObjectList<PendingSubject>(
    offsets[1],
    allOffsets,
    PendingSubjectSchema.serialize,
    object.pendingSubjects,
  );
  writer.writeLong(offsets[2], object.totalPendingHours);
  writer.writeObjectList<WorkloadSummaryItem>(
    offsets[3],
    allOffsets,
    WorkloadSummaryItemSchema.serialize,
    object.workloadSummary,
  );
}

AcademicAchievement _academicAchievementDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AcademicAchievement();
  object.componentSummary = reader.readObjectList<ComponentSummaryItem>(
        offsets[0],
        ComponentSummaryItemSchema.deserialize,
        allOffsets,
        ComponentSummaryItem(),
      ) ??
      [];
  object.id = id;
  object.pendingSubjects = reader.readObjectList<PendingSubject>(
        offsets[1],
        PendingSubjectSchema.deserialize,
        allOffsets,
        PendingSubject(),
      ) ??
      [];
  object.totalPendingHours = reader.readLongOrNull(offsets[2]);
  object.workloadSummary = reader.readObjectList<WorkloadSummaryItem>(
        offsets[3],
        WorkloadSummaryItemSchema.deserialize,
        allOffsets,
        WorkloadSummaryItem(),
      ) ??
      [];
  return object;
}

P _academicAchievementDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<ComponentSummaryItem>(
            offset,
            ComponentSummaryItemSchema.deserialize,
            allOffsets,
            ComponentSummaryItem(),
          ) ??
          []) as P;
    case 1:
      return (reader.readObjectList<PendingSubject>(
            offset,
            PendingSubjectSchema.deserialize,
            allOffsets,
            PendingSubject(),
          ) ??
          []) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readObjectList<WorkloadSummaryItem>(
            offset,
            WorkloadSummaryItemSchema.deserialize,
            allOffsets,
            WorkloadSummaryItem(),
          ) ??
          []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _academicAchievementGetId(AcademicAchievement object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _academicAchievementGetLinks(
    AcademicAchievement object) {
  return [];
}

void _academicAchievementAttach(
    IsarCollection<dynamic> col, Id id, AcademicAchievement object) {
  object.id = id;
}

extension AcademicAchievementQueryWhereSort
    on QueryBuilder<AcademicAchievement, AcademicAchievement, QWhere> {
  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AcademicAchievementQueryWhere
    on QueryBuilder<AcademicAchievement, AcademicAchievement, QWhereClause> {
  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterWhereClause>
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

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterWhereClause>
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
}

extension AcademicAchievementQueryFilter on QueryBuilder<AcademicAchievement,
    AcademicAchievement, QFilterCondition> {
  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      componentSummaryLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'componentSummary',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      componentSummaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'componentSummary',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      componentSummaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'componentSummary',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      componentSummaryLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'componentSummary',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      componentSummaryLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'componentSummary',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      componentSummaryLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'componentSummary',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
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

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      pendingSubjectsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pendingSubjects',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      pendingSubjectsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pendingSubjects',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      pendingSubjectsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pendingSubjects',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      pendingSubjectsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pendingSubjects',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      pendingSubjectsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pendingSubjects',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      pendingSubjectsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pendingSubjects',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      totalPendingHoursIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalPendingHours',
      ));
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      totalPendingHoursIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalPendingHours',
      ));
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      totalPendingHoursEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalPendingHours',
        value: value,
      ));
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      totalPendingHoursGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalPendingHours',
        value: value,
      ));
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      totalPendingHoursLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalPendingHours',
        value: value,
      ));
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      totalPendingHoursBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalPendingHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      workloadSummaryLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'workloadSummary',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      workloadSummaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'workloadSummary',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      workloadSummaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'workloadSummary',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      workloadSummaryLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'workloadSummary',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      workloadSummaryLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'workloadSummary',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      workloadSummaryLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'workloadSummary',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension AcademicAchievementQueryObject on QueryBuilder<AcademicAchievement,
    AcademicAchievement, QFilterCondition> {
  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      componentSummaryElement(FilterQuery<ComponentSummaryItem> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'componentSummary');
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      pendingSubjectsElement(FilterQuery<PendingSubject> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'pendingSubjects');
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterFilterCondition>
      workloadSummaryElement(FilterQuery<WorkloadSummaryItem> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'workloadSummary');
    });
  }
}

extension AcademicAchievementQueryLinks on QueryBuilder<AcademicAchievement,
    AcademicAchievement, QFilterCondition> {}

extension AcademicAchievementQuerySortBy
    on QueryBuilder<AcademicAchievement, AcademicAchievement, QSortBy> {
  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterSortBy>
      sortByTotalPendingHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPendingHours', Sort.asc);
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterSortBy>
      sortByTotalPendingHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPendingHours', Sort.desc);
    });
  }
}

extension AcademicAchievementQuerySortThenBy
    on QueryBuilder<AcademicAchievement, AcademicAchievement, QSortThenBy> {
  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterSortBy>
      thenByTotalPendingHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPendingHours', Sort.asc);
    });
  }

  QueryBuilder<AcademicAchievement, AcademicAchievement, QAfterSortBy>
      thenByTotalPendingHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPendingHours', Sort.desc);
    });
  }
}

extension AcademicAchievementQueryWhereDistinct
    on QueryBuilder<AcademicAchievement, AcademicAchievement, QDistinct> {
  QueryBuilder<AcademicAchievement, AcademicAchievement, QDistinct>
      distinctByTotalPendingHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalPendingHours');
    });
  }
}

extension AcademicAchievementQueryProperty
    on QueryBuilder<AcademicAchievement, AcademicAchievement, QQueryProperty> {
  QueryBuilder<AcademicAchievement, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AcademicAchievement, List<ComponentSummaryItem>,
      QQueryOperations> componentSummaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'componentSummary');
    });
  }

  QueryBuilder<AcademicAchievement, List<PendingSubject>, QQueryOperations>
      pendingSubjectsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendingSubjects');
    });
  }

  QueryBuilder<AcademicAchievement, int?, QQueryOperations>
      totalPendingHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalPendingHours');
    });
  }

  QueryBuilder<AcademicAchievement, List<WorkloadSummaryItem>, QQueryOperations>
      workloadSummaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'workloadSummary');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const WorkloadSummaryItemSchema = Schema(
  name: r'WorkloadSummaryItem',
  id: 6503986168714521940,
  properties: {
    r'category': PropertySchema(
      id: 0,
      name: r'category',
      type: IsarType.string,
    ),
    r'children': PropertySchema(
      id: 1,
      name: r'children',
      type: IsarType.objectList,
      target: r'WorkloadSummaryItem',
    ),
    r'completedHours': PropertySchema(
      id: 2,
      name: r'completedHours',
      type: IsarType.long,
    ),
    r'completedPercentage': PropertySchema(
      id: 3,
      name: r'completedPercentage',
      type: IsarType.double,
    ),
    r'integration': PropertySchema(
      id: 4,
      name: r'integration',
      type: IsarType.long,
    ),
    r'name': PropertySchema(
      id: 5,
      name: r'name',
      type: IsarType.string,
    ),
    r'toCompleteHours': PropertySchema(
      id: 6,
      name: r'toCompleteHours',
      type: IsarType.long,
    ),
    r'toCompletePercentage': PropertySchema(
      id: 7,
      name: r'toCompletePercentage',
      type: IsarType.double,
    ),
    r'waivedHours': PropertySchema(
      id: 8,
      name: r'waivedHours',
      type: IsarType.long,
    ),
    r'waivedPercentage': PropertySchema(
      id: 9,
      name: r'waivedPercentage',
      type: IsarType.double,
    )
  },
  estimateSize: _workloadSummaryItemEstimateSize,
  serialize: _workloadSummaryItemSerialize,
  deserialize: _workloadSummaryItemDeserialize,
  deserializeProp: _workloadSummaryItemDeserializeProp,
);

int _workloadSummaryItemEstimateSize(
  WorkloadSummaryItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.category;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.children.length * 3;
  {
    final offsets = allOffsets[WorkloadSummaryItem]!;
    for (var i = 0; i < object.children.length; i++) {
      final value = object.children[i];
      bytesCount +=
          WorkloadSummaryItemSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  {
    final value = object.name;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _workloadSummaryItemSerialize(
  WorkloadSummaryItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.category);
  writer.writeObjectList<WorkloadSummaryItem>(
    offsets[1],
    allOffsets,
    WorkloadSummaryItemSchema.serialize,
    object.children,
  );
  writer.writeLong(offsets[2], object.completedHours);
  writer.writeDouble(offsets[3], object.completedPercentage);
  writer.writeLong(offsets[4], object.integration);
  writer.writeString(offsets[5], object.name);
  writer.writeLong(offsets[6], object.toCompleteHours);
  writer.writeDouble(offsets[7], object.toCompletePercentage);
  writer.writeLong(offsets[8], object.waivedHours);
  writer.writeDouble(offsets[9], object.waivedPercentage);
}

WorkloadSummaryItem _workloadSummaryItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WorkloadSummaryItem();
  object.category = reader.readStringOrNull(offsets[0]);
  object.children = reader.readObjectList<WorkloadSummaryItem>(
        offsets[1],
        WorkloadSummaryItemSchema.deserialize,
        allOffsets,
        WorkloadSummaryItem(),
      ) ??
      [];
  object.completedHours = reader.readLongOrNull(offsets[2]);
  object.completedPercentage = reader.readDoubleOrNull(offsets[3]);
  object.integration = reader.readLongOrNull(offsets[4]);
  object.name = reader.readStringOrNull(offsets[5]);
  object.toCompleteHours = reader.readLongOrNull(offsets[6]);
  object.toCompletePercentage = reader.readDoubleOrNull(offsets[7]);
  object.waivedHours = reader.readLongOrNull(offsets[8]);
  object.waivedPercentage = reader.readDoubleOrNull(offsets[9]);
  return object;
}

P _workloadSummaryItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readObjectList<WorkloadSummaryItem>(
            offset,
            WorkloadSummaryItemSchema.deserialize,
            allOffsets,
            WorkloadSummaryItem(),
          ) ??
          []) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension WorkloadSummaryItemQueryFilter on QueryBuilder<WorkloadSummaryItem,
    WorkloadSummaryItem, QFilterCondition> {
  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      categoryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'category',
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      categoryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'category',
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      categoryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      categoryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      categoryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      categoryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      categoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      categoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      childrenLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'children',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      childrenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'children',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      childrenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'children',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      childrenLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'children',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      childrenLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'children',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      childrenLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'children',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      completedHoursIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completedHours',
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      completedHoursIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completedHours',
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      completedHoursEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedHours',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      completedHoursGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedHours',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      completedHoursLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedHours',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      completedHoursBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      completedPercentageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completedPercentage',
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      completedPercentageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completedPercentage',
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      completedPercentageEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      completedPercentageGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      completedPercentageLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      completedPercentageBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedPercentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      integrationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'integration',
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      integrationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'integration',
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      integrationEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'integration',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      integrationGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'integration',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      integrationLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'integration',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      integrationBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'integration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      nameEqualTo(
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

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      nameGreaterThan(
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

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      nameLessThan(
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

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      nameBetween(
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

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      nameStartsWith(
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

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      nameEndsWith(
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

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      toCompleteHoursIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'toCompleteHours',
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      toCompleteHoursIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'toCompleteHours',
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      toCompleteHoursEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toCompleteHours',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      toCompleteHoursGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'toCompleteHours',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      toCompleteHoursLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'toCompleteHours',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      toCompleteHoursBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'toCompleteHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      toCompletePercentageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'toCompletePercentage',
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      toCompletePercentageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'toCompletePercentage',
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      toCompletePercentageEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toCompletePercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      toCompletePercentageGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'toCompletePercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      toCompletePercentageLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'toCompletePercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      toCompletePercentageBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'toCompletePercentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      waivedHoursIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'waivedHours',
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      waivedHoursIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'waivedHours',
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      waivedHoursEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'waivedHours',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      waivedHoursGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'waivedHours',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      waivedHoursLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'waivedHours',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      waivedHoursBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'waivedHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      waivedPercentageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'waivedPercentage',
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      waivedPercentageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'waivedPercentage',
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      waivedPercentageEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'waivedPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      waivedPercentageGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'waivedPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      waivedPercentageLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'waivedPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      waivedPercentageBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'waivedPercentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension WorkloadSummaryItemQueryObject on QueryBuilder<WorkloadSummaryItem,
    WorkloadSummaryItem, QFilterCondition> {
  QueryBuilder<WorkloadSummaryItem, WorkloadSummaryItem, QAfterFilterCondition>
      childrenElement(FilterQuery<WorkloadSummaryItem> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'children');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const ComponentSummaryItemSchema = Schema(
  name: r'ComponentSummaryItem',
  id: -4055716193077317366,
  properties: {
    r'category': PropertySchema(
      id: 0,
      name: r'category',
      type: IsarType.string,
    ),
    r'description': PropertySchema(
      id: 1,
      name: r'description',
      type: IsarType.string,
    ),
    r'hours': PropertySchema(
      id: 2,
      name: r'hours',
      type: IsarType.long,
    ),
    r'quantity': PropertySchema(
      id: 3,
      name: r'quantity',
      type: IsarType.long,
    )
  },
  estimateSize: _componentSummaryItemEstimateSize,
  serialize: _componentSummaryItemSerialize,
  deserialize: _componentSummaryItemDeserialize,
  deserializeProp: _componentSummaryItemDeserializeProp,
);

int _componentSummaryItemEstimateSize(
  ComponentSummaryItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.category;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _componentSummaryItemSerialize(
  ComponentSummaryItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.category);
  writer.writeString(offsets[1], object.description);
  writer.writeLong(offsets[2], object.hours);
  writer.writeLong(offsets[3], object.quantity);
}

ComponentSummaryItem _componentSummaryItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ComponentSummaryItem();
  object.category = reader.readStringOrNull(offsets[0]);
  object.description = reader.readStringOrNull(offsets[1]);
  object.hours = reader.readLongOrNull(offsets[2]);
  object.quantity = reader.readLongOrNull(offsets[3]);
  return object;
}

P _componentSummaryItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension ComponentSummaryItemQueryFilter on QueryBuilder<ComponentSummaryItem,
    ComponentSummaryItem, QFilterCondition> {
  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> categoryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'category',
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> categoryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'category',
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> categoryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> categoryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> categoryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> categoryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
          QAfterFilterCondition>
      categoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
          QAfterFilterCondition>
      categoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
          QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
          QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> hoursIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'hours',
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> hoursIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'hours',
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> hoursEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hours',
        value: value,
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> hoursGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hours',
        value: value,
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> hoursLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hours',
        value: value,
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> hoursBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> quantityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'quantity',
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> quantityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'quantity',
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> quantityEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> quantityGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> quantityLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<ComponentSummaryItem, ComponentSummaryItem,
      QAfterFilterCondition> quantityBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ComponentSummaryItemQueryObject on QueryBuilder<ComponentSummaryItem,
    ComponentSummaryItem, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const PendingSubjectSchema = Schema(
  name: r'PendingSubject',
  id: -7571293072780321489,
  properties: {
    r'code': PropertySchema(
      id: 0,
      name: r'code',
      type: IsarType.string,
    ),
    r'credits': PropertySchema(
      id: 1,
      name: r'credits',
      type: IsarType.long,
    ),
    r'name': PropertySchema(
      id: 2,
      name: r'name',
      type: IsarType.string,
    ),
    r'period': PropertySchema(
      id: 3,
      name: r'period',
      type: IsarType.long,
    ),
    r'workload': PropertySchema(
      id: 4,
      name: r'workload',
      type: IsarType.long,
    )
  },
  estimateSize: _pendingSubjectEstimateSize,
  serialize: _pendingSubjectSerialize,
  deserialize: _pendingSubjectDeserialize,
  deserializeProp: _pendingSubjectDeserializeProp,
);

int _pendingSubjectEstimateSize(
  PendingSubject object,
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
  return bytesCount;
}

void _pendingSubjectSerialize(
  PendingSubject object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.code);
  writer.writeLong(offsets[1], object.credits);
  writer.writeString(offsets[2], object.name);
  writer.writeLong(offsets[3], object.period);
  writer.writeLong(offsets[4], object.workload);
}

PendingSubject _pendingSubjectDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PendingSubject();
  object.code = reader.readStringOrNull(offsets[0]);
  object.credits = reader.readLongOrNull(offsets[1]);
  object.name = reader.readStringOrNull(offsets[2]);
  object.period = reader.readLongOrNull(offsets[3]);
  object.workload = reader.readLongOrNull(offsets[4]);
  return object;
}

P _pendingSubjectDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension PendingSubjectQueryFilter
    on QueryBuilder<PendingSubject, PendingSubject, QFilterCondition> {
  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      codeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'code',
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      codeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'code',
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      codeEqualTo(
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

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      codeGreaterThan(
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

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      codeLessThan(
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

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      codeBetween(
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

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      codeStartsWith(
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

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      codeEndsWith(
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

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      codeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      codeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'code',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      codeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'code',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      codeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'code',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      creditsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'credits',
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      creditsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'credits',
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      creditsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'credits',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      creditsGreaterThan(
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

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      creditsLessThan(
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

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      creditsBetween(
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

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      nameEqualTo(
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

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      nameGreaterThan(
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

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      nameLessThan(
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

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      nameBetween(
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

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      nameStartsWith(
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

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      nameEndsWith(
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

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      periodIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'period',
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      periodIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'period',
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      periodEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'period',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      periodGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'period',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      periodLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'period',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      periodBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'period',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      workloadIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'workload',
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      workloadIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'workload',
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      workloadEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'workload',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      workloadGreaterThan(
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

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      workloadLessThan(
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

  QueryBuilder<PendingSubject, PendingSubject, QAfterFilterCondition>
      workloadBetween(
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

extension PendingSubjectQueryObject
    on QueryBuilder<PendingSubject, PendingSubject, QFilterCondition> {}
