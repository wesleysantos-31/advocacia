import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'menu_screen.dart';
import 'registro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
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
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      await AuthService.login(
        _emailCtrl.text.trim(),
        _senhaCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MenuScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      String mensagem = 'E-mail ou senha incorretos.';
      final erro = e.toString().toLowerCase();
      if (erro.contains('email not confirmed')) {
        mensagem = 'E-mail não confirmado. Verifique sua caixa de entrada ou desabilite a confirmação no Supabase.';
      } else if (erro.contains('invalid login')) {
        mensagem = 'E-mail ou senha incorretos.';
      } else if (erro.contains('user not found')) {
        mensagem = 'Usuário não encontrado. Crie uma conta primeiro.';
      } else if (erro.contains('too many requests')) {
        mensagem = 'Muitas tentativas. Aguarde um momento.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
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

                  // Card de Login
                  Container(
                    width: 400,
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
                            'Acessar Sistema',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Entre com suas credenciais',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                              prefixIcon: Icon(Icons.email_outlined, size: 20),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Informe o e-mail' : null,
                          ),
                          const SizedBox(height: 16),
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
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Informe a senha' : null,
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _carregando ? null : _entrar,
                              child: _carregando
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Entrar'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Link para criar conta
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Não tem conta? ',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegistroScreen(),
                                  ),
                                ),
                                child: const Text(
                                  'Criar conta',
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
