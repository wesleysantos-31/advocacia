import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../services/cliente_service.dart';
import '../theme.dart';
import '../widgets/cliente_card.dart';
import 'detalhes_cliente_screen.dart';

class ListaClientesScreen extends StatefulWidget {
  final bool filtroInicial;
  const ListaClientesScreen({super.key, this.filtroInicial = false});

  @override
  State<ListaClientesScreen> createState() => _ListaClientesScreenState();
}

class _ListaClientesScreenState extends State<ListaClientesScreen> {
  List<Cliente> _clientes = [];
  bool _carregando = true;
  final _buscaCtrl = TextEditingController();
  late bool _soPrioritarios;
  String _ordenarPor = 'nome';
  bool _ascendente = true;

  @override
  void initState() {
    super.initState();
    _soPrioritarios = widget.filtroInicial;
    _carregarClientes();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarClientes() async {
    setState(() => _carregando = true);
    try {
      final clientes = await ClienteService.listar(
        busca: _buscaCtrl.text,
        soPrioritarios: _soPrioritarios ? true : null,
        ordenarPor: _ordenarPor,
        ascendente: _ascendente,
      );
      if (!mounted) return;
      setState(() => _clientes = clientes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erro ao carregar clientes.'),
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
        title: Text(
          _soPrioritarios ? 'Clientes Prioritários' : 'Clientes Cadastrados',
        ),
        actions: [
          // Menu de ordenação
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Ordenar',
            onSelected: (value) {
              setState(() {
                if (value == _ordenarPor) {
                  _ascendente = !_ascendente;
                } else {
                  _ordenarPor = value;
                  _ascendente = true;
                }
              });
              _carregarClientes();
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'nome',
                child: Row(
                  children: [
                    Icon(
                      _ordenarPor == 'nome'
                          ? (_ascendente
                              ? Icons.arrow_upward
                              : Icons.arrow_downward)
                          : Icons.sort_by_alpha,
                      size: 18,
                      color: _ordenarPor == 'nome'
                          ? AppColors.primary
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    const Text('Por Nome'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'created_at',
                child: Row(
                  children: [
                    Icon(
                      _ordenarPor == 'created_at'
                          ? (_ascendente
                              ? Icons.arrow_upward
                              : Icons.arrow_downward)
                          : Icons.calendar_today,
                      size: 18,
                      color: _ordenarPor == 'created_at'
                          ? AppColors.primary
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    const Text('Por Data'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Atualizar',
            onPressed: _carregarClientes,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de busca e filtros
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Campo de busca
                TextField(
                  controller: _buscaCtrl,
                  onChanged: (_) => _carregarClientes(),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome ou CPF...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    suffixIcon: _buscaCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            onPressed: () {
                              _buscaCtrl.clear();
                              _carregarClientes();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Toggle prioritários
                Row(
                  children: [
                    FilterChip(
                      label: const Text('Prioritários'),
                      selected: _soPrioritarios,
                      onSelected: (v) {
                        setState(() => _soPrioritarios = v);
                        _carregarClientes();
                      },
                      avatar: Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: _soPrioritarios
                            ? Colors.white
                            : AppColors.gold,
                      ),
                      selectedColor: AppColors.gold,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _soPrioritarios ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      side: BorderSide.none,
                    ),
                    const Spacer(),
                    Text(
                      '${_clientes.length} cliente${_clientes.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de clientes
          Expanded(
            child: _carregando
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _clientes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _buscaCtrl.text.isNotEmpty
                                  ? Icons.search_off_rounded
                                  : Icons.people_outline_rounded,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _buscaCtrl.text.isNotEmpty
                                  ? 'Nenhum resultado encontrado'
                                  : 'Nenhum cliente cadastrado',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _carregarClientes,
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _clientes.length,
                          itemBuilder: (context, index) {
                            final cliente = _clientes[index];
                            return ClienteCard(
                              cliente: cliente,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetalhesClienteScreen(
                                      clienteId: cliente.id!,
                                    ),
                                  ),
                                );
                                _carregarClientes();
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
