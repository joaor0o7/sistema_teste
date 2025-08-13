import 'package:sqflite/sqflite.dart';
import 'package:sistema_comercio_2/database/database_helper.dart';
import 'package:sistema_comercio_2/modules/vendas/model_vendas/vendas_model.dart';

class VendaDao {
  final dbHelper = DatabaseHelper();

  Future<void> insertVenda(VendaModel venda) async {
    final db = await dbHelper.database;
    await db.insert(
      'vendas',
      venda.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<VendaModel>> getAllVendas() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('vendas');

    return List.generate(maps.length, (i) {
      return VendaModel.fromMap(maps[i]);
    });
  }

  Future<void> deleteVenda(int id) async {
    final db = await dbHelper.database;
    await db.delete('vendas', where: 'id = ?', whereArgs: [id]);
  }
}
