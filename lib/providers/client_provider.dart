import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/client.dart';
import '../repositories/client/client_repository.dart';
import 'client_repository_provider.dart';

class ClientState {
  final List<Client> clients;
  final bool isLoading;
  final String? error;

  const ClientState({
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
  late final ClientRepository repository;
  @override
  ClientState build() {
    repository = ref.read(clientRepositoryProvider);
    Future.microtask(fetchClients);
    return const ClientState(isLoading: true);
  }

  Future<void> fetchClients() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final clients = await repository.getClients();
      state = state.copyWith(
        clients: clients,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> saveClient(Client client) async {
    try {
      await repository.saveClient(client);
      await fetchClients();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteClient(String id) async {
    try {
      await repository.deleteClient(id);
      await fetchClients();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final clientProvider =
    NotifierProvider<ClientNotifier, ClientState>(ClientNotifier.new);