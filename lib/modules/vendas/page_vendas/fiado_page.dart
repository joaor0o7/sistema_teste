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
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );
  bool _isLoading = true;
  Map<String, List<VendaModel>> _fiadosPorCliente = {};

  @override
  void initState() {
    super.initState();
    _carregarFiados();
  }

  Future<void> _carregarFiados() async {
    setState(() => _isLoading = true);
    await widget.vendasController.carregarHistoricoCompleto();
    _agruparFiados();
    setState(() => _isLoading = false);
  }

  void _agruparFiados() {
    _fiadosPorCliente.clear();
    for (final venda in widget.vendasController.fiados.where(
      (v) => !v.isPago,
    )) {
      final cliente =
          venda.nomeCliente.isEmpty ? 'Sem Nome' : venda.nomeCliente;
      _fiadosPorCliente.putIfAbsent(cliente, () => []).add(venda);
    }
  }

  Future<void> _marcarComoPago(VendaModel venda) async {
    await widget.vendasController.pagarFiado(venda);
    _agruparFiados();
    setState(() {});
  }

  void _editarVenda(VendaModel venda) {
    final controller = TextEditingController(
      text: venda.total.toStringAsFixed(2),
    );
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Editar Valor do Fiado'),
            content: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Novo Valor (R\$)'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final novoValor = double.tryParse(controller.text);
                  if (novoValor != null && novoValor >= 0) {
                    venda.total = novoValor;
                    await widget.vendasController.atualizarVenda(venda);
                    _agruparFiados();
                    setState(() {});
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Insira um valor válido.')),
                    );
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
    );
  }

  Future<void> _quitarTodasAsVendas(
    String cliente,
    List<VendaModel> vendas,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Quitar todas as vendas'),
            content: Text(
              'Deseja marcar todas as vendas de "$cliente" como pagas?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      for (final venda in vendas) {
        await widget.vendasController.pagarFiado(venda);
      }
      _agruparFiados();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiados Pendentes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarFiados,
            tooltip: 'Atualizar lista',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _fiadosPorCliente.isEmpty
              ? const Center(child: Text('Nenhuma venda no fiado pendente.'))
              : ListView(
                children:
                    _fiadosPorCliente.entries.map((entry) {
                      final cliente = entry.key;
                      final vendasDoCliente = entry.value;
                      final totalDevido = vendasDoCliente.fold<double>(
                        0,
                        (sum, v) => sum + v.total,
                      );

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ExpansionTile(
                          title: Text(
                            '$cliente - Total Devido: ${_currencyFormat.format(totalDevido)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: [
                            ...vendasDoCliente.map((venda) {
                              return ListTile(
                                title: Text(
                                  '${_currencyFormat.format(venda.total)} - ${_dateFormat.format(venda.dataHora)}',
                                ),
                                subtitle: Text(
                                  'Produtos: ${venda.produtos.keys.map((p) => p.nome).join(', ')}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editarVenda(venda),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.check),
                                      onPressed: () => _marcarComoPago(venda),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                icon: const Icon(Icons.done_all),
                                label: const Text('Quitar todas'),
                                onPressed:
                                    () => _quitarTodasAsVendas(
                                      cliente,
                                      vendasDoCliente,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
    );
  }
}

/*
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
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    // Agrupa fiados por cliente
    final Map<String, List<VendaModel>> fiadosPorCliente = {};
    for (final venda in widget.vendasController.fiados.where(
      (v) => !v.isPago,
    )) {
      fiadosPorCliente.putIfAbsent(venda.nomeCliente, () => []).add(venda);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Controle de Fiados')),
      body:
          fiadosPorCliente.isEmpty
              ? const Center(child: Text('Nenhuma venda no fiado pendente.'))
              : ListView(
                children:
                    fiadosPorCliente.entries.map((entry) {
                      final cliente = entry.key;
                      final vendasDoCliente = entry.value;
                      final totalDevido = vendasDoCliente.fold<double>(
                        0,
                        (sum, v) => sum + v.total,
                      );

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
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editarVenda(venda),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.check),
                                      onPressed: () async {
                                        await widget.vendasController
                                            .pagarFiado(venda);
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                icon: const Icon(Icons.done_all),
                                label: const Text('Quitar todas'),
                                onPressed:
                                    () => _quitarTodasAsVendas(
                                      cliente,
                                      vendasDoCliente,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
    );
  }

  void _editarVenda(VendaModel venda) {
    final controller = TextEditingController(
      text: venda.total.toStringAsFixed(2),
    );
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Editar Valor do Fiado'),
            content: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Novo Valor (R\$)'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final novoValor = double.tryParse(controller.text);
                  if (novoValor != null && novoValor >= 0) {
                    venda.total = novoValor;
                    await widget.vendasController.atualizarVenda(venda);
                    setState(() {});
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Insira um valor válido.')),
                    );
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
    );
  }

  void _quitarTodasAsVendas(String cliente, List<VendaModel> vendas) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Quitar todas as vendas'),
            content: Text(
              'Deseja marcar todas as vendas de "$cliente" como pagas?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      for (final venda in vendas) {
        await widget.vendasController.pagarFiado(venda);
      }
      setState(() {});
    }
  }
}
*/
