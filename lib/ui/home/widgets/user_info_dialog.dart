import 'package:flutter/material.dart';
import 'package:my_ufape/domain/entities/user.dart';
import 'package:clipboard/clipboard.dart';

class UserInfoDialog extends StatelessWidget {
  final User user;

  const UserInfoDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    void copyToClipboard(String text, String fieldName) async {
      await FlutterClipboard.copy(text);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fieldName copiada para a área de transferência!'),
          duration: const Duration(seconds: 1),
        ),
      );
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.person_outline),
          SizedBox(width: 8),
          Text('Perfil do Estudante'),
        ],
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            _InfoRow(
                icon: Icons.person_outline,
                label: 'Nome Completo',
                value: user.name),
            _InfoRow(
              icon: Icons.school_outlined,
              label: 'Matrícula',
              value: user.registration,
              onCopy: () => copyToClipboard(user.registration, 'Matrícula'),
            ),
            _InfoRow(
                icon: Icons.book_outlined, label: 'Curso', value: user.course),
            _InfoRow(
                icon: Icons.date_range_outlined,
                label: 'Período de Ingresso',
                value: user.entryPeriod),
            _InfoRow(
                icon: Icons.login_outlined,
                label: 'Tipo de Ingresso',
                value: user.entryType),
            _InfoRow(
                icon: Icons.assignment_ind_outlined,
                label: 'Perfil',
                value: user.profile),
            _InfoRow(
                icon: Icons.wb_sunny_outlined,
                label: 'Turno',
                value: user.shift),
            _InfoRow(
                icon: Icons.check_circle_outline,
                label: 'Situação',
                value: user.situation),
            _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Período Letivo Corrente',
                value: user.currentPeriod),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Fechar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  // 3. Adicione um callback opcional para a ação de copiar
  final VoidCallback? onCopy;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 20,
              color: theme.colorScheme.primary.withValues(alpha: 0.8)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.textTheme.labelSmall?.color
                        ?.withValues(alpha: 0.7),
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          // 4. Mostre o botão de copiar apenas se o callback 'onCopy' for fornecido
          if (onCopy != null)
            IconButton(
              icon: const Icon(Icons.content_copy),
              iconSize: 20,
              color: theme.colorScheme.secondary,
              tooltip: 'Copiar',
              onPressed: onCopy,
            ),
        ],
      ),
    );
  }
}
