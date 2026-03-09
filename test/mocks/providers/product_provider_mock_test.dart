import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:teste_vagacrud/models/product.dart';
import 'package:teste_vagacrud/providers/product_provider.dart';
import 'package:teste_vagacrud/providers/product_repository_provider.dart';
import '../mock_product_repository.dart';

void main() {

  test('Provider carrega produtos do repository', () async {

    final mockRepository = MockProductRepository();

    final fakeProducts = [
      Product(
        id: "1",
        descricao: "Produto Teste",
        valorVenda: 10,
        estoque: 5,
        imagens: [],
      )
    ];

    when(mockRepository.getProducts())
        .thenAnswer((_) async => fakeProducts);

    final container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );

    await container.read(productProvider.notifier).fetchProducts();

    final state = container.read(productProvider);

    expect(state.products.length, 1);
    expect(state.products.first.descricao, "Produto Teste");

  });

}