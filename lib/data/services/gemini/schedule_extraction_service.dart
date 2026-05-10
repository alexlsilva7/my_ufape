import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:my_ufape/core/debug/logarte.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';

class ScheduleExtractionService {
  final SettingsRepository _settingsRepository;

  ScheduleExtractionService(this._settingsRepository);
  Future<List<Map<String, dynamic>>> extractSchedule({
    required String apiKey,
    required Uint8List pdfBytes,
    required List<String> knownSubjectsContext,
  }) async {
    // 1. Schema de saída estruturada
    final schema = Schema.object(
      properties: {
        'classes': Schema.array(
          description: 'Lista de turmas ofertadas no semestre.',
          items: Schema.object(
            properties: {
              'subjectCode': Schema.string(
                  description:
                      'Código da disciplina correspondente na lista de Disciplinas Conhecidas. Se não houver correspondência, gere um código baseado no nome.'),
              'subjectName': Schema.string(
                  description:
                      'Nome da disciplina. Ex: Introdução à Programação I'),
              'professor': Schema.string(
                  description:
                      'Nome do professor. Se não houver, deixe vazio.'),
              'period': Schema.string(
                  description: 'Período indicado. Ex: 1, 2, Optativa'),
              'className': Schema.string(
                  description: 'Nome/código da turma. Ex: Turma 1, Turma 2'),
              'room': Schema.string(description: 'Sala de aula. Ex: SALA 1B'),
              'schedules': Schema.array(
                description: 'Horários em que a aula ocorre',
                items: Schema.object(
                  properties: {
                    'day': Schema.enumString(
                      enumValues: [
                        'segunda',
                        'terca',
                        'quarta',
                        'quinta',
                        'sexta',
                        'sabado'
                      ],
                    ),
                    'start': Schema.string(
                        description:
                            'Horário de início (HH:mm). Extraia de "h1830_2010" como "18:30"'),
                    'end': Schema.string(
                        description:
                            'Horário de término (HH:mm). Extraia de "h1830_2010" como "20:10"'),
                  },
                  requiredProperties: ['day', 'start', 'end'],
                ),
              ),
            },
            requiredProperties: [
              'subjectCode',
              'subjectName',
              'schedules',
            ],
          ),
        ),
      },
      requiredProperties: ['classes'],
    );

    // 2. Modelo
    final modelName = _settingsRepository.geminiModel;
    final model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: schema,
      ),
    );

    // 3. Prompt
    final prompt = Content.text('''
      Você é um assistente acadêmico. Analise o arquivo PDF anexo contendo a oferta de horários de disciplinas da UFAPE.
      O documento está organizado por blocos que indicam a Turma, o Período e a Sala.
      O cabeçalho "h1830_2010" significa que a aula começa às 18:30 e termina às 20:10.
      Abaixo disso, nas colunas de "seg", "ter", "qua", etc., estão os nomes das disciplinas e o professor (entre parênteses).
      Exemplo: "Lógica Matemática I (Marcius)".
      Extraia todas as disciplinas ofertadas, seus horários, turmas, períodos e salas.
      
      IMPORTANTE: Você está recebendo uma lista de referência de "Disciplinas Conhecidas" no formato CÓDIGO - NOME:
      ${knownSubjectsContext.join('\n')}
      
      Compare o nome extraído do PDF com essa lista. Retorne o subjectCode exato da lista de referência para cada disciplina.
      Caso não encontre uma correspondência na lista, você deve gerar um código baseado no nome.
    ''');

    // 4. Dados do PDF
    final pdfData = Content.data('application/pdf', pdfBytes);

    try {
      final response = await model.generateContent([
        Content.multi([prompt.parts.first, pdfData.parts.first])
      ]);

      if (response.text == null) throw Exception("Gemini retornou vazio.");

      logarte.log('Gemini (schedule) retornou: ${response.text}');
      final jsonResponse = jsonDecode(response.text!);
      return List<Map<String, dynamic>>.from(jsonResponse['classes'] ?? []);
    } catch (e) {
      logarte.log('Erro ao extrair grade com Gemini: $e');
      rethrow;
    }
  }
}
