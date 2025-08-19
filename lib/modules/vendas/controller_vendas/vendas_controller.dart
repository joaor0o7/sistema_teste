import 'package:flutter/material.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/models/produtos_model.dart';
import 'package:sistema_comercio_2/modules/vendas/model_vendas/vendas_model.dart';
import 'package:sistema_comercio_2/database/data_access_object/venda_dao.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/controllers/produtos_controller.dart';

class VendasController extends ChangeNotifier {
  final VendaDao _vendaDao = VendaDao();
  final ProdutosController produtosController;

  VendasController({required this.produtosController});

  final List<VendaModel> _historicoVendas = [];
  final List<VendaModel> _fiados = [];

  List<VendaModel> get historico => List.unmodifiable(_historicoVendas);
  List<VendaModel> get fiados => List.unmodifiable(_fiados);

  // Calcula preço proporcional baseado na unidade de medida
  double calcularPrecoProporcional(
    double precoUnitario,
    double quantidade,
    ProdutoModel produto,
  ) {
    switch (produto.unidadeMedida.toLowerCase()) {
      case 'g':
        return (precoUnitario / 1000) * quantidade;
      case 'kg':
      case 'unidade':
      case 'un':
        return precoUnitario * quantidade;
      default:
        return precoUnitario * quantidade;
    }
  }

  // Salva venda no banco e na lista local
  Future<void> salvarVenda({
    required Map<ProdutoModel, double> produtos,
    required double total,
    required String formaPagamento,
    String nomeCliente = '',
  }) async {
    final isPago = formaPagamento.toLowerCase() != 'fiado';

    final venda = VendaModel(
      produtos: produtos,
      total: total,
      formaPagamento: formaPagamento,
      nomeCliente: nomeCliente,
      dataHora: DateTime.now(),
      isPago: isPago,
    );

    await _vendaDao.insertVenda(venda);

    _historicoVendas.add(venda);
    if (!isPago) {
      _fiados.add(venda);
    }

    notifyListeners();
  }

  // Carrega produtos e histórico do banco
  Future<void> carregarHistoricoCompleto() async {
    await produtosController.buscarProdutos();

    final vendasDoBanco = await _vendaDao.getAllVendas(
      produtosController.produtos,
    );

    _historicoVendas
      ..clear()
      ..addAll(vendasDoBanco);

    _fiados
      ..clear()
      ..addAll(
        vendasDoBanco.where(
          (v) => v.formaPagamento.toLowerCase() == 'fiado' && !v.isPago,
        ),
      );

    notifyListeners();
  }

  // Atualiza uma venda existente (ex.: editar valor ou marcar como pago)
  Future<void> atualizarVenda(VendaModel venda) async {
    if (venda.id != null) {
      await _vendaDao.updateVenda(venda); // Update direto
      await carregarHistoricoCompleto();
    }
  }

  // Marca um fiado como pago
  Future<void> pagarFiado(VendaModel venda) async {
    if (!venda.isPago && venda.id != null) {
      await _vendaDao.marcarComoPago(venda.id!);
      venda.isPago = true;
      _fiados.remove(venda);
      notifyListeners();
    }
  }
}
