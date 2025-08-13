import 'package:flutter/material.dart';

class SalesSummary extends StatelessWidget {
  final Map<String, double> pagamentoTotais;
  final double totalGeral;
  final bool hasSales;

  const SalesSummary({
    super.key,
    required this.pagamentoTotais,
    required this.totalGeral,
    required this.hasSales,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const Text(
            'Totais por Forma de Pagamento:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          if (!hasSales)
            const Text('Nenhuma venda no período.')
          else if (pagamentoTotais.isEmpty)
            const Text('Nenhuma venda com essa forma de pagamento no período.')
          else
            ...pagamentoTotais.entries.map(
              (entry) =>
                  Text('${entry.key}: R\$ ${entry.value.toStringAsFixed(2)}'),
            ),
          const SizedBox(height: 8),
          Text(
            'Total Geral: R\$ ${totalGeral.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
