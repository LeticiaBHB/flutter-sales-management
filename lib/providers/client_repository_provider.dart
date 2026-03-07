import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/client/client_repository.dart';
import '../repositories/client/hive_client_repository.dart';
import '../repositories/client/sqlite_client_repository.dart';

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  if (kIsWeb) {
    return HiveClientRepository();
  }
  return SqliteClientRepository();
});