import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('crud.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path;

    if (kIsWeb) {
      // No web não existe filesystem
      path = filePath;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {

    await db.execute('''
CREATE TABLE clients(
id TEXT PRIMARY KEY,
razaoSocial TEXT,
cnpj TEXT,
email TEXT,
cep TEXT,
logradouro TEXT
)
''');

    await db.execute('''
CREATE TABLE products(
id TEXT PRIMARY KEY,
descricao TEXT,
valorVenda REAL,
estoque INTEGER,
imagens TEXT
)
''');

    await db.execute('''
CREATE TABLE orders(
id TEXT PRIMARY KEY,
clienteId TEXT,
data TEXT,
valorTotal REAL
)
''');

    await db.execute('''
CREATE TABLE order_items(
id TEXT PRIMARY KEY,
orderId TEXT,
productId TEXT,
quantidade INTEGER,
valorUnitario REAL
)
''');
  }
}