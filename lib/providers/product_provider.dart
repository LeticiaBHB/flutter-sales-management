import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../core/database_helper.dart';
import '../models/product.dart';

class ProductState {
  final List<Product> products;
  final bool isLoading;
  final String? error;

  ProductState({
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
      error: error,
    );
  }
}

class ProductNotifier extends Notifier<ProductState> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  ProductState build() {
    fetchProducts();
    return ProductState();
  }

  Future<void> fetchProducts() async {
    state = state.copyWith(isLoading: true);

    try {
      final db = await _db.database;

      final maps = await db.query('products');

      final productList = maps.map((e) => Product.fromMap(e)).toList();

      state = state.copyWith(
        products: productList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> saveProduct(Product product) async {
    final db = await _db.database;

    if (product.id.isEmpty) {
      await db.insert('products', product.toMap());
    } else {
      await db.update(
        'products',
        product.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
    }

    await fetchProducts();
  }

  Future<void> deleteProduct(String id) async {
    final db = await _db.database;

    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    await fetchProducts();
  }

  Future<List<String>> pickImages() async {
    final images = await _picker.pickMultiImage();

    if (images.isEmpty) return [];

    return images.map((img) => img.path).toList();
  }
}

final productProvider =
    NotifierProvider<ProductNotifier, ProductState>(ProductNotifier.new);