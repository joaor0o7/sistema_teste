import 'package:sistema_comercio_2/modules/auth/models/user_model.dart';

class AuthController {
  UserModel? _usuarioLogado;

  UserModel? login(String email, String senha) {
    if (email.trim().isEmpty || senha.trim().isEmpty) return null;

    if (email == 'admin' && senha == '1234') {
      _usuarioLogado = UserModel(nome: 'Administrador', email: email);
      return _usuarioLogado;
    }

    return null;
  }

  UserModel? get usuarioLogado => _usuarioLogado;

  void logout() {
    _usuarioLogado = null;
  }
}
