import 'dart:convert';
import 'package:sistema_comercio_2/modules/estoque/produtos/models/produtos_model.dart';

class VendaModel {
  int? id;
  Map<ProdutoModel, double> produtos;
  double total;
  String formaPagamento;
  String nomeCliente;
  DateTime dataHora;
  bool isPago;

  VendaModel({
    this.id,
    required this.produtos,
    required this.total,
    required this.formaPagamento,
    required this.nomeCliente,
    required this.dataHora,
    this.isPago = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total': total,
      'formaPagamento': formaPagamento,
      'nomeCliente': nomeCliente,
      'dataHora': dataHora.toIso8601String(),
      'isPago': isPago ? 1 : 0,
      'produtos': jsonEncode(
        produtos.map((produto, qtd) => MapEntry(produto.codigo, qtd)),
      ),
    };
  }

  factory VendaModel.fromMap(Map<String, dynamic> map) {
    return VendaModel(
      id: map['id'] as int?,
      total: (map['total'] as num).toDouble(),
      formaPagamento: map['formaPagamento'] ?? '',
      nomeCliente: map['nomeCliente'] ?? '',
      dataHora: DateTime.parse(map['dataHora']),
      isPago: (map['isPago'] ?? 0) == 1,
      produtos:
          map['produtos'] != null
              ? (jsonDecode(map['produtos']) as Map<String, dynamic>).map(
                (codigo, qtd) => MapEntry(
                  ProdutoModel(
                    codigo: codigo,
                    nome: '',
                    precoVenda: 0,
                    precoCusto: 0,
                    quantidade: 0,
                    unidadeMedida: '',
                  ),
                  (qtd as num).toDouble(),
                ),
              )
              : {},
    );
  }
}
