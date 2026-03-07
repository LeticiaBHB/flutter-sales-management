import 'package:sqflite/sqflite.dart';
import 'package:teste_vagacrud/core/database_helper.dart';
import 'package:teste_vagacrud/models/product.dart';
import 'product_repository.dart';

class SqliteProductRepository implements ProductRepository {

  final dbHelper = DatabaseHelper.instance;

  @override
  Future<List<Product>> getProducts() async {

    final db = await dbHelper.database;

    final maps = await db.query('products');

    return maps.map((e)=>Product.fromMap(e)).toList();
  }

  @override
  Future<void> saveProduct(Product product) async {

    final db = await dbHelper.database;

    await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteProduct(String id) async {

    final db = await dbHelper.database;

    await db.delete(
      'products',
      where: 'id=?',
      whereArgs: [id],
    );
  }
}