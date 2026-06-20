import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../theme.dart';

class ClienteCard extends StatelessWidget {
  final Cliente cliente;
  final VoidCallback onTap;

  const ClienteCard({
    super.key,
    required this.cliente,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inicial = cliente.nome.isNotEmpty
        ? cliente.nome[0].toUpperCase()
        : '?';

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar com inicial
              CircleAvatar(
                radius: 24,
                backgroundColor: cliente.prioridade
                    ? AppColors.gold
                    : AppColors.primary,
                child: Text(
                  inicial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Nome e CPF
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            cliente.nome,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (cliente.prioridade)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded,
                                    size: 14, color: AppColors.gold),
                                SizedBox(width: 3),
                                Text(
                                  'Prioritário',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CPF: ${cliente.cpf}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Seta
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
