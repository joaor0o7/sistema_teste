import 'package:flutter/material.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/models/produtos_model.dart';

class ProdutoDisponivelItem extends StatelessWidget {
  final ProdutoModel produto;
  final Function(double) onAdicionar;

  const ProdutoDisponivelItem({
    super.key,
    required this.produto,
    required this.onAdicionar,
  });

  void _mostrarDialogoQuantidade(BuildContext context) {
    final TextEditingController quantidadeController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Quantidade (${produto.unidadeMedida})'),
            content: TextField(
              controller: quantidadeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                hintText: 'Digite a quantidade',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final qtd = double.tryParse(
                    quantidadeController.text.replaceAll(',', '.'),
                  );
                  if (qtd != null && qtd > 0) {
                    onAdicionar(qtd);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Adicionar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(produto.nome),
        subtitle: Text(
          'R\$ ${produto.precoVenda.toStringAsFixed(2)} por ${produto.unidadeMedida}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_shopping_cart),
          onPressed: () => _mostrarDialogoQuantidade(context),
        ),
      ),
    );
  }
}
