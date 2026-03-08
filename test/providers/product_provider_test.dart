import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teste_vagacrud/providers/product_provider.dart';

void main() {
  test('ProductProvider inicia vazio', () {
    final container = ProviderContainer();
    final state = container.read(productProvider);
    expect(state.products.isEmpty, true);
  });

}