class Contato {
  final int? id;
  final String nome;
  final String telefone;
  final String? email;
  final bool favorito;
  final String criadoEm;

  const Contato({
    this.id,
    required this.nome,
    required this.telefone,
    this.email,
    this.favorito = false,
    required this.criadoEm,
  });

  Contato copyWith({
    int? id,
    String? nome,
    String? telefone,
    String? email,
    bool? favorito,
    String? criadoEm,
  }) {
    return Contato(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      favorito: favorito ?? this.favorito,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'telefone': telefone,
      'email': email,
      'favorito': favorito ? 1 : 0,
      'criado_em': criadoEm,
    };
  }

  factory Contato.fromMap(Map<String, dynamic> map) {
    return Contato(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      telefone: map['telefone'] as String,
      email: map['email'] as String?,
      favorito: (map['favorito'] as int) == 1,
      criadoEm: map['criado_em'] as String,
    );
  }

  String get iniciais {
    final partes = nome.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nome.isNotEmpty ? nome[0].toUpperCase() : '?';
  }
}
