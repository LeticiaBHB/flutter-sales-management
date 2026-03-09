import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product_provider.dart'; 

class Order {
  final String id;
  final String clienteId;
  final String clienteNome;
  final String data;
  final double valorTotal;
  final List<Map<String, dynamic>> itens;

  Order({
    required this.id,
    required this.clienteId,
    required this.clienteNome,
    required this.data,
    required this.valorTotal,
    required this.itens,
  });
}

class OrderState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;

  const OrderState({
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
      error: error ?? this.error,
    );
  }
}

final orderProvider =
    NotifierProvider<OrderNotifier, OrderState>(OrderNotifier.new);

class OrderNotifier extends Notifier<OrderState> {
  @override
  OrderState build() {
    Future.microtask(() => fetchOrders());
    return const OrderState();
  }

  /// LISTAR PEDIDOS
  Future<void> fetchOrders() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(
      orders: state.orders,
      isLoading: false,
    );
  }

  /// SALVAR PEDIDO
  Future<void> saveOrder({
    required String clienteId,
    required String clienteNome,
    required String data,
    required double valorTotal,
    required List<Map<String, dynamic>> itens,
  }) async {
    final newOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clienteId: clienteId,
      clienteNome: clienteNome,
      data: data,
      valorTotal: valorTotal,
      itens: itens, 
    );

    final updated = [...state.orders, newOrder];
    state = state.copyWith(orders: updated);
  }

  /// EXCLUIR PEDIDO E RESTAURAR ESTOQUE
  Future<void> deleteOrder(String id) async {
    try {
      // Encontrar o pedido antes de deletar para saber o que devolver
      final orderToDelete = state.orders.firstWhere((o) => o.id == id);

      // PERCORRER OS ITENS E DEVOLVER O ESTOQUE
      for (var item in orderToDelete.itens) {
        final productId = item['produtoId'] as String;
        final quantity = item['quantidade'] as int;

        await ref.read(productProvider.notifier).increaseStock(productId, quantity);
      }

      // Remove o pedido da lista
      final updated = state.orders.where((o) => o.id != id).toList();
      state = state.copyWith(orders: updated);

    } catch (e) {
      print('Erro ao excluir pedido: $e');
      rethrow;
    }
  }
}