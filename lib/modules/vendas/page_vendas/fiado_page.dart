import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_comercio_2/modules/vendas/controller_vendas/vendas_controller.dart';
import 'package:sistema_comercio_2/modules/vendas/model_vendas/vendas_model.dart';

class FiadosPage extends StatefulWidget {
  final VendasController vendasController;

  const FiadosPage({super.key, required this.vendasController});

  @override
  State<FiadosPage> createState() => _FiadosPageState();
}

class _FiadosPageState extends State<FiadosPage> {
  Map<String, List<VendaModel>> _fiadosPorCliente = {};
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _agruparFiados();
  }

  void _agruparFiados() {
    _fiadosPorCliente = {};
    for (final venda in widget.vendasController.fiados.where(
      (venda) => !venda.isPago,
    )) {
      if (_fiadosPorCliente.containsKey(venda.nomeCliente)) {
        _fiadosPorCliente[venda.nomeCliente]!.add(venda);
      } else {
        _fiadosPorCliente[venda.nomeCliente] = [venda];
      }
    }
    final sortedKeys = _fiadosPorCliente.keys.toList()..sort();
    final sortedMap = {
      for (var key in sortedKeys) key: _fiadosPorCliente[key]!,
    };
    setState(() {
      _fiadosPorCliente = sortedMap;
    });
  }

  double _calcularTotalDevido(List<VendaModel> vendas) {
    return vendas.fold(0.0, (sum, venda) => sum + venda.total);
  }

  void _marcarComoPago(VendaModel venda) {
    setState(() {
      venda.isPago = true;
      _agruparFiados();
    });
  }

  void _confirmarPagamento(VendaModel venda) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirmar pagamento'),
            content: const Text(
              'Tem certeza que deseja marcar esta venda como paga?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _marcarComoPago(venda);
                },
                child: const Text('Confirmar'),
              ),
            ],
          ),
    );
  }

  void _quitarTodasAsVendas(String cliente) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Quitar todas as vendas'),
            content: Text(
              'Deseja realmente marcar todas as vendas de "$cliente" como pagas?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final vendas = _fiadosPorCliente[cliente];
                  if (vendas != null) {
                    for (final venda in vendas) {
                      venda.isPago = true;
                    }
                    setState(() {
                      _agruparFiados();
                    });
                  }
                  Navigator.pop(context);
                },
                child: const Text('Confirmar'),
              ),
            ],
          ),
    );
  }

  void _editarVenda(VendaModel venda) {
    final TextEditingController valorController = TextEditingController(
      text: venda.total.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Valor do Fiado'),
          content: TextField(
            controller: valorController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Novo Valor (R\$)'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Salvar'),
              onPressed: () {
                final novoValor = double.tryParse(valorController.text);
                if (novoValor != null && novoValor >= 0) {
                  setState(() {
                    venda.total = novoValor;
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, insira um valor válido.'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Controle de Fiados')),
      body:
          _fiadosPorCliente.isEmpty
              ? const Center(child: Text('Nenhuma venda no fiado pendente.'))
              : ListView.builder(
                itemCount: _fiadosPorCliente.length,
                itemBuilder: (context, index) {
                  final cliente = _fiadosPorCliente.keys.elementAt(index);
                  final vendasDoCliente = _fiadosPorCliente[cliente]!;
                  final totalDevido = _calcularTotalDevido(vendasDoCliente);

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ExpansionTile(
                      title: Text(
                        '$cliente - Total Devido: R\$ ${totalDevido.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        ...vendasDoCliente.map((venda) {
                          return ListTile(
                            title: Text(
                              'R\$ ${venda.total.toStringAsFixed(2)} - ${_dateFormat.format(venda.dataHora)}',
                            ),
                            subtitle: Text(
                              'Produtos: ${venda.produtos.keys.map((p) => p.nome).join(', ')}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _editarVenda(venda),
                                  child: const Text('Editar'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => _confirmarPagamento(venda),
                                  child: const Text('Pago'),
                                ),
                              ],
                            ),
                          );
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              icon: const Icon(Icons.done_all),
                              label: const Text('Quitar todas'),
                              onPressed: () => _quitarTodasAsVendas(cliente),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
