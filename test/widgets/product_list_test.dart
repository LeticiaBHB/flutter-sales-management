import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teste_vagacrud/ui/pages/products/product_list_page.dart';

void main() {
  testWidgets('Tela de produtos carrega', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProductListPage(),
        ),
      ),
    );
    expect(find.text('Produtos'), findsOneWidget);

  });

}