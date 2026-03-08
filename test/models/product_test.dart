import 'package:flutter_test/flutter_test.dart';
import 'package:teste_vagacrud/models/product.dart';

void main() {

  test('Product toMap e fromMap funcionam corretamente', () {

    final product = Product(
      id: "1",
      descricao: "Produto Teste",
      valorVenda: 10.5,
      estoque: 5,
      imagens: ["img1.png", "img2.png"],
    );

    final map = product.toMap();

    final productFromMap = Product.fromMap(map);

    expect(productFromMap.id, "1");
    expect(productFromMap.descricao, "Produto Teste");
    expect(productFromMap.valorVenda, 10.5);
    expect(productFromMap.estoque, 5);
    expect(productFromMap.imagens.length, 2);

  });

}