import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teste_vagacrud/repositories/order/hive_order_repository.dart';
import 'package:teste_vagacrud/repositories/order/order_repository.dart';
import 'package:teste_vagacrud/repositories/order/sqlite_order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  if (kIsWeb) {
    return HiveOrderRepository();
  }
  return SqliteOrderRepository();
});