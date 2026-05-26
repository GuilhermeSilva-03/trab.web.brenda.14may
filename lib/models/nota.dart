class Nota {
  final int? id;
  final String titulo;
  final String conteudo;
  final String? imagemPath;
  final String criadoEm;
  final String atualizadoEm;

  const Nota({
    this.id,
    required this.titulo,
    required this.conteudo,
    this.imagemPath,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  Nota copyWith({
    int? id,
    String? titulo,
    String? conteudo,
    String? imagemPath,
    bool clearImagem = false,
    String? criadoEm,
    String? atualizadoEm,
  }) {
    return Nota(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      conteudo: conteudo ?? this.conteudo,
      imagemPath: clearImagem ? null : (imagemPath ?? this.imagemPath),
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'conteudo': conteudo,
      'imagem_path': imagemPath,
      'criado_em': criadoEm,
      'atualizado_em': atualizadoEm,
    };
  }

  factory Nota.fromMap(Map<String, dynamic> map) {
    return Nota(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      conteudo: map['conteudo'] as String,
      imagemPath: map['imagem_path'] as String?,
      criadoEm: map['criado_em'] as String,
      atualizadoEm: map['atualizado_em'] as String,
    );
  }

  String get resumo {
    if (conteudo.length <= 80) return conteudo;
    return '${conteudo.substring(0, 80)}...';
  }
}
