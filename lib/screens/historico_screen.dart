import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/cliente_service.dart';
import '../theme.dart';

class HistoricoScreen extends StatefulWidget {
  final int clienteId;
  final String nome;

  const HistoricoScreen({
    super.key,
    required this.clienteId,
    required this.nome,
  });

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  List<Map<String, dynamic>> _historico = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    setState(() => _carregando = true);
    try {
      final dados = await ClienteService.buscarHistorico(widget.clienteId);
      if (!mounted) return;
      setState(() {
        _historico = dados;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Alterações'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // Cabeçalho
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: AppColors.background,
                child: Row(
                  children: [
                    const Icon(Icons.history_rounded,
                        color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.nome,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${_historico.length} alteraç${_historico.length == 1 ? 'ão' : 'ões'} registrada${_historico.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Lista do histórico
              Expanded(
                child: _carregando
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      )
                    : _historico.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.history_rounded,
                                    size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhuma alteração registrada',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'As alterações nos dados do cliente\naparecerão aqui',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _carregarHistorico,
                            color: AppColors.primary,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _historico.length,
                              itemBuilder: (context, index) {
                                final item = _historico[index];
                                return _HistoricoItem(
                                  item: item,
                                  isFirst: index == 0,
                                  isLast: index == _historico.length - 1,
                                );
                              },
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

// ─── Item do Histórico (Timeline) ────────────────────────────────────────────

class _HistoricoItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isFirst;
  final bool isLast;

  const _HistoricoItem({
    required this.item,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final campo = item['campo'] ?? '';
    final valorAnterior = item['valor_anterior'] ?? '-';
    final valorNovo = item['valor_novo'] ?? '-';
    final usuario = item['usuario'] ?? 'desconhecido';
    final data = item['created_at'] != null
        ? DateFormat('dd/MM/yyyy HH:mm')
            .format(DateTime.parse(item['created_at']).toLocal())
        : '-';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline visual
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Linha superior
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.divider,
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
                // Círculo
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryLight,
                      width: 2,
                    ),
                  ),
                ),
                // Linha inferior
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.divider,
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),

          // Conteúdo
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo alterado e data
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            campo,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          data,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Valor anterior → novo
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Anterior',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  valorAnterior.isEmpty ? '(vazio)' : valorAnterior,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: valorAnterior.isEmpty
                                        ? Colors.grey
                                        : AppColors.textPrimary,
                                    fontStyle: valorAnterior.isEmpty
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.arrow_forward_rounded,
                              size: 16, color: AppColors.textSecondary),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Novo',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  valorNovo.isEmpty ? '(vazio)' : valorNovo,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: valorNovo.isEmpty
                                        ? Colors.grey
                                        : AppColors.textPrimary,
                                    fontStyle: valorNovo.isEmpty
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Usuário
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          usuario,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
