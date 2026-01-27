import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:my_ufape/core/debug/logarte.dart';

class TeachingPlanExtractionService {
  Future<Map<String, dynamic>> extractPlan({
    required String apiKey,
    required Uint8List pdfBytes,
  }) async {
    // 1. Definição do Schema para Saída Estruturada
    final schema = Schema.object(
      properties: {
        'topics': Schema.array(
          items: Schema.object(
            properties: {
              'date': Schema.string(
                  description:
                      'Data da aula no formato YYYY-MM-DD. Se for um intervalo, use a data de início.'),
              'content': Schema.string(
                  description: 'O conteúdo programático ou assunto da aula.'),
              'type': Schema.enumString(
                enumValues: ['teorica', 'pratica', 'prova', 'outro'],
                description: 'Tipo de atividade',
              ),
            },
            requiredProperties: ['content', 'type'],
          ),
        ),
      },
      requiredProperties: ['topics'],
    );

    // 2. Configuração do Modelo
    final model = GenerativeModel(
      model: 'gemini-flash-lite-latest',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: schema,
      ),
    );

    // 3. Prompt
    final prompt = Content.text('''
      Analise este Plano de Ensino universitário (PDF).
      Extraia o cronograma de aulas, associando datas aos conteúdos.
      Ignore cabeçalhos institucionais. Foque na tabela de "Unidade Programática" ou "Cronograma".
      Converta todas as datas para o ano atual ou próximo se não especificado.
    ''');

    // 4. Dados do PDF
    final pdfData = Content.data('application/pdf', pdfBytes);

    try {
      final response = await model.generateContent([
        Content.multi([prompt.parts.first, pdfData.parts.first])
      ]);

      if (response.text == null) throw Exception("Gemini retornou vazio.");

      logarte.log('Gemini retornou: ${response.text}');
      // Retorna o JSON parseado
      return jsonDecode(response.text!);
    } catch (e) {
      logarte.log('Erro ao extrair plano com Gemini: $e');
      rethrow;
    }
  }
}
