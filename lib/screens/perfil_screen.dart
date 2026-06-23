import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Usuario? _perfil;
  String _cargo = 'Secretário(a)';
  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarPerfil() async {
    setState(() => _carregando = true);
    try {
      final perfil = await UsuarioService.buscarPerfilAtual();
      if (!mounted) return;
      if (perfil != null) {
        _perfil = perfil;
        _nomeCtrl.text = perfil.nome;
        _emailCtrl.text = perfil.email;
        _cargo = perfil.cargo;
      }
      setState(() => _carregando = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar perfil: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _salvarPerfil() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    try {
      if (_perfil == null) {
        final user = AuthService.usuarioAtual;
        if (user != null) {
          await UsuarioService.criarPerfil(
            authId: user.id,
            nome: _nomeCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            cargo: _cargo,
          );
          // Reload profile after creating
          _perfil = await UsuarioService.buscarPerfilAtual();
        }
      } else {
        await UsuarioService.atualizar(
          _perfil!.id!,
          nome: _nomeCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          cargo: _cargo,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Perfil atualizado com sucesso!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
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
    if (!mounted) return;
    setState(() => _salvando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
      ),
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: AppColors.accent,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Dados do Perfil',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Edite suas informações pessoais',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            TextFormField(
                              controller: _nomeCtrl,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Nome Completo',
                                prefixIcon:
                                    Icon(Icons.person_outline, size: 20),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Informe seu nome'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'E-mail',
                                prefixIcon: Icon(Icons.email_outlined, size: 20),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Informe seu e-mail'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            DropdownButtonFormField<String>(
                              initialValue: _cargo,
                              decoration: const InputDecoration(
                                labelText: 'Cargo',
                                prefixIcon: Icon(Icons.work_outline, size: 20),
                              ),
                              items: Usuario.cargos
                                  .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _cargo = v);
                              },
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: _salvando ? null : _salvarPerfil,
                                icon: _salvando
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.save_rounded, size: 20),
                                label: Text(_salvando ? 'Salvando...' : 'Salvar Alterações'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
