import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/documento.dart';
import '../theme.dart';

class DocumentoTile extends StatelessWidget {
  final Documento documento;
  final VoidCallback onVisualizar;
  final VoidCallback onDeletar;

  const DocumentoTile({
    super.key,
    required this.documento,
    required this.onVisualizar,
    required this.onDeletar,
  });

  IconData _iconeDoTipo(String tipo) {
    switch (tipo) {
      case 'RG':
      case 'CPF':
        return Icons.badge_outlined;
      case 'Comprovante de Residência':
        return Icons.home_outlined;
      case 'CTPS':
        return Icons.work_outline;
      case 'Certidão de Nascimento':
      case 'Certidão de Casamento':
        return Icons.description_outlined;
      case 'Laudo Médico':
        return Icons.medical_services_outlined;
      case 'Processo':
        return Icons.gavel_outlined;
      case 'Procuração':
        return Icons.assignment_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataFormatada = documento.createdAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(documento.createdAt!)
        : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // Ícone do tipo
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _iconeDoTipo(documento.tipo),
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Nome e tipo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  documento.nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${documento.tipo} • $dataFormatada',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Ações
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded, size: 20),
            color: AppColors.accent,
            tooltip: 'Visualizar',
            onPressed: onVisualizar,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            color: AppColors.error,
            tooltip: 'Excluir',
            onPressed: onDeletar,
          ),
        ],
      ),
    );
  }
}
