import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/usuario_service.dart';
import '../theme.dart';
import 'menu_screen.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen>
    with SingleTickerProviderStateMixin {
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmarSenhaCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _cargo = 'Secretário(a)';
  bool _carregando = false;
  bool _senhaVisivel = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmarSenhaCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      // 1. Criar conta no Supabase Auth
      final response = await AuthService.registrar(
        _emailCtrl.text.trim(),
        _senhaCtrl.text.trim(),
      );

      if (!mounted) return;

      if (response.user != null) {
        // 2. Criar perfil na tabela usuarios
        await UsuarioService.criarPerfil(
          authId: response.user!.id,
          nome: _nomeCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          cargo: _cargo,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Conta criada com sucesso!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Se já está autenticado, vai direto para o menu
        if (response.session != null) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MenuScreen()),
            (route) => false,
          );
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (!mounted) return;
      String mensagem = 'Erro ao criar conta.';
      final erro = e.toString().toLowerCase();
      if (erro.contains('already registered') ||
          erro.contains('already exists')) {
        mensagem = 'Este e-mail já está cadastrado.';
      } else if (erro.contains('password')) {
        mensagem = 'A senha deve ter pelo menos 6 caracteres.';
      } else if (erro.contains('email')) {
        mensagem = 'E-mail inválido.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
    if (!mounted) return;
    setState(() => _carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              AppColors.primaryLight,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.balance_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'GestãoPrev',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Advocacia Previdenciária',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Card de Registro
                  Container(
                    width: 420,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Criar Conta',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Cadastre-se para acessar o sistema',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Nome
                          TextFormField(
                            controller: _nomeCtrl,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Nome Completo',
                              prefixIcon:
                                  Icon(Icons.person_outlined, size: 20),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Informe seu nome';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // E-mail
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                              prefixIcon:
                                  Icon(Icons.email_outlined, size: 20),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Informe o e-mail';
                              }
                              if (!v.contains('@') || !v.contains('.')) {
                                return 'E-mail inválido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Cargo
                          DropdownButtonFormField<String>(
                            initialValue: _cargo,
                            decoration: const InputDecoration(
                              labelText: 'Cargo',
                              prefixIcon:
                                  Icon(Icons.work_outlined, size: 20),
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
                          const SizedBox(height: 16),

                          // Senha
                          TextFormField(
                            controller: _senhaCtrl,
                            obscureText: !_senhaVisivel,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon:
                                  const Icon(Icons.lock_outlined, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _senhaVisivel
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                    () => _senhaVisivel = !_senhaVisivel),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Informe a senha';
                              }
                              if (v.length < 6) {
                                return 'Mínimo de 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Confirmar Senha
                          TextFormField(
                            controller: _confirmarSenhaCtrl,
                            obscureText: !_senhaVisivel,
                            decoration: const InputDecoration(
                              labelText: 'Confirmar Senha',
                              prefixIcon:
                                  Icon(Icons.lock_outline_rounded, size: 20),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Confirme a senha';
                              }
                              if (v != _senhaCtrl.text) {
                                return 'As senhas não coincidem';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),

                          // Botão Criar Conta
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _carregando ? null : _registrar,
                              child: _carregando
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Criar Conta'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Link para voltar ao login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Já tem uma conta? ',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Text(
                                  'Entrar',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Sistema de Gerenciamento de Dados de Clientes',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
