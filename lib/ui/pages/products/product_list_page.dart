import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teste_vagacrud/ui/pages/products/product_from_page.dart';
import '../../../providers/product_provider.dart';
import '../../widgets/image_display_widget.dart';

class ProductListPage extends ConsumerWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    Future.microtask(() {
      ref.read(productProvider.notifier).fetchProducts();
    });

    final asyncState = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
      ),
      body: asyncState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : asyncState.error != null
              ? Center(child: Text('Erro: ${asyncState.error}'))
              : ListView.builder(
                  itemCount: asyncState.products.length,
                  itemBuilder: (ctx, index) {
                    final prod = asyncState.products[index];

                    return ListTile(
                      leading: prod.imagens.isNotEmpty
                          ? ImageDisplayWidget(
                              imagePath: prod.imagens.first,
                            )
                          : const Icon(Icons.image_not_supported),

                      title: Text(prod.descricao),

                      subtitle: Text(
                        'R\$ ${prod.valorVenda.toStringAsFixed(2)} | Estoque: ${prod.estoque}',
                      ),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          IconButton(
                            key: const Key('editProductButton'),
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductFormPage(
                                    product: prod,
                                  ),
                                ),
                              );
                            },
                          ),

                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _showDeleteDialog(
                              context,
                              ref,
                              prod.id,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

      floatingActionButton: FloatingActionButton(
        key: const Key('newProductButton'),
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProductFormPage(),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Produto'),
        content: const Text('Deseja realmente excluir?'),
        actions: [

          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),

          TextButton(
            key: const Key('deleteProductButton'),
            onPressed: () {
              ref
                  .read(productProvider.notifier)
                  .deleteProduct(id);

              Navigator.pop(ctx);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}