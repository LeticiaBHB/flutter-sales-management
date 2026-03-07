import '../../models/client.dart';

abstract class ClientRepository {
  Future<List<Client>> getClients();
  Future<void> saveClient(Client client);
  Future<void> deleteClient(String id);
}