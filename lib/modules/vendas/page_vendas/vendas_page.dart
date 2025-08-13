import 'package:flutter/material.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/controllers/produtos_controller.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/models/produtos_model.dart';
import 'package:sistema_comercio_2/modules/vendas/widgets/produto_item_venda.dart';
import 'package:sistema_comercio_2/modules/vendas/widgets/produto_disponivel_item.dart';
import 'package:sistema_comercio_2/modules/vendas/controller_vendas/vendas_controller.dart';
import 'package:sistema_comercio_2/modules/vendas/widgets/finalizar_vendas_dialog.dart';
import 'package:sistema_comercio_2/modules/vendas/page_vendas/fiado_page.dart';
import 'package:sistema_comercio_2/modules/vendas/page_vendas/historico_vendas.dart';

class VendasPage extends StatefulWidget {
  final ProdutosController produtosController;
  final VendasController vendasController;

  const VendasPage({
    super.key,
    required this.produtosController,
    required this.vendasController,
  });

  @override
  State<VendasPage> createState() => _VendasPageState();
}

class _VendasPageState extends State<VendasPage> {
  final Map<ProdutoModel, double> _produtosNaVenda = {};
  final TextEditingController _buscaController = TextEditingController();
  List<ProdutoModel> _todosProdutos = [];

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
    _buscaController.addListener(() => setState(() {}));
  }

  Future<void> _carregarProdutos() async {
    final produtos = await widget.produtosController.buscarProdutos();
    setState(() {
      _todosProdutos = produtos;
    });
  }

  void _adicionarProduto(ProdutoModel produto, double quantidade) {
    setState(() {
      if (_produtosNaVenda.containsKey(produto)) {
        _produtosNaVenda[produto] = (_produtosNaVenda[produto]! + quantidade);
      } else {
        _produtosNaVenda[produto] = quantidade;
      }
      produto.quantidade -= quantidade.toInt();
    });
  }

  void _removerProduto(ProdutoModel produto) {
    setState(() {
      produto.quantidade += _produtosNaVenda[produto]!.toInt();
      _produtosNaVenda.remove(produto);
    });
  }

  void _limparCarrinho() {
    setState(() {
      _produtosNaVenda.forEach((produto, qtd) {
        produto.quantidade += qtd.toInt();
      });
      _produtosNaVenda.clear();
    });
  }

  void _editarQuantidade(ProdutoModel produto) {
    final TextEditingController qtdController = TextEditingController(
      text: _produtosNaVenda[produto]?.toStringAsFixed(2) ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar quantidade de ${produto.nome}'),
          content: TextField(
            controller: qtdController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Quantidade em ${produto.unidadeMedida}',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final novaQtd = double.tryParse(qtdController.text);
                if (novaQtd != null && novaQtd >= 0) {
                  setState(() {
                    final atual = _produtosNaVenda[produto]!;
                    final diff = novaQtd - atual;
                    produto.quantidade -= diff.toInt();
                    _produtosNaVenda[produto] = novaQtd;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  double _calcularTotal() {
    return _produtosNaVenda.entries.fold(0, (total, entry) {
      final produto = entry.key;
      final quantidade = entry.value;
      return total +
          widget.vendasController.calcularPrecoProporcional(
            produto.precoVenda,
            quantidade,
            produto,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final produtosDisponiveis =
        _todosProdutos
            .where(
              (produto) =>
                  produto.quantidade > 0 &&
                  produto.nome.toLowerCase().contains(
                    _buscaController.text.toLowerCase(),
                  ),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.attach_money),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          FiadosPage(vendasController: widget.vendasController),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _limparCarrinho,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _buscaController,
              decoration: const InputDecoration(
                hintText: 'Buscar produto...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            const Text('Produtos disponíveis:'),
            Expanded(
              child: ListView.builder(
                itemCount: produtosDisponiveis.length,
                itemBuilder: (context, index) {
                  final produto = produtosDisponiveis[index];
                  return ProdutoDisponivelItem(
                    produto: produto,
                    onAdicionar: (qtd) => _adicionarProduto(produto, qtd),
                  );
                },
              ),
            ),
            const Divider(),
            const Text('Carrinho:'),
            Expanded(
              child: ListView.builder(
                itemCount: _produtosNaVenda.length,
                itemBuilder: (context, index) {
                  final produto = _produtosNaVenda.keys.elementAt(index);
                  final quantidade = _produtosNaVenda[produto]!;
                  final preco = widget.vendasController
                      .calcularPrecoProporcional(
                        produto.precoVenda,
                        quantidade,
                        produto,
                      );
                  return ListTile(
                    title: Text(produto.nome),
                    subtitle: Text(
                      '${quantidade.toStringAsFixed(2)} ${produto.unidadeMedida} x R\$ ${produto.precoVenda.toStringAsFixed(2)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editarQuantidade(produto),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removerProduto(produto),
                        ),
                        Text('R\$ ${preco.toStringAsFixed(2)}'),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Total: R\$ ${_calcularTotal().toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => FinalizarVendaDialog(
                            total: _calcularTotal(),
                            onConfirmar: (
                              formaPagamento,
                              nomeCliente,
                              desconto,
                            ) {
                              widget.vendasController.salvarVenda(
                                produtos: _produtosNaVenda,
                                total: _calcularTotal() - desconto,
                                formaPagamento: formaPagamento,
                                nomeCliente: nomeCliente,
                              );
                              _limparCarrinho();
                              Navigator.pop(context);
                            },
                          ),
                    );
                  },
                  child: const Text('Finalizar Venda'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Funcionalidade de Nota Fiscal ainda não disponível.',
                        ),
                      ),
                    );
                  },
                  child: const Text('Emitir Nota Fiscal'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
