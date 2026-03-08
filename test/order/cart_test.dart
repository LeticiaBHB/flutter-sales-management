import 'package:flutter_test/flutter_test.dart';
import 'package:teste_vagacrud/models/product.dart';
import 'package:teste_vagacrud/ui/pages/orders/new_order_page.dart';

void main() {

  test('Subtotal do carrinho calcula corretamente', () {

    final product = Product(
      id: "1",
      descricao: "Produto",
      valorVenda: 20,
      estoque: 10,
      imagens: [],
    );

    final item = CartItem(
      product: product,
      quantity: 3,
    );

    expect(item.subtotal, 60);

  });

}