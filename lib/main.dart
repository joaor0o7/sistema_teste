import 'package:flutter/material.dart';
import 'modules/auth/pages/login_page.dart'; // Ajuste o caminho se necessário
import 'modules/auth/pages/home_page.dart'; // Ajuste o caminho se necessário
import 'package:sistema_comercio_2/modules/estoque/produtos/controllers/produtos_controller.dart';
import 'package:sistema_comercio_2/modules/estoque/controllers/estoque_controller.dart';
import 'package:sistema_comercio_2/modules/auth/models/user_model.dart';
import 'package:sistema_comercio_2/modules/vendas/controller_vendas/vendas_controller.dart';
import 'package:sistema_comercio_2/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // precisa pra chamadas async antes do runApp

  final dbHelper = DatabaseHelper();
  final db = await dbHelper.database;
  print('Banco de dados inicializado: $db');

  final produtosController = ProdutosController();
  final movimentacoesController = EstoqueController(
    produtosController: produtosController,
  );
  final vendasController = VendasController(); //

  runApp(
    MyApp(
      produtosController: produtosController,
      movimentacoesController: movimentacoesController,
      vendasController: vendasController, //
    ),
  );
}

class MyApp extends StatelessWidget {
  final ProdutosController produtosController;
  final EstoqueController movimentacoesController;
  final VendasController vendasController; //
  const MyApp({
    super.key,
    required this.produtosController,
    required this.movimentacoesController,
    required this.vendasController, //
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema Comércio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: HomePage(
        user: UserModel(nome: 'Usuário Demo'),
        produtosController: produtosController,
        estoqueController: movimentacoesController,
        vendasController: vendasController, //
      ),
    );
  }
}
