// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_note.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSubjectNoteCollection on Isar {
  IsarCollection<SubjectNote> get subjectNotes => this.collection();
}

const SubjectNoteSchema = CollectionSchema(
  name: r'SubjectNote',
  id: 6005850464468682121,
  properties: {
    r'nome': PropertySchema(
      id: 0,
      name: r'nome',
      type: IsarType.string,
    ),
    r'notasKeys': PropertySchema(
      id: 1,
      name: r'notasKeys',
      type: IsarType.stringList,
    ),
    r'notasValues': PropertySchema(
      id: 2,
      name: r'notasValues',
      type: IsarType.stringList,
    ),
    r'semestre': PropertySchema(
      id: 3,
      name: r'semestre',
      type: IsarType.string,
    ),
    r'situacao': PropertySchema(
      id: 4,
      name: r'situacao',
      type: IsarType.string,
    ),
    r'teacher': PropertySchema(
      id: 5,
      name: r'teacher',
      type: IsarType.string,
    )
  },
  estimateSize: _subjectNoteEstimateSize,
  serialize: _subjectNoteSerialize,
  deserialize: _subjectNoteDeserialize,
  deserializeProp: _subjectNoteDeserializeProp,
  idName: r'id',
  indexes: {
    r'nome': IndexSchema(
      id: -3554607249464315131,
      name: r'nome',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'nome',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'semestre': IndexSchema(
      id: 2781374809941845433,
      name: r'semestre',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'semestre',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _subjectNoteGetId,
  getLinks: _subjectNoteGetLinks,
  attach: _subjectNoteAttach,
  version: '3.3.0',
);

int _subjectNoteEstimateSize(
  SubjectNote object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.nome.length * 3;
  bytesCount += 3 + object.notasKeys.length * 3;
  {
    for (var i = 0; i < object.notasKeys.length; i++) {
      final value = object.notasKeys[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.notasValues.length * 3;
  {
    for (var i = 0; i < object.notasValues.length; i++) {
      final value = object.notasValues[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.semestre.length * 3;
  bytesCount += 3 + object.situacao.length * 3;
  bytesCount += 3 + object.teacher.length * 3;
  return bytesCount;
}

void _subjectNoteSerialize(
  SubjectNote object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.nome);
  writer.writeStringList(offsets[1], object.notasKeys);
  writer.writeStringList(offsets[2], object.notasValues);
  writer.writeString(offsets[3], object.semestre);
  writer.writeString(offsets[4], object.situacao);
  writer.writeString(offsets[5], object.teacher);
}

SubjectNote _subjectNoteDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SubjectNote(
    nome: reader.readString(offsets[0]),
    semestre: reader.readString(offsets[3]),
    situacao: reader.readString(offsets[4]),
    teacher: reader.readString(offsets[5]),
  );
  object.id = id;
  object.notasKeys = reader.readStringList(offsets[1]) ?? [];
  object.notasValues = reader.readStringList(offsets[2]) ?? [];
  return object;
}

P _subjectNoteDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _subjectNoteGetId(SubjectNote object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _subjectNoteGetLinks(SubjectNote object) {
  return [];
}

void _subjectNoteAttach(
    IsarCollection<dynamic> col, Id id, SubjectNote object) {
  object.id = id;
}

extension SubjectNoteQueryWhereSort
    on QueryBuilder<SubjectNote, SubjectNote, QWhere> {
  QueryBuilder<SubjectNote, SubjectNote, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SubjectNoteQueryWhere
    on QueryBuilder<SubjectNote, SubjectNote, QWhereClause> {
  QueryBuilder<SubjectNote, SubjectNote, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SubjectNote, SubjectNote, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterWhereClause> idBetween(
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

  QueryBuilder<SubjectNote, SubjectNote, QAfterWhereClause> nomeEqualTo(
      String nome) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nome',
        value: [nome],
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterWhereClause> nomeNotEqualTo(
      String nome) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nome',
              lower: [],
              upper: [nome],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nome',
              lower: [nome],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nome',
              lower: [nome],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nome',
              lower: [],
              upper: [nome],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterWhereClause> semestreEqualTo(
      String semestre) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'semestre',
        value: [semestre],
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterWhereClause> semestreNotEqualTo(
      String semestre) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'semestre',
              lower: [],
              upper: [semestre],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'semestre',
              lower: [semestre],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'semestre',
              lower: [semestre],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'semestre',
              lower: [],
              upper: [semestre],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SubjectNoteQueryFilter
    on QueryBuilder<SubjectNote, SubjectNote, QFilterCondition> {
  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> nomeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> nomeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> nomeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> nomeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nome',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> nomeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> nomeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> nomeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> nomeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nome',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> nomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nome',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      nomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nome',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasKeysElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notasKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasKeysElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notasKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasKeysElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notasKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasKeysElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notasKeys',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasKeysElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notasKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasKeysElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notasKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasKeysElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notasKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasKeysElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notasKeys',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasKeysElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notasKeys',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasKeysElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notasKeys',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasKeysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'notasKeys',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasKeysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'notasKeys',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasKeysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'notasKeys',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasKeysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'notasKeys',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasKeysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'notasKeys',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasKeysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'notasKeys',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasValuesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notasValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasValuesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notasValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasValuesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notasValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasValuesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notasValues',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasValuesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notasValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasValuesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notasValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasValuesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notasValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasValuesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notasValues',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasValuesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notasValues',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasValuesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notasValues',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasValuesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'notasValues',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasValuesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'notasValues',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasValuesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'notasValues',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasValuesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'notasValues',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasValuesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'notasValues',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      notasValuesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'notasValues',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> semestreEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'semestre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      semestreGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'semestre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      semestreLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'semestre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> semestreBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'semestre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      semestreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'semestre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      semestreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'semestre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      semestreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'semestre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> semestreMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'semestre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      semestreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'semestre',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      semestreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'semestre',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> situacaoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'situacao',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      situacaoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'situacao',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      situacaoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'situacao',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> situacaoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'situacao',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      situacaoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'situacao',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      situacaoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'situacao',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      situacaoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'situacao',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> situacaoMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'situacao',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      situacaoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'situacao',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      situacaoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'situacao',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> teacherEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'teacher',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      teacherGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'teacher',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> teacherLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'teacher',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> teacherBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'teacher',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      teacherStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'teacher',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> teacherEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'teacher',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> teacherContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'teacher',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition> teacherMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'teacher',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      teacherIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'teacher',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterFilterCondition>
      teacherIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'teacher',
        value: '',
      ));
    });
  }
}

extension SubjectNoteQueryObject
    on QueryBuilder<SubjectNote, SubjectNote, QFilterCondition> {}

extension SubjectNoteQueryLinks
    on QueryBuilder<SubjectNote, SubjectNote, QFilterCondition> {}

extension SubjectNoteQuerySortBy
    on QueryBuilder<SubjectNote, SubjectNote, QSortBy> {
  QueryBuilder<SubjectNote, SubjectNote, QAfterSortBy> sortByNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.asc);
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterSortBy> sortByNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.desc);
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterSortBy> sortBySemestre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semestre', Sort.asc);
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterSortBy> sortBySemestreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semestre', Sort.desc);
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterSortBy> sortBySituacao() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'situacao', Sort.asc);
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterSortBy> sortBySituacaoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'situacao', Sort.desc);
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterSortBy> sortByTeacher() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teacher', Sort.asc);
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterSortBy> sortByTeacherDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teacher', Sort.desc);
    });
  }
}

