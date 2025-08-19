import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/controllers/produtos_controller.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/models/produtos_model.dart';
import 'package:sistema_comercio_2/modules/vendas/controller_vendas/vendas_controller.dart';
import 'package:sistema_comercio_2/modules/vendas/widgets/produto_carrinho_item.dart';
import 'package:sistema_comercio_2/modules/vendas/widgets/produto_disponivel_item.dart';
import 'package:sistema_comercio_2/modules/vendas/widgets/finalizar_vendas_dialog.dart';
import 'package:sistema_comercio_2/modules/vendas/page_vendas/fiado_page.dart';

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
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
    _buscaController.addListener(() => setState(() {}));
  }

  Future<void> _carregarProdutos() async {
    setState(() => _isLoading = true);
    await widget.produtosController.buscarProdutos();
    setState(() => _isLoading = false);
  }

  void _adicionarProduto(ProdutoModel produto, double quantidade) {
    setState(() {
      _produtosNaVenda.update(
        produto,
        (qtd) => qtd + quantidade,
        ifAbsent: () => quantidade,
      );
      produto.quantidade -= quantidade.toInt();
    });
  }

  void _removerProduto(ProdutoModel produto) {
    setState(() {
      produto.quantidade += _produtosNaVenda[produto]!.toInt();
      _produtosNaVenda.remove(produto);
    });
  }

  void _editarQuantidade(ProdutoModel produto) {
    final controller = TextEditingController(
      text: _produtosNaVenda[produto]?.toStringAsFixed(2) ?? '',
    );
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Editar quantidade de ${produto.nome}'),
            content: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
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
                  final novaQtd = double.tryParse(controller.text);
                  if (novaQtd != null && novaQtd >= 0) {
                    setState(() {
                      final diff = novaQtd - _produtosNaVenda[produto]!;
                      produto.quantidade -= diff.toInt();
                      _produtosNaVenda[produto] = novaQtd;
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
    );
  }

  void _limparCarrinho() {
    setState(() {
      _produtosNaVenda.forEach(
        (produto, qtd) => produto.quantidade += qtd.toInt(),
      );
      _produtosNaVenda.clear();
    });
  }

  double _calcularTotal() {
    return _produtosNaVenda.entries.fold(0.0, (total, entry) {
      return total +
          widget.vendasController.calcularPrecoProporcional(
            entry.key.precoVenda,
            entry.value,
            entry.key,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final produtosDisponiveis =
        widget.produtosController.produtos
            .where(
              (p) =>
                  p.quantidade > 0 &&
                  p.nome.toLowerCase().contains(
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
            onPressed: () async {
              await widget.vendasController.carregarHistoricoCompleto();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) =>
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _buscaController,
                      decoration: const InputDecoration(
                        hintText: 'Buscar produto...',
                        prefixIcon: Icon(Icons.search),
                      ),
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
                            onAdicionar:
                                (qtd) => _adicionarProduto(produto, qtd),
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
                          final produto = _produtosNaVenda.keys.elementAt(
                            index,
                          );
                          final quantidade = _produtosNaVenda[produto]!;
                          final subtotal = widget.vendasController
                              .calcularPrecoProporcional(
                                produto.precoVenda,
                                quantidade,
                                produto,
                              );
                          return ProdutoCarrinhoItem(
                            produto: produto,
                            quantidade: quantidade.toInt(),
                            onRemover: () => _removerProduto(produto),
                            onEditarQuantidade:
                                () => _editarQuantidade(produto),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Total: ${_currencyFormat.format(_calcularTotal())}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder:
                                    (_) => FinalizarVendaDialog(
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
                                        _carregarProdutos();
                                        Navigator.pop(context);
                                      },
                                    ),
                              );
                            },
                            child: const Text('Finalizar Venda'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}
