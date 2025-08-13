import 'package:sistema_comercio_2/database/data_access_object/produto_dao.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/models/produtos_model.dart';

class ProdutosController {
  final ProdutoDao _produtoDao = ProdutoDao();

  Future<void> adicionarProduto(ProdutoModel produto) async {
    await _produtoDao.insertProduto(produto);
  }

  Future<List<ProdutoModel>> buscarProdutos() async {
    return await _produtoDao.getAllProdutos();
  }

  Future<ProdutoModel?> buscarProdutoPorCodigo(String codigo) async {
    return await _produtoDao.getProdutoPorCodigo(codigo);
  }

  Future<void> editarProduto(ProdutoModel produto) async {
    await _produtoDao.updateProduto(produto);
  }

  Future<void> removerProduto(String codigo) async {
    await _produtoDao.deleteProduto(codigo);
  }

  /// Inicializa produtos de exemplo no banco
  Future<void> inicializarProdutosDeExemplo() async {
    final produtosExistentes = await buscarProdutos();

    if (produtosExistentes.isEmpty) {
      final exemplos = [
        ProdutoModel(
          codigo: '001',
          nome: 'Papríca Doce',
          precoVenda: 45.00,
          precoCusto: 22.00,
          quantidade: 100,
          unidadeMedida: 'g',
        ),
        ProdutoModel(
          codigo: '002',
          nome: 'Papríca Defumada',
          precoVenda: 45.00,
          precoCusto: 22.50,
          quantidade: 100,
          unidadeMedida: 'g',
        ),
        ProdutoModel(
          codigo: '003',
          nome: 'Vinagre de maçã',
          precoVenda: 38.00,
          precoCusto: 16.00,
          quantidade: 1,
          unidadeMedida: 'un',
        ),
      ];

      for (var produto in exemplos) {
        await adicionarProduto(produto);
      }

      print('Produtos de exemplo adicionados.');
    } else {
      print('Produtos já cadastrados no banco.');
    }
  }
}
