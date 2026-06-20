import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/cliente_service.dart';
import '../theme.dart';
import 'cadastro_screen.dart';
import 'lista_clientes_screen.dart';
import 'login_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _totalClientes = 0;
  int _totalPrioritarios = 0;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDashboard();
  }

  Future<void> _carregarDashboard() async {
    try {
      final total = await ClienteService.contarTotal();
      final prioritarios = await ClienteService.contarPrioritarios();
      if (!mounted) return;
      setState(() {
        _totalClientes = total;
        _totalPrioritarios = prioritarios;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _carregando = false);
    }
  }

  Future<void> _logout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sair do Sistema'),
        content: const Text('Deseja realmente sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = AuthService.emailAtual ?? '';
    final nomeUsuario = email.split('@').first;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                child: Row(
                  children: [
                    // Avatar do usuário
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        nomeUsuario.isNotEmpty
                            ? nomeUsuario[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Olá, $nomeUsuario!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            email,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white70,
                      ),
                      tooltip: 'Sair',
                      onPressed: _logout,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Conteúdo principal
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dashboard Cards
                        const Text(
                          'Resumo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _DashboardCard(
                                icone: Icons.people_rounded,
                                titulo: 'Clientes',
                                valor: _carregando
                                    ? '...'
                                    : _totalClientes.toString(),
                                cor: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _DashboardCard(
                                icone: Icons.star_rounded,
                                titulo: 'Prioritários',
                                valor: _carregando
                                    ? '...'
                                    : _totalPrioritarios.toString(),
                                cor: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Menu de Ações
                        const Text(
                          'O que deseja fazer?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _MenuCard(
                          icone: Icons.person_add_rounded,
                          titulo: 'Cadastrar Cliente',
                          descricao:
                              'Registrar novo cliente com dados pessoais',
                          cor: AppColors.primary,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CadastroScreen(),
                              ),
                            );
                            _carregarDashboard();
                          },
                        ),
                        _MenuCard(
                          icone: Icons.people_rounded,
                          titulo: 'Visualizar Clientes',
                          descricao:
                              'Buscar, filtrar e gerenciar todos os clientes',
                          cor: AppColors.success,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ListaClientesScreen(),
                              ),
                            );
                            _carregarDashboard();
                          },
                        ),
                        _MenuCard(
                          icone: Icons.star_rounded,
                          titulo: 'Clientes Prioritários',
                          descricao:
                              'Ver apenas clientes marcados como prioritários',
                          cor: AppColors.gold,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ListaClientesScreen(
                                  filtroInicial: true,
                                ),
                              ),
                            );
                            _carregarDashboard();
                          },
                        ),
                      ],
                    ),
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

// ─── Dashboard Card ──────────────────────────────────────────────────────────

class _DashboardCard extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String valor;
  final Color cor;

  const _DashboardCard({
    required this.icone,
    required this.titulo,
    required this.valor,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cor.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icone, color: cor, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            valor,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Menu Card ───────────────────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String descricao;
  final Color cor;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icone,
    required this.titulo,
    required this.descricao,
    required this.cor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icone, color: cor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descricao,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
