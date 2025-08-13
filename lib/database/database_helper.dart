import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'comercio.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE ${Tabelas.produtos} (
      codigo TEXT PRIMARY KEY,
      nome TEXT NOT NULL,
      precoVenda REAL NOT NULL,
      precoCusto REAL NOT NULL,
      quantidade REAL NOT NULL,
      unidadeMedida TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE ${Tabelas.movimentacoes} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      produtoCodigo TEXT NOT NULL,
      quantidade REAL NOT NULL,
      tipo TEXT NOT NULL,
      data TEXT NOT NULL,
      FOREIGN KEY (produtoCodigo) REFERENCES ${Tabelas.produtos} (codigo)
    )
  ''');

    await db.execute('''
    CREATE TABLE ${Tabelas.vendas} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      data TEXT NOT NULL,
      valor_total REAL NOT NULL
    )
  ''');

    print('Banco de dados criado com as tabelas!');
  }

  // Controle de migração para versões futuras
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Exemplo de alteração:
      await db.execute(
        'ALTER TABLE ${Tabelas.produtos} ADD COLUMN descricao TEXT',
      );
      print('Banco atualizado para versão 2');
    }
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}

// Constantes para tabelas e colunas
class Tabelas {
  static const produtos = 'produtos';
  static const movimentacoes = 'movimentacoes';
  static const vendas = 'vendas';
}
