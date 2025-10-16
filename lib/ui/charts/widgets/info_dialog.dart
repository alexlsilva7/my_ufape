import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

class InfoDialog extends StatelessWidget {
  final String markdownContent;

  const InfoDialog({
    super.key,
    required this.markdownContent,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: GptMarkdown(
          markdownContent,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}

void showInfoDialog(BuildContext context, String markdownContent) {
  showDialog(
    context: context,
    builder: (context) => InfoDialog(
      markdownContent: markdownContent,
    ),
  );
}
