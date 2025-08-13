import 'package:flutter/material.dart';
import 'package:sistema_comercio_2/modules/auth/controllers/auth_controller.dart';
import 'package:sistema_comercio_2/modules/auth/models/user_model.dart';
import 'package:sistema_comercio_2/modules/auth/pages/home_page.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/controllers/produtos_controller.dart';
import 'package:sistema_comercio_2/modules/estoque/controllers/estoque_controller.dart';
import 'package:sistema_comercio_2/modules/vendas/controller_vendas/vendas_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authController = AuthController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  void login() {
    final email = emailController.text.trim();
    final senha = senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
      return;
    }

    final user = _authController.login(email, senha);

    if (user != null) {
      final vendasController = VendasController();
      final produtosController = ProdutosController();
      final estoqueController = EstoqueController(
        produtosController: produtosController,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => HomePage(
                user: user,
                produtosController: produtosController,
                estoqueController: estoqueController,
                vendasController: vendasController,
              ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail ou senha inválidos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Login',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: senhaController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Senha'),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Entrar', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
