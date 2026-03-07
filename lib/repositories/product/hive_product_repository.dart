import 'package:hive/hive.dart';
import 'package:teste_vagacrud/models/product.dart';
import 'product_repository.dart';

class HiveProductRepository implements ProductRepository {

  static const boxName = 'products';

  Future<Box> _box() async {
    return await Hive.openBox(boxName);
  }

  @override
  Future<List<Product>> getProducts() async {

    final box = await _box();

    return box.values
        .map((e) => Product.fromMap(Map<String,dynamic>.from(e)))
        .toList();
  }

  @override
  Future<void> saveProduct(Product product) async {

    final box = await _box();

    await box.put(product.id, product.toMap());
  }

  @override
  Future<void> deleteProduct(String id) async {

    final box = await _box();

    await box.delete(id);
  }
}