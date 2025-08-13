class ProdutoModel {
  final String codigo;
  final String nome;
  final double precoVenda;
  final double precoCusto;
  double quantidade;
  final String unidadeMedida;

  ProdutoModel({
    required this.codigo,
    required this.nome,
    required this.precoVenda,
    required this.precoCusto,
    required this.quantidade,
    required this.unidadeMedida,
  });

  // Método toMap: Converte o objeto ProdutoModel para um Map
  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo,
      'nome': nome,
      'precoVenda': precoVenda,
      'precoCusto': precoCusto,
      'quantidade': quantidade,
      'unidadeMedida': unidadeMedida,
    };
  }

  // Método fromMap: Converte um Map para um objeto ProdutoModel
  factory ProdutoModel.fromMap(Map<String, dynamic> map) {
    return ProdutoModel(
      codigo: map['codigo'],
      nome: map['nome'],
      precoVenda: map['precoVenda'],
      precoCusto: map['precoCusto'],
      quantidade: map['quantidade'],
      unidadeMedida: map['unidadeMedida'],
    );
  }

  ProdutoModel copyWith({
    String? codigo,
    String? nome,
    double? precoVenda,
    double? precoCusto,
    double? quantidade,
    String? unidadeMedida,
  }) {
    return ProdutoModel(
      codigo: codigo ?? this.codigo,
      nome: nome ?? this.nome,
      precoVenda: precoVenda ?? this.precoVenda,
      precoCusto: precoCusto ?? this.precoCusto,
      quantidade: quantidade ?? this.quantidade,
      unidadeMedida: unidadeMedida ?? this.unidadeMedida,
    );
  }
}
