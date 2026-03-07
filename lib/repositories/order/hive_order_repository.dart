import 'package:hive/hive.dart';
import 'package:teste_vagacrud/models/order.dart';
import 'package:uuid/uuid.dart';
import 'order_repository.dart';

class HiveOrderRepository implements OrderRepository {
  static const boxName = 'orders';
  final Uuid _uuid = const Uuid();
  Future<Box> _box() async {
    return await Hive.openBox(boxName);
  }

  @override
  Future<List<Order>> getOrders() async {
    final box = await _box();
    final orders = box.values.map((e) {
      return Order.fromMap(Map<String, dynamic>.from(e));
    }).toList();
    orders.sort((a, b) => b.data.compareTo(a.data));
    return orders;
  }

@override
Future<void> saveOrder({
  required String clienteId,
  required String clienteNome,
  required String data,
  required double valorTotal,
  required List<Map<String, dynamic>> itens,
}) async {

  final box = await _box();

  final order = Order(
    id: _uuid.v4(),
    clienteId: clienteId,
    clienteNome: clienteNome,
    data: data,
    valorTotal: valorTotal,
    itens: itens,
  );

  await box.put(order.id, order.toMap());
}
  @override
  Future<void> deleteOrder(String orderId) async {
    final box = await _box();
    await box.delete(orderId);
  }
}