import 'package:flutter/material.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/models/produtos_model.dart';

class ProdutoItemVenda extends StatelessWidget {
  final ProdutoModel produto;
  final double quantidade;
  final VoidCallback onRemover;
  final VoidCallback onEditar;

  const ProdutoItemVenda({
    super.key,
    required this.produto,
    required this.quantidade,
    required this.onRemover,
    required this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    final double subtotal = produto.precoVenda * quantidade;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(produto.nome),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quantidade: $quantidade ${produto.unidadeMedida}'),
            Text('Subtotal: R\$ ${subtotal.toStringAsFixed(2)}'),
          ],
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar Produto',
              onPressed: onEditar,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Remover Produto',
              onPressed: onRemover,
            ),
          ],
        ),
      ),
    );
  }
}
