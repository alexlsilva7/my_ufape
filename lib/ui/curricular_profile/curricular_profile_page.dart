import 'package:flutter/material.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/repositories/block_of_profile/block_of_profile_repository.dart';
import 'package:my_ufape/domain/entities/block_of_profile.dart';
import 'package:my_ufape/domain/entities/subject.dart';
import 'package:my_ufape/domain/entities/prerequisite.dart';

class CurricularProfilePage extends StatefulWidget {
  const CurricularProfilePage({super.key});

  @override
  State<CurricularProfilePage> createState() => _CurricularProfilePageState();
}

class _CurricularProfilePageState extends State<CurricularProfilePage> {
  final BlockOfProfileRepository _blockRepository = injector.get();
  List<BlockOfProfile> _blocks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBlocks();
  }

  Future<void> _loadBlocks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _blockRepository.getAllBlocks();

    result.fold(
      (blocks) async {
        // Carregar os links de subjects para cada bloco
        for (final block in blocks) {
          await block.subjects.load();
        }

        if (mounted) {
          setState(() {
            _blocks = blocks;
            _isLoading = false;
          });
        }
      },
      (error) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Erro ao carregar perfil curricular: $error';
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil Curricular'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBlocks,
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadBlocks,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_blocks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum perfil curricular encontrado',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Extraia o perfil curricular do SIGA primeiro',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _blocks.length,
      itemBuilder: (context, index) {
        final block = _blocks[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 2,
          child: ExpansionTile(
            title: Text(
              block.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              '${block.subjects.length} disciplina(s)',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            children: block.subjects.map((course) {
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
    );
  }

  void _showSubjectDetails(BuildContext context, Subject subject) {
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
                  _buildDetailRow('Tipo:', subject.type.toString(), context),
                  _buildDetailRow('Período Sugerido:', subject.period, context),
                  _buildDetailRow(
                      'Créditos:', subject.credits.toString(), context),
                  _buildDetailRow(
                      'CH Teórica:', '${subject.workload.teorica}h', context),
                  _buildDetailRow(
                      'CH Prática:', '${subject.workload.pratica}h', context),
                  _buildDetailRow(
                      'CH Extensão:', '${subject.workload.extensao}h', context),
                  _buildDetailRow(
                      'CH Total:', '${subject.workload.total}h', context),
                  const Divider(height: 20),
                  if (subject.prerequisites.isNotEmpty)
                    _buildDetailList('Pré-requisitos:', subject.prerequisites),
                  if (subject.corequisites.isNotEmpty)
                    _buildDetailList('Co-requisitos:', subject.corequisites),
                  if (subject.equivalences.isNotEmpty)
                    _buildDetailList('Equivalências:', subject.equivalences),
                  if (subject.ementa.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text('Ementa:',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subject.ementa),
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
