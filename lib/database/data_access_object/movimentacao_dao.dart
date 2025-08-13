import 'package:sqflite/sqflite.dart';
import 'package:sistema_comercio_2/database/database_helper.dart';
import 'package:sistema_comercio_2/modules/estoque/models/estoque_model.dart';

class MovimentacaoDao {
  final dbHelper = DatabaseHelper();

  Future<void> insertMovimentacao(MovimentacaoModel movimentacao) async {
    final db = await dbHelper.database;
    await db.insert(
      'movimentacoes',
      movimentacao.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MovimentacaoModel>> getAllMovimentacoes() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('movimentacoes');

    return List.generate(maps.length, (i) {
      return MovimentacaoModel.fromMap(maps[i]);
    });
  }

  Future<void> deleteMovimentacao(int id) async {
    final db = await dbHelper.database;
    await db.delete('movimentacoes', where: 'id = ?', whereArgs: [id]);
  }
}
