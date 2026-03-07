import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/database_helper.dart';
import '../models/order.dart';

class OrderState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;

  OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  OrderState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class OrderNotifier extends Notifier<OrderState> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  @override
  OrderState build() {
    fetchOrders();
    return OrderState();
  }

  Future<void> fetchOrders() async {
    state = state.copyWith(isLoading: true);

    try {
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

      final orderList = maps.map((e) => Order.fromMap(e)).toList();

      state = state.copyWith(
        orders: orderList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> saveOrder({
    required String clienteId,
    required String data,
    required double valorTotal,
  }) async {
    final db = await _db.database;

    final newOrder = Order(
      id: _uuid.v4(),
      clienteId: clienteId,
      clienteNome: '',
      data: data,
      valorTotal: valorTotal,
    );

    await db.insert('orders', newOrder.toMap());

    await fetchOrders();
  }

  Future<void> deleteOrder(String orderId) async {
    final db = await _db.database;

    await db.delete('order_items', where: 'orderId = ?', whereArgs: [orderId]);

    await db.delete('orders', where: 'id = ?', whereArgs: [orderId]);

    await fetchOrders();
  }
}

final orderProvider =
    NotifierProvider<OrderNotifier, OrderState>(OrderNotifier.new);