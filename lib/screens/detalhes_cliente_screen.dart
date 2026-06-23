import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/cliente.dart';
import '../models/documento.dart';
import '../services/cliente_service.dart';
import '../services/documento_service.dart';
import '../theme.dart';
import '../widgets/documento_tile.dart';
import 'editar_cliente_screen.dart';
import 'historico_screen.dart';

class DetalhesClienteScreen extends StatefulWidget {
  final int clienteId;
  const DetalhesClienteScreen({super.key, required this.clienteId});

  @override
  State<DetalhesClienteScreen> createState() => _DetalhesClienteScreenState();
}

class _DetalhesClienteScreenState extends State<DetalhesClienteScreen> {
  Cliente? _cliente;
  List<Documento> _documentos = [];
  bool _carregando = true;
  bool _senhaVisivel = false;
  bool _uploadando = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    try {
      final cliente = await ClienteService.buscarPorId(widget.clienteId);
      List<Documento> docs = [];
      try {
        docs = await DocumentoService.listar(widget.clienteId);
      } catch (_) {
        // Tabela de documentos pode não existir ainda
      }
      if (!mounted) return;
      setState(() {
        _cliente = cliente;
        _documentos = docs;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erro ao carregar dados.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _alternarPrioridade() async {
    if (_cliente == null) return;
    try {
      await ClienteService.alternarPrioridade(
          _cliente!.id!, !_cliente!.prioridade);
      _carregarDados();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _uploadDocumento() async {
    if (_cliente == null) return;

    // Selecionar tipo de documento
    final tipo = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Tipo de Documento'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        children: Documento.tipos
            .map(
              (t) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, t),
                child: Text(t),
              ),
            )
            .toList(),
      ),
    );
    if (tipo == null) return;

    // Selecionar arquivo
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      withData: true,
    );
    if (resultado == null || resultado.files.isEmpty) return;

    final arquivo = resultado.files.first;
    if (arquivo.bytes == null) return;

    setState(() => _uploadando = true);
    try {
      await DocumentoService.upload(
        clienteId: _cliente!.id!,
        nomeArquivo: arquivo.name,
        tipo: tipo,
        bytes: arquivo.bytes!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Documento enviado com sucesso!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      _carregarDados();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar documento: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
    if (!mounted) return;
    setState(() => _uploadando = false);
  }

  Future<void> _deletarDocumento(Documento doc) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir Documento'),
        content: Text('Deseja excluir "${doc.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await DocumentoService.deletar(doc);
      _carregarDados();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _deletarCliente() async {
    if (_cliente == null) return;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir Cliente'),
        content: Text(
            'Deseja realmente excluir "${_cliente!.nome}" e todos os seus dados? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await ClienteService.deletar(_cliente!.id!);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes do Cliente')),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_cliente == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes do Cliente')),
        body: const Center(child: Text('Cliente não encontrado.')),
      );
    }

    final c = _cliente!;
    final inicial = c.nome.isNotEmpty ? c.nome[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Cliente'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              switch (value) {
                case 'editar':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditarClienteScreen(cliente: c),
                    ),
                  ).then((_) => _carregarDados());
                  break;
                case 'historico':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          HistoricoScreen(clienteId: c.id!, nome: c.nome),
                    ),
                  );
                  break;
                case 'deletar':
                  _deletarCliente();
                  break;
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'editar',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'historico',
                child: Row(
                  children: [
                    Icon(Icons.history_rounded, size: 18, color: AppColors.accent),
                    SizedBox(width: 8),
                    Text('Histórico'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'deletar',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded, size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Excluir'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Cabeçalho do cliente
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: c.prioridade
                            ? AppColors.gold
                            : AppColors.primary,
                        child: Text(
                          inicial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        c.nome,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Badge de prioridade
                      GestureDetector(
                        onTap: _alternarPrioridade,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: c.prioridade
                                ? AppColors.gold.withValues(alpha: 0.15)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                c.prioridade
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                size: 18,
                                color: c.prioridade
                                    ? AppColors.gold
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                c.prioridade ? 'Prioritário' : 'Normal',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: c.prioridade
                                      ? AppColors.gold
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      // Botões de ação rápida
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ActionChip(
                            icone: Icons.edit_rounded,
                            label: 'Editar',
                            cor: AppColors.primary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditarClienteScreen(cliente: c),
                                ),
                              ).then((_) => _carregarDados());
                            },
                          ),
                          const SizedBox(width: 10),
                          _ActionChip(
                            icone: Icons.history_rounded,
                            label: 'Histórico',
                            cor: AppColors.accent,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HistoricoScreen(
                                    clienteId: c.id!,
                                    nome: c.nome,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Dados Pessoais
              _secaoTitulo('Dados Pessoais', Icons.person_rounded),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _InfoRow(
                          icone: Icons.badge_outlined,
                          label: 'CPF',
                          valor: c.cpf),
                      if (c.rg != null && c.rg!.isNotEmpty)
                        _InfoRow(
                            icone: Icons.credit_card_outlined,
                            label: 'RG',
                            valor: c.rg!),
                      if (c.dataNascimento != null &&
                          c.dataNascimento!.isNotEmpty)
                        _InfoRow(
                            icone: Icons.calendar_today_outlined,
                            label: 'Nascimento',
                            valor: c.dataNascimento!),
                      if (c.estadoCivil != null && c.estadoCivil!.isNotEmpty)
                        _InfoRow(
                            icone: Icons.favorite_border_rounded,
                            label: 'Estado Civil',
                            valor: c.estadoCivil!),
                    ],
                  ),
                ),
              ),

              // Dados Previdenciários
              if ((c.nitPis != null && c.nitPis!.isNotEmpty) ||
                  (c.senhaGov != null && c.senhaGov!.isNotEmpty)) ...[
                const SizedBox(height: 16),
                _secaoTitulo(
                    'Dados Previdenciários', Icons.account_balance_rounded),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (c.nitPis != null && c.nitPis!.isNotEmpty)
                          _InfoRow(
                              icone: Icons.numbers_rounded,
                              label: 'NIT/PIS',
                              valor: c.nitPis!),
                        if (c.senhaGov != null && c.senhaGov!.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.lock_outlined,
                                  size: 20, color: AppColors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Senha GOV.BR',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary),
                                    ),
                                    Text(
                                      _senhaVisivel
                                          ? c.senhaGov!
                                          : '••••••••',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => setState(
                                    () => _senhaVisivel = !_senhaVisivel),
                                icon: Icon(
                                  _senhaVisivel
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                tooltip: _senhaVisivel
                                    ? 'Ocultar'
                                    : 'Mostrar',
                              ),
                              IconButton(
                                onPressed: () async {
                                  await Clipboard.setData(
                                      ClipboardData(text: c.senhaGov!));
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Senha copiada!'),
                                      backgroundColor: AppColors.success,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.copy_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                tooltip: 'Copiar senha',
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],

              // Contato
              if ((c.telefone != null && c.telefone!.isNotEmpty) ||
                  (c.email != null && c.email!.isNotEmpty) ||
                  (c.endereco != null && c.endereco!.isNotEmpty)) ...[
                const SizedBox(height: 16),
                _secaoTitulo('Contato', Icons.phone_rounded),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (c.telefone != null && c.telefone!.isNotEmpty)
                          _InfoRow(
                              icone: Icons.phone_outlined,
                              label: 'Telefone',
                              valor: c.telefone!),
                        if (c.email != null && c.email!.isNotEmpty)
                          _InfoRow(
                              icone: Icons.email_outlined,
                              label: 'E-mail',
                              valor: c.email!),
                        if (c.endereco != null && c.endereco!.isNotEmpty)
                          _InfoRow(
                              icone: Icons.home_outlined,
                              label: 'Endereço',
                              valor: c.endereco!),
                      ],
                    ),
                  ),
                ),
              ],

              // Observações
              if (c.observacoes != null && c.observacoes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _secaoTitulo('Observações', Icons.notes_rounded),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      c.observacoes!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],

              // Documentos
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.folder_rounded,
                      size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Documentos',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _uploadando ? null : _uploadDocumento,
                    icon: _uploadando
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload_file_rounded, size: 18),
                    label: Text(_uploadando ? 'Enviando...' : 'Anexar'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_documentos.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.folder_open_rounded,
                            size: 40, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text(
                          'Nenhum documento anexado',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...(_documentos.map(
                  (doc) => DocumentoTile(
                    documento: doc,
                    onVisualizar: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final uri = Uri.parse(doc.url);
                      try {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      } catch (_) {
                        messenger.showSnackBar(
                          SnackBar(
                            content:
                                const Text('Não foi possível abrir o arquivo.'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                    onBaixar: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final uri = Uri.parse('${doc.url}?download=');
                      try {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      } catch (_) {
                        messenger.showSnackBar(
                          SnackBar(
                            content:
                                const Text('Não foi possível baixar o arquivo.'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                    onDeletar: () => _deletarDocumento(doc),
                  ),
                )),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _secaoTitulo(String titulo, IconData icone) {
    return Row(
      children: [
        Icon(icone, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

// ─── Widgets auxiliares ──────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icone;
  final String label;
  final String valor;

  const _InfoRow({
    required this.icone,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icone;
  final String label;
  final Color cor;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icone,
    required this.label,
    required this.cor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: 16, color: cor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
