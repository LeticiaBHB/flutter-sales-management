import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/database_helper.dart';
import '../models/client.dart';

class ClientState {
  final List<Client> clients;
  final bool isLoading;
  final String? error;

  ClientState({
    this.clients = const [],
    this.isLoading = false,
    this.error,
  });

  ClientState copyWith({
    List<Client>? clients,
    bool? isLoading,
    String? error,
  }) {
    return ClientState(
      clients: clients ?? this.clients,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ClientNotifier extends Notifier<ClientState> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  @override
  ClientState build() {
    Future.microtask(fetchClients);
    return ClientState(isLoading: true);
  }

  Future<void> fetchClients() async {
    state = state.copyWith(isLoading: true);

    try {
      final db = await _db.database;
      final maps = await db.query('clients');

      final clientList = maps.map((e) => Client.fromMap(e)).toList();

      state = state.copyWith(
        clients: clientList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> saveClient(Client client) async {
    final db = await _db.database;

    if (client.id.isEmpty) {
      final newClient = Client(
        id: _uuid.v4(),
        razaoSocial: client.razaoSocial,
        cnpj: client.cnpj,
        email: client.email,
        cep: client.cep,
        logradouro: client.logradouro,
      );

      await db.insert('clients', newClient.toMap());
    } else {
      await db.update(
        'clients',
        client.toMap(),
        where: 'id = ?',
        whereArgs: [client.id],
      );
    }

    await fetchClients();
  }

  Future<void> deleteClient(String id) async {
    final db = await _db.database;

    await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );

    await fetchClients();
  }
}

final clientProvider =
NotifierProvider<ClientNotifier, ClientState>(ClientNotifier.new);