import 'package:sqflite/sqflite.dart';

import '../../models/client.dart';
import '../../core/database_helper.dart';
import 'client_repository.dart';

class SqliteClientRepository implements ClientRepository {
  final dbHelper = DatabaseHelper.instance;

  @override
  Future<List<Client>> getClients() async {
    final db = await dbHelper.database;
    final maps = await db.query('clients');
    return maps.map((e)=>Client.fromMap(e)).toList();
  }

  @override
  Future<void> saveClient(Client client) async {
    final db = await dbHelper.database;
    await db.insert(
      'clients',
      client.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteClient(String id) async {
    final db = await dbHelper.database;
    await db.delete(
      'clients',
      where: 'id=?',
      whereArgs: [id],
    );
  }
}