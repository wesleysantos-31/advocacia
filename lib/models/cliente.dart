class Cliente {
  final int? id;
  final String nome;
  final String cpf;
  final String? rg;
  final String? dataNascimento;
  final String? nitPis;
  final String? estadoCivil;
  final String? telefone;
  final String? email;
  final String? endereco;
  final String? senhaGov;
  final String? observacoes;
  final bool prioridade;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Cliente({
    this.id,
    required this.nome,
    required this.cpf,
    this.rg,
    this.dataNascimento,
    this.nitPis,
    this.estadoCivil,
    this.telefone,
    this.email,
    this.endereco,
    this.senhaGov,
    this.observacoes,
    this.prioridade = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] as int?,
      nome: json['nome'] as String? ?? '',
      cpf: json['cpf'] as String? ?? '',
      rg: json['rg'] as String?,
      dataNascimento: json['data_nascimento'] as String?,
      nitPis: json['nit_pis'] as String?,
      estadoCivil: json['estado_civil'] as String?,
      telefone: json['telefone'] as String?,
      email: json['email'] as String?,
      endereco: json['endereco'] as String?,
      senhaGov: json['senha_gov'] as String?,
      observacoes: json['observacoes'] as String?,
      prioridade: json['prioridade'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'cpf': cpf,
      'rg': rg,
      'data_nascimento': dataNascimento,
      'nit_pis': nitPis,
      'estado_civil': estadoCivil,
      'telefone': telefone,
      'email': email,
      'endereco': endereco,
      'senha_gov': senhaGov,
      'observacoes': observacoes,
      'prioridade': prioridade,
    };
  }

  Cliente copyWith({
    int? id,
    String? nome,
    String? cpf,
    String? rg,
    String? dataNascimento,
    String? nitPis,
    String? estadoCivil,
    String? telefone,
    String? email,
    String? endereco,
    String? senhaGov,
    String? observacoes,
    bool? prioridade,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cliente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cpf: cpf ?? this.cpf,
      rg: rg ?? this.rg,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      nitPis: nitPis ?? this.nitPis,
      estadoCivil: estadoCivil ?? this.estadoCivil,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      endereco: endereco ?? this.endereco,
      senhaGov: senhaGov ?? this.senhaGov,
      observacoes: observacoes ?? this.observacoes,
      prioridade: prioridade ?? this.prioridade,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Retorna um mapa legível dos campos para comparação no histórico
  Map<String, String?> get camposParaHistorico => {
        'Nome': nome,
        'CPF': cpf,
        'RG': rg,
        'Data de Nascimento': dataNascimento,
        'NIT/PIS': nitPis,
        'Estado Civil': estadoCivil,
        'Telefone': telefone,
        'E-mail': email,
        'Endereço': endereco,
        'Senha GOV': senhaGov,
        'Observações': observacoes,
        'Prioridade': prioridade ? 'Sim' : 'Não',
      };
}
