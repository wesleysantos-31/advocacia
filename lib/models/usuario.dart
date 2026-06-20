class Usuario {
  final int? id;
  final String authId;
  final String nome;
  final String email;
  final String cargo;
  final DateTime? createdAt;

  Usuario({
    this.id,
    required this.authId,
    required this.nome,
    required this.email,
    this.cargo = 'Secretário(a)',
    this.createdAt,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int?,
      authId: json['auth_id'] as String? ?? '',
      nome: json['nome'] as String? ?? '',
      email: json['email'] as String? ?? '',
      cargo: json['cargo'] as String? ?? 'Secretário(a)',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auth_id': authId,
      'nome': nome,
      'email': email,
      'cargo': cargo,
    };
  }

  Usuario copyWith({
    int? id,
    String? authId,
    String? nome,
    String? email,
    String? cargo,
    DateTime? createdAt,
  }) {
    return Usuario(
      id: id ?? this.id,
      authId: authId ?? this.authId,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      cargo: cargo ?? this.cargo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Cargos disponíveis
  static const List<String> cargos = [
    'Advogado(a)',
    'Secretário(a)',
    'Estagiário(a)',
    'Administrador(a)',
  ];
}
