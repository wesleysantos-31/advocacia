import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario.dart';

class UsuarioService {
  static final _client = Supabase.instance.client;

  /// Criar perfil de usuário após registro
  static Future<void> criarPerfil({
    required String authId,
    required String nome,
    required String email,
    String cargo = 'Secretário(a)',
  }) async {
    await _client.from('usuarios').insert({
      'auth_id': authId,
      'nome': nome,
      'email': email,
      'cargo': cargo,
    });
  }

  /// Buscar perfil do usuário logado
  static Future<Usuario?> buscarPerfilAtual() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final dados = await _client
        .from('usuarios')
        .select()
        .eq('auth_id', user.id)
        .maybeSingle();
    if (dados == null) return null;
    return Usuario.fromJson(dados);
  }

  /// Listar todos os usuários
  static Future<List<Usuario>> listar() async {
    final dados = await _client
        .from('usuarios')
        .select()
        .order('nome', ascending: true);
    return (dados as List)
        .map((json) => Usuario.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Buscar usuário por ID
  static Future<Usuario?> buscarPorId(int id) async {
    final dados = await _client
        .from('usuarios')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (dados == null) return null;
    return Usuario.fromJson(dados);
  }

  /// Atualizar dados do usuário
  static Future<void> atualizar(int id, {
    String? nome,
    String? email,
    String? cargo,
  }) async {
    final updates = <String, dynamic>{};
    if (nome != null) updates['nome'] = nome;
    if (email != null) updates['email'] = email;
    if (cargo != null) updates['cargo'] = cargo;
    if (updates.isEmpty) return;
    await _client.from('usuarios').update(updates).eq('id', id);
  }

  /// Deletar usuário (perfil — não deleta o auth user)
  static Future<void> deletar(int id) async {
    await _client.from('usuarios').delete().eq('id', id);
  }

  /// Contagem total de usuários
  static Future<int> contarTotal() async {
    final dados = await _client.from('usuarios').select('id');
    return (dados as List).length;
  }
}
