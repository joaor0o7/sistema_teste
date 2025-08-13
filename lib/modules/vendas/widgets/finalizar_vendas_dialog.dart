import 'package:flutter/material.dart';

class FinalizarVendaDialog extends StatefulWidget {
  final double total;
  final void Function(
    String formaPagamento,
    String nomeCliente,
    double desconto,
  )
  onConfirmar;

  const FinalizarVendaDialog({
    super.key,
    required this.total,
    required this.onConfirmar,
  });

  @override
  State<FinalizarVendaDialog> createState() => _FinalizarVendaDialogState();
}

class _FinalizarVendaDialogState extends State<FinalizarVendaDialog> {
  final TextEditingController clienteController = TextEditingController();
  final TextEditingController valorPagoController = TextEditingController();
  final TextEditingController descontoController = TextEditingController(
    text: '0',
  ); // Inicializa com 0%

  String formaPagamentoSelecionada = 'Dinheiro';
  double troco = 0;
  double desconto = 0.0; // Variável para armazenar o desconto

  @override
  void initState() {
    super.initState();
    descontoController.addListener(_atualizarDesconto);
  }

  void _atualizarDesconto() {
    setState(() {
      desconto =
          double.tryParse(descontoController.text.replaceAll(',', '.')) ?? 0.0;
    });
  }

  double get totalComDesconto => widget.total - (widget.total * desconto / 100);

  void _calcularTroco() {
    final valorPago =
        double.tryParse(valorPagoController.text.replaceAll(',', '.')) ?? 0;
    if (valorPago >= totalComDesconto) {
      setState(() {
        troco = valorPago - totalComDesconto;
      });
    } else {
      setState(() {
        troco = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Finalizar Venda'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total: R\$ ${widget.total.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            TextField(
              controller: descontoController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Desconto (%)'),
              onChanged: (_) {
                setState(() {
                  desconto = double.tryParse(descontoController.text) ?? 0.0;
                });
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Total com Desconto: R\$ ${totalComDesconto.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: formaPagamentoSelecionada,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    formaPagamentoSelecionada = value;
                    if (formaPagamentoSelecionada != 'Dinheiro') {
                      valorPagoController.clear();
                      troco = 0;
                    }
                  });
                }
              },
              items: const [
                DropdownMenuItem(value: 'Dinheiro', child: Text('Dinheiro')),
                DropdownMenuItem(value: 'Pix', child: Text('Pix')),
                DropdownMenuItem(value: 'Débito', child: Text('Débito')),
                DropdownMenuItem(value: 'Credito', child: Text('Crédito')),
                DropdownMenuItem(value: 'Fiado', child: Text('Fiado')),
              ],
              decoration: const InputDecoration(
                labelText: 'Forma de pagamento',
              ),
            ),
            if (formaPagamentoSelecionada == 'Dinheiro') ...[
              const SizedBox(height: 12),
              TextField(
                controller: valorPagoController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Valor pago'),
                onChanged: (_) => _calcularTroco(),
              ),
              const SizedBox(height: 8),
              Text('Troco: R\$ ${troco.toStringAsFixed(2)}'),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: clienteController,
              decoration: const InputDecoration(
                labelText: 'Nome do cliente (opcional)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfirmar(
              formaPagamentoSelecionada,
              clienteController.text,
              desconto, // Passa o valor do desconto
            );
            Navigator.pop(context);
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
