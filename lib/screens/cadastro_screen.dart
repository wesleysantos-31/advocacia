import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../models/cliente.dart';
import '../services/cliente_service.dart';
import '../theme.dart';
import '../widgets/campo_texto.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _rgCtrl = TextEditingController();
  final _dataNascCtrl = TextEditingController();
  final _nitPisCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _enderecoCtrl = TextEditingController();
  final _senhaGovCtrl = TextEditingController();
  final _observacoesCtrl = TextEditingController();
  String? _estadoCivil;
  bool _prioridade = false;
  bool _carregando = false;
  bool _senhaVisivel = false;

  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  final _telMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  final _dataMask = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  static const _estadosCivis = [
    'Solteiro(a)',
    'Casado(a)',
    'Divorciado(a)',
    'Viúvo(a)',
    'União Estável',
  ];

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _cpfCtrl.dispose();
    _rgCtrl.dispose();
    _dataNascCtrl.dispose();
    _nitPisCtrl.dispose();
    _telefoneCtrl.dispose();
    _emailCtrl.dispose();
    _enderecoCtrl.dispose();
    _senhaGovCtrl.dispose();
    _observacoesCtrl.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);
    try {
      final cliente = Cliente(
        nome: _nomeCtrl.text.trim(),
        cpf: _cpfCtrl.text.trim(),
        rg: _rgCtrl.text.trim().isEmpty ? null : _rgCtrl.text.trim(),
        dataNascimento: _dataNascCtrl.text.trim().isEmpty
            ? null
            : _dataNascCtrl.text.trim(),
        nitPis:
            _nitPisCtrl.text.trim().isEmpty ? null : _nitPisCtrl.text.trim(),
        estadoCivil: _estadoCivil,
        telefone: _telefoneCtrl.text.trim().isEmpty
            ? null
            : _telefoneCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        endereco: _enderecoCtrl.text.trim().isEmpty
            ? null
            : _enderecoCtrl.text.trim(),
        senhaGov: _senhaGovCtrl.text.trim().isEmpty
            ? null
            : _senhaGovCtrl.text.trim(),
        observacoes: _observacoesCtrl.text.trim().isEmpty
            ? null
            : _observacoesCtrl.text.trim(),
        prioridade: _prioridade,
      );

      await ClienteService.cadastrar(cliente);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Cliente cadastrado com sucesso!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar: $e'),
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
      appBar: AppBar(
        title: const Text('Cadastrar Cliente'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Seção: Dados Pessoais
                _secaoTitulo('Dados Pessoais', Icons.person_rounded),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CampoTexto(
                          label: 'Nome Completo *',
                          controller: _nomeCtrl,
                          icone: Icons.person_outlined,
                          validador: (v) =>
                              v == null || v.isEmpty ? 'Informe o nome' : null,
                        ),
                        const SizedBox(height: 14),
                        CampoTexto(
                          label: 'CPF *',
                          controller: _cpfCtrl,
                          icone: Icons.badge_outlined,
                          teclado: TextInputType.number,
                          formatters: [_cpfMask],
                          validador: (v) =>
                              v == null || v.isEmpty ? 'Informe o CPF' : null,
                        ),
                        const SizedBox(height: 14),
                        CampoTexto(
                          label: 'RG',
                          controller: _rgCtrl,
                          icone: Icons.credit_card_outlined,
                        ),
                        const SizedBox(height: 14),
                        CampoTexto(
                          label: 'Data de Nascimento',
                          controller: _dataNascCtrl,
                          icone: Icons.calendar_today_outlined,
                          teclado: TextInputType.number,
                          formatters: [_dataMask],
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: _estadoCivil,
                          decoration: const InputDecoration(
                            labelText: 'Estado Civil',
                            prefixIcon:
                                Icon(Icons.favorite_border_rounded, size: 20),
                          ),
                          items: _estadosCivis
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _estadoCivil = v),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Seção: Dados Previdenciários
                _secaoTitulo(
                    'Dados Previdenciários', Icons.account_balance_rounded),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CampoTexto(
                          label: 'NIT / PIS',
                          controller: _nitPisCtrl,
                          icone: Icons.numbers_rounded,
                          teclado: TextInputType.number,
                        ),
                        const SizedBox(height: 14),
                        CampoTexto(
                          label: 'Senha GOV.BR',
                          controller: _senhaGovCtrl,
                          icone: Icons.lock_outlined,
                          obscureText: !_senhaVisivel,
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
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Seção: Contato
                _secaoTitulo('Contato', Icons.phone_rounded),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CampoTexto(
                          label: 'Telefone',
                          controller: _telefoneCtrl,
                          icone: Icons.phone_outlined,
                          teclado: TextInputType.phone,
                          formatters: [_telMask],
                        ),
                        const SizedBox(height: 14),
                        CampoTexto(
                          label: 'E-mail',
                          controller: _emailCtrl,
                          icone: Icons.email_outlined,
                          teclado: TextInputType.emailAddress,
                          validador: (v) {
                            if (v != null && v.isNotEmpty) {
                              final regex =
                                  RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!regex.hasMatch(v)) {
                                return 'E-mail inválido (ex: cliente@gmail.com)';
                              }
                              final dominio = v.split('@').last.toLowerCase();
                              if (dominio == 'gmaill.com' || dominio == 'gmail.com.br') {
                                return 'Você quis dizer @gmail.com?';
                              }
                              if (dominio == 'hotmal.com') {
                                return 'Você quis dizer @hotmail.com?';
                              }
                              if (dominio == 'outlok.com') {
                                return 'Você quis dizer @outlook.com?';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        CampoTexto(
                          label: 'Endereço',
                          controller: _enderecoCtrl,
                          icone: Icons.home_outlined,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Seção: Observações e Prioridade
                _secaoTitulo('Observações', Icons.notes_rounded),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CampoTexto(
                          label: 'Observações',
                          controller: _observacoesCtrl,
                          icone: Icons.edit_note_rounded,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 14),
                        SwitchListTile(
                          title: const Text(
                            'Marcar como Prioritário',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: const Text(
                            'Clientes prioritários aparecem em destaque',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: _prioridade,
                          activeThumbColor: AppColors.gold,
                          secondary: Icon(
                            _prioridade
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: _prioridade
                                ? AppColors.gold
                                : AppColors.textSecondary,
                          ),
                          onChanged: (v) =>
                              setState(() => _prioridade = v),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Botão Cadastrar
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _carregando ? null : _cadastrar,
                    icon: _carregando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(
                      _carregando ? 'Salvando...' : 'Cadastrar Cliente',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
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
