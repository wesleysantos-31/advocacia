import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cliente.dart';
import 'auth_service.dart';

class ClienteService {
  static final _client = Supabase.instance.client;

  /// Cadastrar novo cliente
  static Future<void> cadastrar(Cliente cliente) async {
    await _client.from('clientes').insert(cliente.toJson());
  }

  /// Listar clientes com busca e filtro de prioridade
  static Future<List<Cliente>> listar({
    String? busca,
    bool? soPrioritarios,
    String ordenarPor = 'nome',
    bool ascendente = true,
  }) async {
    var query = _client.from('clientes').select();

    if (soPrioritarios == true) {
      query = query.eq('prioridade', true);
    }

    if (busca != null && busca.trim().isNotEmpty) {
      final termoBusca = busca.trim();
      query = query.or('nome.ilike.%$termoBusca%,cpf.ilike.%$termoBusca%');
    }

    final dados = await query.order(ordenarPor, ascending: ascendente);

    return (dados as List)
        .map((json) => Cliente.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Buscar cliente por ID
  static Future<Cliente?> buscarPorId(int id) async {
    final dados = await _client
        .from('clientes')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (dados == null) return null;
    return Cliente.fromJson(dados);
  }

  /// Atualizar cliente e registrar histórico de alterações
  static Future<void> atualizar(Cliente antigo, Cliente novo) async {
    // Compara campos e registra no histórico
    final camposAntigos = antigo.camposParaHistorico;
    final camposNovos = novo.camposParaHistorico;

    final registros = <Map<String, dynamic>>[];
    for (final campo in camposAntigos.keys) {
      final valorAntigo = camposAntigos[campo] ?? '';
      final valorNovo = camposNovos[campo] ?? '';
      if (valorAntigo != valorNovo) {
        registros.add({
          'cliente_id': antigo.id,
          'campo': campo,
          'valor_anterior': valorAntigo,
          'valor_novo': valorNovo,
          'usuario': AuthService.emailAtual ?? 'desconhecido',
        });
      }
    }

    // Atualiza o cliente
    final dadosUpdate = novo.toJson();
    dadosUpdate['updated_at'] = DateTime.now().toIso8601String();
    await _client.from('clientes').update(dadosUpdate).eq('id', antigo.id!);

    // Insere os registros de histórico
    if (registros.isNotEmpty) {
      await _client.from('historico').insert(registros);
    }
  }

  /// Deletar cliente
  static Future<void> deletar(int id) async {
    await _client.from('clientes').delete().eq('id', id);
  }

  /// Alternar prioridade do cliente
  static Future<void> alternarPrioridade(int id, bool valor) async {
    await _client.from('clientes').update({
      'prioridade': valor,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);

    // Registra no histórico
    await _client.from('historico').insert({
      'cliente_id': id,
      'campo': 'Prioridade',
      'valor_anterior': valor ? 'Não' : 'Sim',
      'valor_novo': valor ? 'Sim' : 'Não',
      'usuario': AuthService.emailAtual ?? 'desconhecido',
    });
  }

  /// Buscar histórico de alterações de um cliente
  static Future<List<Map<String, dynamic>>> buscarHistorico(
      int clienteId) async {
    final dados = await _client
        .from('historico')
        .select()
        .eq('cliente_id', clienteId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(dados);
  }

  /// Contagem total de clientes
  static Future<int> contarTotal() async {
    final dados = await _client.from('clientes').select('id');
    return (dados as List).length;
  }

  /// Contagem de clientes prioritários
  static Future<int> contarPrioritarios() async {
    final dados =
        await _client.from('clientes').select('id').eq('prioridade', true);
    return (dados as List).length;
  }
}
