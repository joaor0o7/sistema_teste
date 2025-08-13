import 'package:sqflite/sqflite.dart';
import 'package:sistema_comercio_2/database/database_helper.dart';
import 'package:sistema_comercio_2/modules/estoque/produtos/models/produtos_model.dart';

class ProdutoDao {
  final dbHelper = DatabaseHelper();

  // Inserir produto
  Future<void> insertProduto(ProdutoModel produto) async {
    final db = await dbHelper.database;
    await db.insert(
      'produtos',
      produto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Buscar todos os produtos
  Future<List<ProdutoModel>> getAllProdutos() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('produtos');

    return List.generate(maps.length, (i) {
      return ProdutoModel.fromMap(maps[i]);
    });
  }

  // Buscar produto pelo código
  Future<ProdutoModel?> getProdutoPorCodigo(String codigo) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'produtos',
      where: 'codigo = ?',
      whereArgs: [codigo],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return ProdutoModel.fromMap(result.first);
    } else {
      return null;
    }
  }

  // Atualizar produto
  Future<void> updateProduto(ProdutoModel produto) async {
    final db = await dbHelper.database;
    await db.update(
      'produtos',
      produto.toMap(),
      where: 'codigo = ?',
      whereArgs: [produto.codigo],
    );
  }

  // Deletar produto
  Future<void> deleteProduto(String codigo) async {
    final db = await dbHelper.database;
    await db.delete('produtos', where: 'codigo = ?', whereArgs: [codigo]);
  }
}
