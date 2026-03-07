import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/client.dart';
import '../../../models/product.dart';

import '../../../providers/client_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/order_provider.dart';

import '../../widgets/image_display_widget.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  double get subtotal => product.valorVenda * quantity;
}

class NewOrderPage extends ConsumerStatefulWidget {
  const NewOrderPage({super.key});

  @override
  ConsumerState<NewOrderPage> createState() => _NewOrderPageState();
}

class _NewOrderPageState extends ConsumerState<NewOrderPage> {
  final List<CartItem> _cart = [];

  String? _selectedClientId;

  final Map<String, TextEditingController> _qtyControllers = {};

  bool _isSaving = false;

  final currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  @override
  void dispose() {
    for (var controller in _qtyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double get _totalOrderValue {
    double total = 0;

    for (var item in _cart) {
      total += item.subtotal;
    }

    return total;
  }

  void _addToCart(Product product) {
    final controller = _qtyControllers[product.id];

    final qty = int.tryParse(controller?.text ?? '1') ?? 1;

    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantidade inválida')),
      );
      return;
    }

    if (qty > product.estoque) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantidade maior que o estoque'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final existingIndex =
        _cart.indexWhere((item) => item.product.id == product.id);

    setState(() {
      if (existingIndex != -1) {
        _cart[existingIndex].quantity += qty;
      } else {
        _cart.add(
          CartItem(
            product: product,
            quantity: qty,
          ),
        );
      }
    });

    controller?.text = '1';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${qty}x ${product.descricao} adicionado'),
      ),
    );
  }

  void _removeFromCart(int index) {
    setState(() {
      _cart.removeAt(index);
    });
  }

  Future<void> _saveOrder() async {
    if (_selectedClientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um cliente'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione produtos ao pedido'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final clientsState = ref.read(clientProvider);

      final client = clientsState.clients.firstWhere(
        (c) => c.id == _selectedClientId,
      );

      final orderItems = _cart
          .map(
            (item) => {
              "produtoId": item.product.id,
              "descricao": item.product.descricao,
              "quantidade": item.quantity,
              "valorUnitario": item.product.valorVenda,
              "subtotal": item.subtotal,
            },
          )
          .toList();

      await ref.read(orderProvider.notifier).saveOrder(
            clienteId: client.id,
            clienteNome: client.razaoSocial,
            data: DateTime.now().toIso8601String(),
            valorTotal: _totalOrderValue,
            itens: orderItems,
          );

      if (mounted) {
        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientsState = ref.watch(clientProvider);
    final productsState = ref.watch(productProvider);

    Client? selectedClient;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Pedido'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /// CLIENTE
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cliente',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                clientsState.isLoading
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        hint: const Text('Selecione um cliente'),
                        value: _selectedClientId,
                        items: clientsState.clients.map((client) {
                          return DropdownMenuItem(
                            value: client.id,
                            child: Text(client.razaoSocial),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedClientId = value;
                          });
                        },
                      ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Produtos Disponíveis',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          /// LISTA PRODUTOS
          Expanded(
            flex: 2,
            child: productsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: productsState.products.length,
                    itemBuilder: (ctx, index) {
                      final product = productsState.products[index];

                      _qtyControllers.putIfAbsent(
                        product.id,
                        () => TextEditingController(text: '1'),
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: product.imagens.isNotEmpty
                              ? ImageDisplayWidget(
                                  imagePath: product.imagens.first,
                                )
                              : const Icon(Icons.image_not_supported),
                          title: Text(product.descricao),
                          subtitle: Text(
                            'Preço: ${currencyFormatter.format(product.valorVenda)} | Estoque: ${product.estoque}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 50,
                                child: TextField(
                                  controller: _qtyControllers[product.id],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle,
                                  color: Colors.green,
                                ),
                                onPressed: () => _addToCart(product),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          /// CARRINHO
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Itens no Pedido',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Total: ${currencyFormatter.format(_totalOrderValue)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _cart.isEmpty
                      ? const Center(child: Text('Carrinho vazio'))
                      : ListView.builder(
                          itemCount: _cart.length,
                          itemBuilder: (ctx, index) {
                            final item = _cart[index];

                            return ListTile(
                              dense: true,
                              title: Text(item.product.descricao),
                              subtitle: Text(
                                '${item.quantity} x ${currencyFormatter.format(item.product.valorVenda)} = ${currencyFormatter.format(item.subtotal)}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeFromCart(index),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveOrder,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'FINALIZAR PEDIDO',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}