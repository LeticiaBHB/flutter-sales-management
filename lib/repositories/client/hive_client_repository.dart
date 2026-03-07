import 'package:hive/hive.dart';
import '../../models/client.dart';
import 'client_repository.dart';

class HiveClientRepository implements ClientRepository {
  static const boxName = 'clients';
  Future<Box> _box() async {
    return await Hive.openBox(boxName);
  }

  @override
  Future<List<Client>> getClients() async {
    final box = await _box();
    return box.values
        .map((e) => Client.fromMap(Map<String,dynamic>.from(e)))
        .toList();
  }

  @override
  Future<void> saveClient(Client client) async {
    final box = await _box();
    await box.put(client.id, client.toMap());
  }

  @override
  Future<void> deleteClient(String id) async {
    final box = await _box();
    await box.delete(id);
  }
}