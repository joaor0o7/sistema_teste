class UserModel {
  final String nome;
  final String? email;

  UserModel({required this.nome, this.email});

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(nome: map['nome'] ?? '', email: map['email']);
  }

  Map<String, dynamic> toMap() {
    return {'nome': nome, 'email': email};
  }

  UserModel copyWith({String? nome, String? email}) {
    return UserModel(nome: nome ?? this.nome, email: email ?? this.email);
  }

  @override
  String toString() => 'UserModel(nome: $nome, email: $email)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          nome == other.nome &&
          email == other.email;

  @override
  int get hashCode => nome.hashCode ^ (email?.hashCode ?? 0);
}
