import 'package:flutter/material.dart';
import 'package:sistema_comercio_2/modules/auth/models/user_model.dart';
import 'package:sistema_comercio_2/modules/auth/pages/login_page.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/controllers/produtos_controller.dart';
import 'package:sistema_comercio_2/modules/estoque/pages/estoque_page.dart';
import 'package:sistema_comercio_2/modules/estoque/controllers/estoque_controller.dart';
import 'package:sistema_comercio_2/modules/vendas/page_vendas/vendas_page.dart';
import 'package:sistema_comercio_2/modules/vendas/controller_vendas/vendas_controller.dart';
import 'package:sistema_comercio_2/modules/vendas/page_vendas/historico_vendas.dart';

class HomePage extends StatelessWidget {
  final UserModel user;
  final ProdutosController produtosController;
  final EstoqueController estoqueController;
  final VendasController vendasController;

  const HomePage({
    super.key,
    required this.user,
    required this.produtosController,
    required this.estoqueController,
    required this.vendasController,
  });

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Logout'),
            content: const Text('Deseja realmente sair da conta?'),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text('Sair'),
                onPressed: () {
                  Navigator.pop(context);
                  _logout(context);
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-vindo, ${user.nome}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _confirmLogout(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, ${user.nome} 👋',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'O que você deseja fazer hoje?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.inventory_2),
                  label: const Text('Estoque'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                EstoquePage(controller: estoqueController),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Vendas'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => VendasPage(
                              produtosController: produtosController,
                              vendasController: vendasController,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.history),
                  label: const Text('Histórico de Vendas'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => HistoricoVendasPage(
                              vendasController: vendasController,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
