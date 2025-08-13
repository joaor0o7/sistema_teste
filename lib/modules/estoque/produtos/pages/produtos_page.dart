import 'package:flutter/material.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/controllers/produtos_controller.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/pages/adiconar_editar_produtos_page.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/models/produtos_model.dart';

class ProdutosPage extends StatefulWidget {
  final ProdutosController controller;

  const ProdutosPage({super.key, required this.controller});

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  final TextEditingController _searchController = TextEditingController();
  List<ProdutoModel> _produtos = [];
  List<ProdutoModel> _produtosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_filtrarProdutos);
  }

  Future<void> _loadProducts() async {
    final fetchedProducts = await widget.controller.buscarProdutos();
    setState(() {
      _produtos = fetchedProducts;
      _produtosFiltrados = _produtos;
    });
  }

  void _filtrarProdutos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _produtosFiltrados =
          _produtos.where((produto) {
            return produto.nome.toLowerCase().contains(query) ||
                produto.codigo.toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => AdicionarEditarProdutoPage(
                        controller: widget.controller,
                      ),
                ),
              );
              _loadProducts(); // Recarrega a lista ao voltar da inclusão/edição
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Pesquisar',
                hintText: 'Nome ou código do produto',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _produtosFiltrados.length,
        itemBuilder: (context, index) {
          final produto = _produtosFiltrados[index];
          return ListTile(
            title: Text(produto.nome),
            subtitle: Text(
              'Código: ${produto.codigo}\nPreço: R\$ ${produto.precoVenda.toStringAsFixed(2)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Qtd: ${produto.quantidade}'),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: const Text('Confirmar exclusão'),
                            content: Text(
                              'Deseja remover o produto "${produto.nome}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await widget.controller.removerProduto(
                                    produto.codigo,
                                  );
                                  Navigator.pop(ctx);
                                  _loadProducts(); // Atualiza a lista após a remoção
                                },
                                child: const Text('Remover'),
                              ),
                            ],
                          ),
                    );
                  },
                ),
              ],
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => AdicionarEditarProdutoPage(
                        controller: widget.controller,
                        produto: produto,
                      ),
                ),
              );
              _loadProducts(); // Atualiza a lista após edição
            },
          );
        },
      ),
    );
  }
}
