import 'package:flutter/material.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/models/produtos_model.dart';

class ProdutoCarrinhoItem extends StatelessWidget {
  final ProdutoModel produto;
  final int quantidade;
  final VoidCallback onRemover;
  final VoidCallback onEditarQuantidade;

  const ProdutoCarrinhoItem({
    super.key,
    required this.produto,
    required this.quantidade,
    required this.onRemover,
    required this.onEditarQuantidade,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(produto.nome),
      subtitle: Text(
        'Preço: R\$ ${produto.precoVenda.toStringAsFixed(2)} • Qtd: $quantidade',
      ),
      trailing: Wrap(
        spacing: 8,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEditarQuantidade,
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            onPressed: onRemover,
          ),
        ],
      ),
    );
  }
}
