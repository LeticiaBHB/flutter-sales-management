import 'package:flutter/material.dart';
import 'package:teste_vagacrud/ui/pages/clients/client_list_page.dart';
import 'package:teste_vagacrud/ui/pages/orders/order_list_page.dart';
import 'package:teste_vagacrud/ui/pages/products/product_list_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget buildCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    Key? cardKey,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth > 600 
        ? 280 
        : (screenWidth - 72) / 2; 
    double cardHeight = screenWidth > 600 ? 180 : 160;
    if (screenWidth < 400) {
      cardWidth = screenWidth - 48;
    }

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: InkWell(
          key: cardKey,
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: screenWidth > 400 ? 38 : 32, color: Colors.blue),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth > 400 ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: screenWidth > 400 ? 14 : 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Gestão'),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        toolbarHeight: MediaQuery.of(context).size.height * 0.07, 
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              'Painel Administrativo',
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width > 600 ? 32 : 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sistema de gestão de clientes, produtos e pedidos.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: MediaQuery.of(context).size.width > 600 ? 18 : 14,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                alignment: WrapAlignment.center,
                                children: [
                                  buildCard(
                                    cardKey: const Key('openClientsPage'),
                                    context: context,
                                    icon: Icons.people,
                                    title: 'Clientes',
                                    description: 'Gerencie e consulte clientes cadastrados.',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const ClientListPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  buildCard(
                                    cardKey: const Key('openProductsPage'),
                                    context: context,
                                    icon: Icons.inventory,
                                    title: 'Produtos',
                                    description: 'Controle estoque e cadastro de produtos.',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const ProductListPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  buildCard(
                                    cardKey: const Key('openOrdersPage'),
                                    context: context,
                                    icon: Icons.shopping_cart,
                                    title: 'Pedidos',
                                    description: 'Criação e gerenciamento de pedidos.',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const OrderListPage(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    // Footer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.flutter_dash,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                MediaQuery.of(context).size.width > 400
                                    ? 'Desenvolvido em Flutter | Arquitetura: Riverpod + SQLite'
                                    : 'Flutter | Riverpod + SQLite | Hive',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}