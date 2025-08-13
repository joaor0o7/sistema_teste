import 'package:flutter/material.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/controllers/produtos_controller.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/models/produtos_model.dart';

class AdicionarEditarProdutoPage extends StatefulWidget {
  final ProdutosController controller;
  final ProdutoModel? produto;

  const AdicionarEditarProdutoPage({
    super.key,
    required this.controller,
    this.produto,
  });

  @override
  State<AdicionarEditarProdutoPage> createState() =>
      _AdicionarEditarProdutoPageState();
}

class _AdicionarEditarProdutoPageState
    extends State<AdicionarEditarProdutoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codigoController;
  late TextEditingController _nomeController;
  late TextEditingController _precoVendaController;
  late TextEditingController _precoCustoController;
  late TextEditingController _quantidadeController;

  final List<String> _unidades = ['un', 'kg', 'g', 'L', 'mL'];
  String? _unidadeSelecionada;

  @override
  void initState() {
    super.initState();
    final produto = widget.produto;

    _codigoController = TextEditingController(text: produto?.codigo ?? '');
    _nomeController = TextEditingController(text: produto?.nome ?? '');
    _precoVendaController = TextEditingController(
      text: produto?.precoVenda.toString() ?? '',
    );
    _precoCustoController = TextEditingController(
      text: produto?.precoCusto.toString() ?? '',
    );
    _quantidadeController = TextEditingController(
      text: produto?.quantidade.toString() ?? '',
    );

    _unidadeSelecionada = produto?.unidadeMedida ?? 'un';
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nomeController.dispose();
    _precoVendaController.dispose();
    _precoCustoController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  void _salvarProduto() {
    if (_formKey.currentState!.validate()) {
      final novoProduto = ProdutoModel(
        codigo: _codigoController.text.trim(),
        nome: _nomeController.text.trim(),
        precoVenda: double.parse(_precoVendaController.text),
        precoCusto: double.parse(_precoCustoController.text),
        quantidade: double.parse(_quantidadeController.text),
        unidadeMedida: _unidadeSelecionada ?? 'un',
      );

      if (widget.produto == null) {
        widget.controller.adicionarProduto(novoProduto);
      } else {
        widget.controller.editarProduto(novoProduto);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.produto == null ? 'Adicionar Produto' : 'Editar Produto',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(labelText: 'Código'),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Informe o código'
                            : null,
              ),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Informe o nome'
                            : null,
              ),
              TextFormField(
                controller: _precoVendaController,
                decoration: const InputDecoration(labelText: 'Preço de Venda'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  if (parsed == null || parsed <= 0)
                    return 'Informe um valor válido';
                  return null;
                },
              ),
              TextFormField(
                controller: _precoCustoController,
                decoration: const InputDecoration(labelText: 'Preço de Custo'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  if (parsed == null || parsed < 0)
                    return 'Informe um valor válido';
                  return null;
                },
              ),
              TextFormField(
                controller: _quantidadeController,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  if (parsed == null || parsed < 0)
                    return 'Informe uma quantidade válida';
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _unidadeSelecionada,
                items:
                    _unidades
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _unidadeSelecionada = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Unidade de medida',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvarProduto,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
