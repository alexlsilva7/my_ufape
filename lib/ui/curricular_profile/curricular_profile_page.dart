import 'package:flutter/material.dart';
import 'package:my_ufape/domain/entities/curricular_profile.dart';

class CurricularProfilePage extends StatelessWidget {
  const CurricularProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Recupera os dados passados como argumento pela rota
    final curriculumBlocks =
        ModalRoute.of(context)!.settings.arguments as List<CurriculumBlock>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil Curricular'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: curriculumBlocks.length,
        itemBuilder: (context, index) {
          final block = curriculumBlocks[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 2,
            child: ExpansionTile(
              title: Text(
                block.title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              children: block.subjects.map((subject) {
                return ListTile(
                  title: Text('${subject.code} - ${subject.name}'),
                  subtitle: Text(
                      'Período: ${subject.semester} | CH: ${subject.workloadTotal}h | Créditos: ${subject.credits}'),
                  onTap: () => _showSubjectDetails(context, subject),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  void _showSubjectDetails(BuildContext context, SubjectProfile subject) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: ListView(
                controller: scrollController,
                children: [
                  Text(
                    '${subject.code} - ${subject.name}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Divider(height: 20),
                  _buildDetailRow('Tipo:', subject.type, context),
                  _buildDetailRow(
                      'Período Sugerido:', subject.semester, context),
                  _buildDetailRow('Créditos:', subject.credits, context),
                  _buildDetailRow('CH Teórica:',
                      '${subject.workloadTheoretical}h', context),
                  _buildDetailRow(
                      'CH Prática:', '${subject.workloadPractical}h', context),
                  _buildDetailRow(
                      'CH Total:', '${subject.workloadTotal}h', context),
                  const Divider(height: 20),
                  if (subject.prerequisites.isNotEmpty)
                    _buildDetailList('Pré-requisitos:', subject.prerequisites),
                  if (subject.corequisites.isNotEmpty)
                    _buildDetailList('Co-requisitos:', subject.corequisites),
                  if (subject.equivalences.isNotEmpty)
                    _buildDetailList('Equivalências:', subject.equivalences),
                  if (subject.syllabus.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text('Ementa:',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subject.syllabus),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
                text: '$label ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailList(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                child: Text('• $item'),
              )),
        ],
      ),
    );
  }
}
