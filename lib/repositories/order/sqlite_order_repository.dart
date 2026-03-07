import 'package:teste_vagacrud/core/database_helper.dart';
import 'package:teste_vagacrud/models/order.dart';
import 'package:uuid/uuid.dart';
import 'order_repository.dart';

class SqliteOrderRepository implements OrderRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  @override
  Future<List<Order>> getOrders() async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT 
        orders.id,
        orders.clienteId,
        orders.data,
        orders.valorTotal,
        clients.razaoSocial as clienteNome
      FROM orders
      LEFT JOIN clients ON orders.clienteId = clients.id
      ORDER BY orders.data DESC
    ''');
    return maps.map((e) => Order.fromMap(e)).toList();
  }

  @override
Future<void> saveOrder({
  required String clienteId,
  required String clienteNome,
  required String data,
  required double valorTotal,
  required List<Map<String, dynamic>> itens,
}) async {

  final db = await _db.database;

  final orderId = _uuid.v4();

  await db.insert('orders', {
    'id': orderId,
    'clienteId': clienteId,
    'data': data,
    'valorTotal': valorTotal,
  });

  for (var item in itens) {
    await db.insert('order_items', {
      'id': _uuid.v4(),
      'orderId': orderId,
      'productId': item['productId'],
      'quantidade': item['quantidade'],
      'valorUnitario': item['valorUnitario'],
    });
  }
}

  @override
  Future<void> deleteOrder(String orderId) async {
    final db = await _db.database;
    await db.delete(
      'order_items',
      where: 'orderId = ?',
      whereArgs: [orderId],
    );
    await db.delete(
      'orders',
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }
}