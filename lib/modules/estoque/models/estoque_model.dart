enum TipoMovimentacao { entrada, saida }

class MovimentacaoModel {
  final int? id; // Adicionando o campo id
  final String codigoProduto;
  final TipoMovimentacao tipo;
  final int quantidade;
  final DateTime data;

  MovimentacaoModel({
    this.id,
    required this.codigoProduto,
    required this.tipo,
    required this.quantidade,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'produtoCodigo': codigoProduto,
      'tipo': tipo.name, // Salva o nome do enum como String no banco
      'quantidade': quantidade,
      'data': data.toIso8601String(), // Salva a data como String ISO 8601
    };
  }

  factory MovimentacaoModel.fromMap(Map<String, dynamic> map) {
    return MovimentacaoModel(
      id: map['id'],
      codigoProduto: map['produtoCodigo'],
      tipo: TipoMovimentacao.values.byName(
        map['tipo'],
      ), // Converte String de volta para enum
      quantidade: map['quantidade'],
      data: DateTime.parse(
        map['data'],
      ), // Converte String de volta para DateTime
    );
  }
}
