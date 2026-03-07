import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../models/client.dart';
import '../../../models/product.dart';
import '../../../providers/client_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../core/database_helper.dart';
import '../../widgets/image_display_widget.dart'; 

// Classe auxiliar para controlar o carrinho local
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}

class NewOrderPage extends ConsumerStatefulWidget {
  const NewOrderPage({super.key});

  @override
  ConsumerState<NewOrderPage> createState() => _NewOrderPageState();
}

class _NewOrderPageState extends ConsumerState<NewOrderPage> {
  // Estado Local para o Carrinho
  final List<CartItem> _cart = [];

  // Estado para seleção de Cliente
  String? _selectedClientId;

  // Controladores para quantidade temporária na listagem de produtos
  final Map<String, TextEditingController> _qtyControllers = {};

  final DatabaseHelper _db = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();
  bool _isSaving = false;
  final currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  @override
  void dispose() {
    // Limpa os controllers
    for (var controller in _qtyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double get _totalOrderValue {
    double total = 0;
    for (var item in _cart) {
      total += item.product.valorVenda * item.quantity;
    }
    return total;
  }

  void _addToCart(Product product) {
    final controller = _qtyControllers[product.id];
    final qty = int.tryParse(controller?.text ?? '0') ?? 0;

    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quantidade inválida.')));
      return;
    }

    final existingIndex = _cart.indexWhere((item) => item.product.id == product.id);

    if (existingIndex != -1) {
      setState(() {
        _cart[existingIndex].quantity += qty;
      });
    } else {
      setState(() {
        _cart.add(CartItem(product: product, quantity: qty));
      });
    }

    controller?.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${qty}x ${product.descricao} adicionado(s)')),
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
        const SnackBar(content: Text('Selecione um cliente.'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione produtos ao pedido.'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final db = await _db.database;
      await db.transaction((txn) async {
        final orderId = _uuid.v4();
        final now = DateTime.now().toIso8601String();
        await txn.insert('orders', {
          'id': orderId,
          'clienteId': _selectedClientId,
          'data': now,
          'valorTotal': _totalOrderValue,
        });
        for (var item in _cart) {
          await txn.insert('order_items', {
            'id': _uuid.v4(),
            'orderId': orderId,
            'productId': item.product.id,
            'quantidade': item.quantity,
            'valorUnitario': item.product.valorVenda,
          });
        }
      });
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido realizado com sucesso!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar pedido: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientProvider);
    final productsAsync = ref.watch(productProvider);

    Client? selectedClient;
    if (_selectedClientId != null && clientsAsync.clients.isNotEmpty) {
      try {
        selectedClient = clientsAsync.clients.firstWhere((c) => c.id == _selectedClientId);
      } catch (e) {
        selectedClient = null;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Novo Pedido'), centerTitle: true),
      body: Column(
        children: [
          // 1. Seleção de Cliente
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cliente:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                clientsAsync.isLoading
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        hint: const Text('Selecione um cliente'),
                        value: _selectedClientId,
                        items: clientsAsync.clients.map((client) {
                          return DropdownMenuItem(
                            value: client.id,
                            child: Text(client.razaoSocial),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedClientId = val;
                          });
                        },
                      ),
              ],
            ),
          ),
          // 2. Lista de Produtos Disponíveis
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('Produtos Disponíveis', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 2,
            child: productsAsync.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: productsAsync.products.length,
                    itemBuilder: (ctx, index) {
                      final product = productsAsync.products[index];
                      if (!_qtyControllers.containsKey(product.id)) {
                        _qtyControllers[product.id] = TextEditingController(text: '1');
                      }
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: product.imagens.isNotEmpty
                              ? ImageDisplayWidget(imagePath: product.imagens.first)
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
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(0),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: Colors.green),
                                onPressed: () => _addToCart(product),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // 3. Resumo do Carrinho e Total
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Itens no Pedido:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        'Total: ${currencyFormatter.format(_totalOrderValue)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
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
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${item.quantity}x'),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
                                    onPressed: () => _removeFromCart(index),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveOrder,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.blue,
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('FINALIZAR PEDIDO', style: TextStyle(color: Colors.white, fontSize: 16)),
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