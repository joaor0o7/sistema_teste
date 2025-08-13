import 'package:sistema_comercio_2/modules/estoque/models/estoque_model.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/controllers/produtos_controller.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/models/produtos_model.dart';

class EstoqueController {
  final List<MovimentacaoModel> _movimentacoes = [];
  final ProdutosController produtosController;

  EstoqueController({required this.produtosController});

  List<MovimentacaoModel> get movimentacoes =>
      List.unmodifiable(_movimentacoes);

  Future<void> registrarMovimentacao(MovimentacaoModel movimentacao) async {
    _movimentacoes.add(movimentacao);

    // Obtém os produtos de forma assíncrona
    final produtos = await produtosController.buscarProdutos();

    final index = produtos.indexWhere(
      (p) => p.codigo == movimentacao.codigoProduto,
    );

    if (index == -1) {
      throw Exception('Produto não encontrado');
    }

    final produto = produtos[index];
    final novaQuantidade =
        movimentacao.tipo == TipoMovimentacao.entrada
            ? produto.quantidade + movimentacao.quantidade
            : produto.quantidade - movimentacao.quantidade;

    if (novaQuantidade < 0) {
      throw Exception(
        'Quantidade insuficiente no estoque para ${produto.nome}',
      );
    }

    final produtoAtualizado = ProdutoModel(
      codigo: produto.codigo,
      nome: produto.nome,
      precoVenda: produto.precoVenda,
      precoCusto: produto.precoCusto,
      quantidade: novaQuantidade,
      unidadeMedida:
          produto.unidadeMedida, // mantém unidade do produto original
    );

    await produtosController.editarProduto(produtoAtualizado);

    print(
      'Movimentação registrada: ${movimentacao.tipo.name.toUpperCase()} de ${movimentacao.quantidade} ${produto.unidadeMedida} para ${produto.nome}. Novo saldo: $novaQuantidade',
    );
  }

  void limparMovimentacoes() {
    _movimentacoes.clear();
  }
}
