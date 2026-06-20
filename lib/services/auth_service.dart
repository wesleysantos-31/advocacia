import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _client = Supabase.instance.client;

  /// Usuário atualmente logado
  static User? get usuarioAtual => _client.auth.currentUser;

  /// Email do usuário logado
  static String? get emailAtual => usuarioAtual?.email;

  /// Verifica se há sessão ativa
  static bool get estaLogado => usuarioAtual != null;

  /// Login com email e senha
  static Future<AuthResponse> login(String email, String senha) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: senha,
    );
  }

  /// Registrar novo usuário com email e senha
  static Future<AuthResponse> registrar(String email, String senha) async {
    return await _client.auth.signUp(
      email: email,
      password: senha,
    );
  }

  /// Logout
  static Future<void> logout() async {
    await _client.auth.signOut();
  }

  /// Escuta mudanças de autenticação
  static Stream<AuthState> get onAuthStateChange =>
      _client.auth.onAuthStateChange;
}
