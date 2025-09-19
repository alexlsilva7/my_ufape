// lib/grades_page.dart

import 'package:flutter/material.dart';
import '../../domain/entities/grades_model.dart';

class GradesPage extends StatelessWidget {
  final List<Periodo> periodos;

  const GradesPage({super.key, required this.periodos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Notas'),
        backgroundColor: const Color(0xFF004D40),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: periodos.length,
        itemBuilder: (context, index) {
          final periodo = periodos[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ExpansionTile(
              title: Text(
                'Período: ${periodo.nome}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              children: periodo.disciplinas
                  .map((disciplina) => _buildDisciplineCard(disciplina))
                  .toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDisciplineCard(Disciplina disciplina) {
    // Define a cor da situação
    Color situacaoColor;
    if (disciplina.situacao.contains('APROVADO')) {
      situacaoColor = Colors.green.shade700;
    } else if (disciplina.situacao.contains('REPROVADO')) {
      situacaoColor = Colors.red.shade700;
    } else {
      situacaoColor = Colors.orange.shade700;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                disciplina.nome,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Divider(height: 20),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: disciplina.notas.entries.map((entry) {
                  return Chip(
                    label: Text(
                      '${entry.key}: ${entry.value}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.grey.shade200,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  disciplina.situacao,
                  style: TextStyle(
                    color: situacaoColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
