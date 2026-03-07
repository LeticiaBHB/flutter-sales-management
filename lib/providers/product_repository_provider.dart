import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teste_vagacrud/repositories/product/hive_product_repository.dart';
import 'package:teste_vagacrud/repositories/product/product_repository.dart';
import 'package:teste_vagacrud/repositories/product/sqlite_product_repository.dart';

final productRepositoryProvider =
Provider<ProductRepository>((ref) {
  if (kIsWeb) {
    return HiveProductRepository();
  }
  return SqliteProductRepository();
});