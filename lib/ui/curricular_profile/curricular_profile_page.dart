import 'package:flutter/material.dart';
import 'package:my_ufape/domain/entities/block.dart';
import 'package:my_ufape/domain/entities/course.dart';
import 'package:my_ufape/domain/entities/prerequisite.dart';

class CurricularProfilePage extends StatelessWidget {
  const CurricularProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final curriculumBlocks =
        ModalRoute.of(context)!.settings.arguments as List<Block>;

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
                block.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              children: block.courses.map((course) {
                return ListTile(
                  title: Text('${course.code} - ${course.name}'),
                  subtitle: Text(
                      'Período: ${course.period} | CH: ${course.workload.total}h | Créditos: ${course.credits}'),
                  onTap: () => _showSubjectDetails(context, course),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  void _showSubjectDetails(BuildContext context, Course course) {
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
                    '${course.code} - ${course.name}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Divider(height: 20),
                  _buildDetailRow('Tipo:', course.type.toString(), context),
                  _buildDetailRow('Período Sugerido:', course.period, context),
                  _buildDetailRow(
                      'Créditos:', course.credits.toString(), context),
                  _buildDetailRow(
                      'CH Teórica:', '${course.workload.teorica}h', context),
                  _buildDetailRow(
                      'CH Prática:', '${course.workload.pratica}h', context),
                  _buildDetailRow(
                      'CH Extensão:', '${course.workload.extensao}h', context),
                  _buildDetailRow(
                      'CH Total:', '${course.workload.total}h', context),
                  const Divider(height: 20),
                  if (course.prerequisites.isNotEmpty)
                    _buildDetailList('Pré-requisitos:', course.prerequisites),
                  if (course.corequisites.isNotEmpty)
                    _buildDetailList('Co-requisitos:', course.corequisites),
                  if (course.equivalences.isNotEmpty)
                    _buildDetailList('Equivalências:', course.equivalences),
                  if (course.ementa.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text('Ementa:',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(course.ementa),
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

  Widget _buildDetailList(String label, List<Prerequisite> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                child: Text('• ${item.code} - ${item.name}'),
              )),
        ],
      ),
    );
  }
}
