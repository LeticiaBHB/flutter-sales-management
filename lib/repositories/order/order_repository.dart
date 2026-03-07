import 'package:teste_vagacrud/models/order.dart';

abstract class OrderRepository {

  Future<List<Order>> getOrders();

  Future<void> saveOrder({
    required String clienteId,
    required String clienteNome,
    required String data,
    required double valorTotal,
    required List<Map<String, dynamic>> itens,
  });

  Future<void> deleteOrder(String orderId);
}