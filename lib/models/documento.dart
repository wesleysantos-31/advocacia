class Documento {
  final int? id;
  final int clienteId;
  final String nome;
  final String tipo;
  final String url;
  final DateTime? createdAt;

  Documento({
    this.id,
    required this.clienteId,
    required this.nome,
    required this.tipo,
    required this.url,
    this.createdAt,
  });

  factory Documento.fromJson(Map<String, dynamic> json) {
    return Documento(
      id: json['id'] as int?,
      clienteId: json['cliente_id'] as int,
      nome: json['nome'] as String? ?? '',
      tipo: json['tipo'] as String? ?? 'Outro',
      url: json['url'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cliente_id': clienteId,
      'nome': nome,
      'tipo': tipo,
      'url': url,
    };
  }

  /// Lista dos tipos de documento disponíveis
  static const List<String> tipos = [
    'RG',
    'CPF',
    'Comprovante de Residência',
    'CTPS',
    'Certidão de Nascimento',
    'Certidão de Casamento',
    'Laudo Médico',
    'Processo',
    'Procuração',
    'Outro',
  ];
}
