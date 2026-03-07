import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teste_vagacrud/ui/pages/clients/client_form_page.dart';
import '../../../providers/client_provider.dart';

class ClientListPage extends ConsumerWidget {
  const ClientListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(clientProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Clientes'), centerTitle: true),
      body: asyncState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : asyncState.error != null
          ? Center(child: Text('Erro: ${asyncState.error}'))
          : asyncState.clients.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('Nenhum cliente cadastrado'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: asyncState.clients.length,
              itemBuilder: (ctx, index) {
                final client = asyncState.clients[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(
                      client.razaoSocial,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("CNPJ: ${client.cnpj}"),
                        Text("Email: ${client.email}"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ClientFormPage(client: client),
                              ),
                            );
                            if (result == true) {
                              ref.read(clientProvider.notifier).fetchClients();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            ref
                                .read(clientProvider.notifier)
                                .deleteClient(client.id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.person_add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ClientFormPage()),
          );
          if (result == true) {
            ref.read(clientProvider.notifier).fetchClients();
          }
        },
      ),
    );
  }
}
