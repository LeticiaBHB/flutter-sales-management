import 'package:teste_vagacrud/models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<void> saveProduct(Product product);
  Future<void> deleteProduct(String id);
}