extension SubjectNoteQuerySortThenBy
    on QueryBuilder<SubjectNote, SubjectNote, QSortThenBy> {
  QueryBuilder<SubjectNote, SubjectNote, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterSortBy> thenByNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.asc);
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterSortBy> thenByNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.desc);
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterSortBy> thenBySemestre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semestre', Sort.asc);
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterSortBy> thenBySemestreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semestre', Sort.desc);
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterSortBy> thenBySituacao() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'situacao', Sort.asc);
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterSortBy> thenBySituacaoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'situacao', Sort.desc);
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterSortBy> thenByTeacher() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teacher', Sort.asc);
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QAfterSortBy> thenByTeacherDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teacher', Sort.desc);
    });
  }
}

extension SubjectNoteQueryWhereDistinct
    on QueryBuilder<SubjectNote, SubjectNote, QDistinct> {
  QueryBuilder<SubjectNote, SubjectNote, QDistinct> distinctByNome(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nome', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QDistinct> distinctByNotasKeys() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notasKeys');
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QDistinct> distinctByNotasValues() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notasValues');
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QDistinct> distinctBySemestre(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'semestre', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QDistinct> distinctBySituacao(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'situacao', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectNote, SubjectNote, QDistinct> distinctByTeacher(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'teacher', caseSensitive: caseSensitive);
    });
  }
}

extension SubjectNoteQueryProperty
    on QueryBuilder<SubjectNote, SubjectNote, QQueryProperty> {
  QueryBuilder<SubjectNote, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SubjectNote, String, QQueryOperations> nomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nome');
    });
  }

  QueryBuilder<SubjectNote, List<String>, QQueryOperations>
      notasKeysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notasKeys');
    });
  }

  QueryBuilder<SubjectNote, List<String>, QQueryOperations>
      notasValuesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notasValues');
    });
  }

  QueryBuilder<SubjectNote, String, QQueryOperations> semestreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'semestre');
    });
  }

  QueryBuilder<SubjectNote, String, QQueryOperations> situacaoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'situacao');
    });
  }

  QueryBuilder<SubjectNote, String, QQueryOperations> teacherProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'teacher');
    });
  }
}
