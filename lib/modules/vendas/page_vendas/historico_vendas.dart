import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_comercio_2/modules/vendas/model_vendas/vendas_model.dart';
import 'package:sistema_comercio_2/modules/vendas/controller_vendas/vendas_controller.dart';
import 'package:sistema_comercio_2/modules/vendas/widgets/data_range_filter.dart';
import 'package:sistema_comercio_2/modules/vendas/widgets/sales_summary.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/controllers/produtos_controller.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/models/produtos_model.dart';

class HistoricoVendasPage extends StatefulWidget {
  final VendasController vendasController;
  final ProdutosController produtosController;

  const HistoricoVendasPage({
    super.key,
    required this.vendasController,
    required this.produtosController,
  });

  @override
  State<HistoricoVendasPage> createState() => _HistoricoVendasPageState();
}

class _HistoricoVendasPageState extends State<HistoricoVendasPage> {
  DateTime? _dataInicio;
  DateTime? _dataFim;
  String? _formaPagamentoSelecionada;
  List<VendaModel> _historicoFiltrado = [];
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  Map<String, double> _pagamentoTotais = {};
  double _totalGeral = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarHistoricoDoBanco();
  }

  Future<void> _carregarHistoricoDoBanco() async {
    setState(() => _isLoading = true);

    // Carrega produtos do controller
    await widget.produtosController.buscarProdutos();

    // Carrega vendas do banco
    await widget.vendasController.carregarHistoricoCompleto();

    // Aplica filtros iniciais e calcula totais
    _filtrarHistorico();

    setState(() => _isLoading = false);
  }

  void _filtrarHistorico() {
    final historicoCompleto = widget.vendasController.historico;
    setState(() {
      _historicoFiltrado =
          historicoCompleto.where((venda) {
            final dataVenda = venda.dataHora;

            final inicioValido =
                _dataInicio == null ||
                dataVenda.isAfter(_dataInicio!) ||
                dataVenda.isAtSameMomentAs(_dataInicio!);

            final fimValido =
                _dataFim == null ||
                dataVenda.isBefore(_dataFim!.add(const Duration(days: 1)));

            final pagamentoValido =
                _formaPagamentoSelecionada == null ||
                _formaPagamentoSelecionada == 'Todos' ||
                venda.formaPagamento == _formaPagamentoSelecionada;

            return inicioValido && fimValido && pagamentoValido;
          }).toList();

      _calcularTotais();
    });
  }

  void _calcularTotais() {
    _pagamentoTotais = {};
    _totalGeral = 0.0;

    for (final venda in _historicoFiltrado) {
      _totalGeral += venda.total;
      final formaPagamento = venda.formaPagamento;
      _pagamentoTotais[formaPagamento] =
          (_pagamentoTotais[formaPagamento] ?? 0) + venda.total;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Vendas')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  DateRangeFilter(
                    onStartDateChanged: (DateTime? date) {
                      _dataInicio = date;
                      _filtrarHistorico();
                    },
                    onEndDateChanged: (DateTime? date) {
                      _dataFim = date;
                      _filtrarHistorico();
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Filtrar por Forma de Pagamento',
                        border: OutlineInputBorder(),
                      ),
                      value: _formaPagamentoSelecionada,
                      items:
                          <String>[
                                'Todos',
                                'Dinheiro',
                                'Pix',
                                'Débito',
                                'Crédito',
                                'Fiado',
                              ]
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _formaPagamentoSelecionada = newValue;
                          _filtrarHistorico();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child:
                        _historicoFiltrado.isEmpty
                            ? const Center(
                              child: Text(
                                'Nenhuma venda encontrada com os filtros aplicados.',
                              ),
                            )
                            : ListView.builder(
                              itemCount: _historicoFiltrado.length,
                              itemBuilder: (context, index) {
                                final venda = _historicoFiltrado[index];
                                return Card(
                                  margin: const EdgeInsets.all(8),
                                  child: ExpansionTile(
                                    title: Text(
                                      'Venda ${venda.id ?? index + 1} - R\$ ${venda.total.toStringAsFixed(2)}',
                                    ),
                                    subtitle: Text(
                                      _dateFormat.format(venda.dataHora),
                                    ),
                                    children: [
                                      ListTile(
                                        title: const Text('Forma de pagamento'),
                                        subtitle: Text(venda.formaPagamento),
                                      ),
                                      if (venda.nomeCliente.isNotEmpty)
                                        ListTile(
                                          title: const Text('Cliente'),
                                          subtitle: Text(venda.nomeCliente),
                                        ),
                                      const Divider(),
                                      ...venda.produtos.entries.map((entry) {
                                        final ProdutoModel produto = entry.key;
                                        final double quantidade = entry.value;
                                        return ListTile(
                                          title: Text(produto.nome),
                                          subtitle: Text(
                                            '${quantidade.toStringAsFixed(2)} ${produto.unidadeMedida}',
                                          ),
                                          trailing: Text(
                                            'R\$ ${(produto.precoVenda * quantidade).toStringAsFixed(2)}',
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                );
                              },
                            ),
                  ),
                  SalesSummary(
                    pagamentoTotais: _pagamentoTotais,
                    totalGeral: _totalGeral,
                    hasSales: _historicoFiltrado.isNotEmpty,
                  ),
                ],
              ),
    );
  }
}
