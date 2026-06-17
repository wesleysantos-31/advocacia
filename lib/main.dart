import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://rfjjnlyklozbmqddohky.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJmampubHlrbG96Ym1xZGRvaGt5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE2NDMyMzIsImV4cCI6MjA5NzIxOTIzMn0.s9aAunOy_0wvbs0V8ZkFb9k_IQly4q-nGVQ3Ed-4e7I';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GestãoPrev',
      home: const HomeScreen(),
    );
  }
}

// ─── Tela Inicial ─────────────────────────────────────────────────────────────

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B3A6B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.balance_rounded, color: Colors.white, size: 70),
            const SizedBox(height: 20),
            const Text(
              'GestãoPrev',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Advocacia Previdenciária',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MenuScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1B3A6B),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Inicie Aqui',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tela de Menu ─────────────────────────────────────────────────────────────

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B3A6B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B3A6B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Menu Principal'),
      ),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.account_balance,
                size: 60,
                color: Color(0xFF1B3A6B),
              ),
              const SizedBox(height: 20),
              const Text(
                'O que deseja fazer?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B3A6B),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Cadastrar Cliente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B3A6B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CadastroScreen()),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.people),
                  label: const Text('Visualizar Clientes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ListaClientesScreen(),
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

// ─── Tela de Cadastro ─────────────────────────────────────────────────────────

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _nomeCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _carregando = false;

  Future<void> _cadastrar() async {
    if (_nomeCtrl.text.isEmpty ||
        _cpfCtrl.text.isEmpty ||
        _senhaCtrl.text.isEmpty) {
      _mostrarMensagem('Preencha todos os campos.', erro: true);
      return;
    }
    setState(() => _carregando = true);
    try {
      await Supabase.instance.client.from('clientes').insert({
        'nome': _nomeCtrl.text.trim(),
        'cpf': _cpfCtrl.text.trim(),
        'senha_gov': _senhaCtrl.text.trim(),
      });
      _nomeCtrl.clear();
      _cpfCtrl.clear();
      _senhaCtrl.clear();
      if (!mounted) return;
      _mostrarMensagem('Cliente cadastrado com sucesso!');
    } catch (e) {
      if (!mounted) return;
      _mostrarMensagem('Erro: $e', erro: true);
    }
    if (!mounted) return;
    setState(() => _carregando = false);
  }

  void _mostrarMensagem(String msg, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: erro ? Colors.red : Colors.green,
      ),
    );
  }

  Widget _campo(
    String label,
    TextEditingController ctrl,
    IconData icone, {
    bool senha = false,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: senha,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icone),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B3A6B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B3A6B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Cadastro de Cliente'),
      ),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _campo('Nome Completo', _nomeCtrl, Icons.person),
              const SizedBox(height: 15),
              _campo('CPF', _cpfCtrl, Icons.badge),
              const SizedBox(height: 15),
              _campo('Senha GOV', _senhaCtrl, Icons.lock, senha: true),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _cadastrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B3A6B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _carregando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Cadastrar', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tela de Listagem ─────────────────────────────────────────────────────────

class ListaClientesScreen extends StatefulWidget {
  const ListaClientesScreen({super.key});

  @override
  State<ListaClientesScreen> createState() => _ListaClientesScreenState();
}

class _ListaClientesScreenState extends State<ListaClientesScreen> {
  List<dynamic> clientes = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarClientes();
  }

  Future<void> carregarClientes() async {
    setState(() => carregando = true);
    try {
      final dados = await Supabase.instance.client
          .from('clientes')
          .select('id, nome, cpf, senha_gov')
          .order('id', ascending: false);
      if (!mounted) return;
      setState(() => clientes = dados);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao carregar clientes.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    if (!mounted) return;
    setState(() => carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B3A6B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B3A6B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Clientes Cadastrados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: carregarClientes,
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : clientes.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline, color: Colors.white38, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum cliente cadastrado',
                    style: TextStyle(color: Colors.white60, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: clientes.length,
              itemBuilder: (context, index) {
                final cliente = clientes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetalhesClienteScreen(cliente: cliente),
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF1B3A6B),
                      child: Text(
                        cliente['nome'].toString()[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      cliente['nome'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('CPF: ${cliente['cpf'].toString()}'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ─── Tela de Detalhes do Cliente ──────────────────────────────────────────────

class DetalhesClienteScreen extends StatefulWidget {
  final Map<String, dynamic> cliente;
  const DetalhesClienteScreen({super.key, required this.cliente});

  @override
  State<DetalhesClienteScreen> createState() => _DetalhesClienteScreenState();
}

class _DetalhesClienteScreenState extends State<DetalhesClienteScreen> {
  bool _senhaVisivel = false;

  @override
  Widget build(BuildContext context) {
    final inicial = (widget.cliente['nome'] as String)[0].toUpperCase();
    final senha = widget.cliente['senha_gov'] ?? '-';

    return Scaffold(
      backgroundColor: const Color(0xFF1B3A6B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B3A6B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Detalhes do Cliente'),
      ),
      body: Center(
        child: Container(
          width: 420,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF1B3A6B),
                child: Text(
                  inicial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.cliente['nome'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B3A6B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),

              // CPF
              Row(
                children: [
                  const Icon(Icons.badge, color: Color(0xFF1B3A6B), size: 22),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CPF',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        (widget.cliente['cpf'] ?? '-').toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Senha GOV com botão de olho
              Row(
                children: [
                  const Icon(Icons.lock, color: Color(0xFF1B3A6B), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Senha GOV',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          _senhaVisivel ? senha : '••••••••',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        setState(() => _senhaVisivel = !_senhaVisivel),
                    icon: Icon(
                      _senhaVisivel ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF1B3A6B),
                    ),
                    tooltip: _senhaVisivel ? 'Ocultar senha' : 'Ver senha',
                  ),
                ],
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Voltar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B3A6B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
