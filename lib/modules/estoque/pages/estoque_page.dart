import 'package:flutter/material.dart';
import 'package:sistema_comercio_2/modules/estoque/controllers/estoque_controller.dart';
import 'package:sistema_comercio_2/modules/estoque/models/estoque_model.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/pages/produtos_page.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/models/produtos_model.dart';

class EstoquePage extends StatefulWidget {
  final EstoqueController controller;

  const EstoquePage({super.key, required this.controller});

  @override
  State<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final quantidadeController = TextEditingController();
  ProdutoModel? produtoSelecionado;
  List<ProdutoModel> _produtos = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    _produtos = await widget.controller.produtosController.buscarProdutos();
    setState(() {});
  }

  void _registrarEntrada() async {
    produtoSelecionado = null;
    quantidadeController.clear();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova entrada de produto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ProdutoModel>(
                items:
                    _produtos
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text('${p.codigo} - ${p.nome}'),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  produtoSelecionado = value;
                },
                decoration: const InputDecoration(labelText: 'Produto'),
              ),
              TextField(
                controller: quantidadeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantidade'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (produtoSelecionado != null &&
                    int.tryParse(quantidadeController.text) != null) {
                  final quantidadeEntrada = int.parse(
                    quantidadeController.text,
                  );

                  // Buscar o produto pelo código
                  final produto = await widget.controller.produtosController
                      .buscarProdutoPorCodigo(produtoSelecionado!.codigo);

                  if (produto != null) {
                    // Somar a nova quantidade
                    produto.quantidade += quantidadeEntrada;

                    // Salvar o produto atualizado
                    await widget.controller.produtosController.editarProduto(
                      produto,
                    );

                    // Registrar a movimentação
                    await widget.controller.registrarMovimentacao(
                      MovimentacaoModel(
                        codigoProduto: produto.codigo,
                        quantidade: quantidadeEntrada,
                        tipo: TipoMovimentacao.entrada,
                        data: DateTime.now(),
                      ),
                    );

                    Navigator.pop(context);
                    _carregarProdutos(); // recarrega os produtos após entrada
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Produto não encontrado')),
                    );
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final movimentacoes = widget.controller.movimentacoes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estoque'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Movimentações'), Tab(text: 'Produtos')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Aba de Movimentações
          ListView.builder(
            itemCount: movimentacoes.length,
            itemBuilder: (context, index) {
              final mov = movimentacoes[index];

              final produto = _produtos.firstWhere(
                (p) => p.codigo == mov.codigoProduto,
                orElse:
                    () => ProdutoModel(
                      codigo: mov.codigoProduto,
                      nome: 'Produto não encontrado',
                      precoVenda: 0,
                      precoCusto: 0,
                      quantidade: 0,
                      unidadeMedida: 'g',
                    ),
              );

              return ListTile(
                leading: Icon(
                  mov.tipo == TipoMovimentacao.entrada
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color:
                      mov.tipo == TipoMovimentacao.entrada
                          ? Colors.green
                          : Colors.red,
                ),
                title: Text(
                  '${produto.codigo} - ${produto.nome}: ${mov.quantidade}',
                ),
                subtitle: Text('Data: ${mov.data.toLocal()}'),
                trailing: Text(
                  mov.tipo == TipoMovimentacao.entrada ? 'Entrada' : 'Saída',
                  style: TextStyle(
                    color:
                        mov.tipo == TipoMovimentacao.entrada
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              );
            },
          ),

          // Aba de Produtos
          ProdutosPage(controller: widget.controller.produtosController),
        ],
      ),
      floatingActionButton:
          _tabController.index == 0
              ? FloatingActionButton(
                onPressed: _registrarEntrada,
                tooltip: 'Nova entrada',
                child: const Icon(Icons.add),
              )
              : null,
    );
  }
}
