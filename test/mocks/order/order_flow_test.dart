import 'package:flutter_test/flutter_test.dart';
import 'package:teste_vagacrud/models/product.dart';
import 'package:teste_vagacrud/ui/pages/orders/new_order_page.dart';

void main() {

  test('Fluxo de venda calcula total corretamente', () {

    final product1 = Product(
      id: "1",
      descricao: "Produto A",
      valorVenda: 10,
      estoque: 10,
      imagens: [],
    );

    final product2 = Product(
      id: "2",
      descricao: "Produto B",
      valorVenda: 20,
      estoque: 10,
      imagens: [],
    );

    final item1 = CartItem(
      product: product1,
      quantity: 2,
    );

    final item2 = CartItem(
      product: product2,
      quantity: 1,
    );

    final total = item1.subtotal + item2.subtotal;
    expect(total, 40);

  });

}