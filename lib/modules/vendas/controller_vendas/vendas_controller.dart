import 'package:sistema_comercio_2/modules/estoque/produtos/models/produtos_model.dart';
import 'package:sistema_comercio_2/modules/vendas/model_vendas/vendas_model.dart';

class VendasController {
  final List<VendaModel> _historicoVendas = [];
  final List<VendaModel> _fiados = []; // lista para os fiados

  double calcularPrecoProporcional(
    double precoUnitario,
    double quantidade,
    ProdutoModel produto,
  ) {
    if (produto.unidadeMedida.toLowerCase() == 'g') {
      return (precoUnitario / 1000) * quantidade;
    } else if (produto.unidadeMedida.toLowerCase() == 'kg') {
      return precoUnitario *
          quantidade; // Se já está em KG, não precisa dividir por 1000
    } else if (produto.unidadeMedida.toLowerCase() == 'unidade' ||
        produto.unidadeMedida.toLowerCase() == 'un') {
      return precoUnitario * quantidade; // Para unidades, o preço é direto
    } else {
      // Caso a unidade de medida não seja reconhecida, você pode decidir como tratar
      // Por padrão, vamos retornar o preço unitário multiplicado pela quantidade
      return precoUnitario * quantidade;
    }
  }

  void salvarVenda({
    required Map<ProdutoModel, double> produtos,
    required double total,
    required String formaPagamento,
    required String nomeCliente,
  }) {
    final venda = VendaModel(
      produtos: Map.from(produtos),
      total: total,
      formaPagamento: formaPagamento,
      nomeCliente: nomeCliente,
      dataHora: DateTime.now(),
    );

    _historicoVendas.add(venda);
    if (formaPagamento == 'Fiado') {
      // Verificasse a forma de pagamento é "Fiado"
      _fiados.add(venda); // Adiciona à lista de fiados
    }
  }

  List<VendaModel> get historico => List.unmodifiable(_historicoVendas);
  List<VendaModel> get fiados =>
      List.unmodifiable(_fiados); // Adiciona um getter para a lista de fiados
}
