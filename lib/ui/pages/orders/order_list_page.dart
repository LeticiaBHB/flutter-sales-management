import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:teste_vagacrud/ui/pages/orders/new_order_page.dart';
import '../../../providers/order_provider.dart'; 

class OrderListPage extends ConsumerWidget {
  const OrderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(orderProvider);
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final dateFormatter = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos'), centerTitle: true),
      body: asyncState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : asyncState.error != null
          ? Center(child: Text('Erro: ${asyncState.error}'))
          : asyncState.orders.isEmpty
          ? const Center(child: Text('Nenhum pedido realizado.'))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: asyncState.orders.length,
              itemBuilder: (ctx, index) {
                final order = asyncState.orders[index];
                DateTime orderDate = DateTime.parse(order.data);
                return Card(
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    title: Text(
                      'Cliente: ${order.clienteNome}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text('Data: ${dateFormatter.format(orderDate)}'),
                        const SizedBox(height: 5),
                        Text(
                          'Valor Total: ${currencyFormatter.format(order.valorTotal)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      onPressed: () {
                        _confirmDelete(context, ref, order.id);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.shopping_cart_checkout),
        label: const Text('Novo Pedido'),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewOrderPage()),
          );
          if (result == true) {
            ref.read(orderProvider.notifier).fetchOrders();
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Pedido'),
        content: const Text('Tem certeza que deseja excluir este pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(orderProvider.notifier).deleteOrder(orderId);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pedido excluído com sucesso!')),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
