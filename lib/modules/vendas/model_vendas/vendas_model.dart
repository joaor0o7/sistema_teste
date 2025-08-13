import 'package:sistema_comercio_2/modules/estoque/produtos/models/produtos_model.dart';

class VendaModel {
  int? id;
  Map<ProdutoModel, double> produtos; // Remova o 'final' daqui
  double total;
  final String formaPagamento;
  final String nomeCliente;
  final DateTime dataHora;
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

  // Converte para Map para inserir no banco
  Map<String, dynamic> toMap() {
    // Converter DateTime para String no formato ISO 8601
    String dataHoraString = dataHora.toIso8601String();
    int isPagoInt = isPago ? 1 : 0;

    return {
      'id': id,
      'data': dataHoraString,
      'total': total,
      'formaPagamento': formaPagamento,
      'nomeCliente': nomeCliente,
      'isPago': isPagoInt,
    };
  }

  // Construtor a partir de Map do banco
  factory VendaModel.fromMap(Map<String, dynamic> map) {
    // Converter String de volta para DateTime
    DateTime dataHora = DateTime.parse(map['data']);
    bool isPago = map['isPago'] == 1 ? true : false;

    return VendaModel(
      id: map['id'],
      produtos: {}, // Inicializado vazio, será preenchido em VendaDao
      total: map['total'],
      formaPagamento: map['formaPagamento'],
      nomeCliente: map['nomeCliente'],
      dataHora: dataHora,
      isPago: isPago,
    );
  }
}
