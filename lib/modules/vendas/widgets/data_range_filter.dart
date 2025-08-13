import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeFilter extends StatefulWidget {
  final Function(DateTime?) onStartDateChanged;
  final Function(DateTime?) onEndDateChanged;

  const DateRangeFilter({
    super.key,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  @override
  State<DateRangeFilter> createState() => _DateRangeFilterState();
}

class _DateRangeFilterState extends State<DateRangeFilter> {
  DateTime? _dataInicio;
  DateTime? _dataFim;
  final TextEditingController _dataInicioController = TextEditingController();
  final TextEditingController _dataFimController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: TextField(
              controller: _dataInicioController,
              decoration: const InputDecoration(
                labelText: 'Data Início',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _dataInicio ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (selectedDate != null) {
                  setState(() {
                    _dataInicio = selectedDate;
                    _dataInicioController.text = DateFormat(
                      'dd/MM/yyyy',
                    ).format(_dataInicio!);
                    widget.onStartDateChanged(_dataInicio);
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _dataFimController,
              decoration: const InputDecoration(
                labelText: 'Data Fim',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _dataFim ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (selectedDate != null) {
                  setState(() {
                    _dataFim = selectedDate;
                    _dataFimController.text = DateFormat(
                      'dd/MM/yyyy',
                    ).format(_dataFim!);
                    widget.onEndDateChanged(_dataFim);
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
