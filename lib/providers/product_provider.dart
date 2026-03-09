import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/product.dart';
import '../repositories/product/product_repository.dart';
import 'product_repository_provider.dart';

final productProvider =
    NotifierProvider<ProductNotifier, ProductState>(ProductNotifier.new);

class ProductState {
  final List<Product> products;
  final bool isLoading;
  final String? error;

  const ProductState({
    this.products = const [],
    this.isLoading = false,
    this.error,
  });

  ProductState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ProductNotifier extends Notifier<ProductState> {
  late final ProductRepository repository;

  @override
  ProductState build() {
    repository = ref.read(productRepositoryProvider);
    Future.microtask(() => fetchProducts());
    return const ProductState();
  }

  /// BUSCAR PRODUTOS
  Future<void> fetchProducts() async {
    try {
      state = state.copyWith(isLoading: true);

      final products = await repository.getProducts();

      state = state.copyWith(
        products: products,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// SALVAR PRODUTO
  Future<void> saveProduct(Product product) async {
    try {
      await repository.saveProduct(product);
      await fetchProducts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// DELETAR PRODUTO
  Future<void> deleteProduct(String id) async {
    try {
      await repository.deleteProduct(id);
      await fetchProducts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// PICK IMAGES
  Future<List<String>> pickImages() async {
    final ImagePicker picker = ImagePicker();

    final List<XFile> images = await picker.pickMultiImage();

    return images.map((img) => img.path).toList();
  }

   /// DIMINUIR ESTOQUE APÓS VENDA
  Future<void> decreaseStock(String productId, int quantity) async {
    try {
      final product = state.products.firstWhere((p) => p.id == productId);

      if (product.estoque < quantity) {
        throw Exception('Estoque insuficiente para o produto ${product.descricao}');
      }
      final updatedProduct = Product(
        id: product.id,
        descricao: product.descricao,
        valorVenda: product.valorVenda,
        estoque: product.estoque - quantity,
        imagens: product.imagens,
      );
      await repository.saveProduct(updatedProduct);
      await fetchProducts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow; 
    }
  }

  /// AUMENTAR ESTOQUE (DEVOLVER AO CANCELAR/EXCLUIR)
  Future<void> increaseStock(String productId, int quantity) async {
    try {
      // Encontra o produto na lista atual
      final product = state.products.firstWhere((p) => p.id == productId);

      final updatedProduct = Product(
        id: product.id,
        descricao: product.descricao,
        valorVenda: product.valorVenda,
        estoque: product.estoque + quantity,
        imagens: product.imagens,
      );
      await repository.saveProduct(updatedProduct);
      await fetchProducts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow; 
    }
  }
}
