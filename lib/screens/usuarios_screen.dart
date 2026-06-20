import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';
import '../theme.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  List<Usuario> _usuarios = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  Future<void> _carregarUsuarios() async {
    setState(() => _carregando = true);
    try {
      final usuarios = await UsuarioService.listar();
      if (!mounted) return;
      setState(() {
        _usuarios = usuarios;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar usuários: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _editarUsuario(Usuario usuario) async {
    final nomeCtrl = TextEditingController(text: usuario.nome);
    final emailCtrl = TextEditingController(text: usuario.email);
    String cargo = usuario.cargo;

    final resultado = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Editar Usuário'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    prefixIcon: Icon(Icons.person_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: cargo,
                  decoration: const InputDecoration(
                    labelText: 'Cargo',
                    prefixIcon: Icon(Icons.work_outlined, size: 20),
                  ),
                  items: Usuario.cargos
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => cargo = v);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    if (resultado != true) return;

    try {
      await UsuarioService.atualizar(
        usuario.id!,
        nome: nomeCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        cargo: cargo,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Usuário atualizado!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      _carregarUsuarios();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    nomeCtrl.dispose();
    emailCtrl.dispose();
  }

  Future<void> _deletarUsuario(Usuario usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir Usuário'),
        content: Text(
          'Deseja excluir o perfil de "${usuario.nome}"?\n\nIsso não remove a conta de autenticação, apenas o perfil do sistema.',
        ),
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
      await UsuarioService.deletar(usuario.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Perfil excluído.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      _carregarUsuarios();
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

  IconData _iconeDoCargo(String cargo) {
    switch (cargo) {
      case 'Advogado(a)':
        return Icons.gavel_rounded;
      case 'Secretário(a)':
        return Icons.support_agent_rounded;
      case 'Estagiário(a)':
        return Icons.school_rounded;
      case 'Administrador(a)':
        return Icons.admin_panel_settings_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  Color _corDoCargo(String cargo) {
    switch (cargo) {
      case 'Advogado(a)':
        return AppColors.primary;
      case 'Secretário(a)':
        return AppColors.accent;
      case 'Estagiário(a)':
        return AppColors.success;
      case 'Administrador(a)':
        return AppColors.gold;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Usuários'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Atualizar',
            onPressed: _carregarUsuarios,
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // Cabeçalho com contagem
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: AppColors.background,
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.group_rounded,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Equipe do Escritório',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${_usuarios.length} usuário${_usuarios.length != 1 ? 's' : ''} cadastrado${_usuarios.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Lista de usuários
              Expanded(
                child: _carregando
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      )
                    : _usuarios.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.group_off_rounded,
                                    size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhum usuário cadastrado',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _carregarUsuarios,
                            color: AppColors.primary,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _usuarios.length,
                              itemBuilder: (context, index) {
                                final u = _usuarios[index];
                                final inicial = u.nome.isNotEmpty
                                    ? u.nome[0].toUpperCase()
                                    : '?';
                                final dataFormatada = u.createdAt != null
                                    ? DateFormat('dd/MM/yyyy')
                                        .format(u.createdAt!)
                                    : '-';

                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Avatar
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor:
                                              _corDoCargo(u.cargo),
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

                                        // Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                u.nome,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                  color:
                                                      AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                u.email,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 3,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: _corDoCargo(
                                                              u.cargo)
                                                          .withValues(
                                                              alpha: 0.12),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          _iconeDoCargo(
                                                              u.cargo),
                                                          size: 14,
                                                          color: _corDoCargo(
                                                              u.cargo),
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          u.cargo,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600,
                                                            color:
                                                                _corDoCargo(
                                                                    u.cargo),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Desde $dataFormatada',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color:
                                                          Colors.grey.shade400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Ações
                                        IconButton(
                                          icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 20),
                                          color: AppColors.primary,
                                          tooltip: 'Editar',
                                          onPressed: () =>
                                              _editarUsuario(u),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              size: 20),
                                          color: AppColors.error,
                                          tooltip: 'Excluir',
                                          onPressed: () =>
                                              _deletarUsuario(u),
                                        ),
                                      ],
                                    ),
                                  ),
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
