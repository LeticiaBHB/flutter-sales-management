import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/client.dart';
import '../../../providers/client_provider.dart';
import '../../../services/api_service.dart';
import 'package:uuid/uuid.dart';
class ClientFormPage extends ConsumerStatefulWidget {
  final Client? client; 

  const ClientFormPage({super.key, this.client});

  @override
  ConsumerState<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends ConsumerState<ClientFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  bool _isSearchingCep = false;
  late TextEditingController _razaoSocialController;
  late TextEditingController _cnpjController;
  late TextEditingController _emailController;
  late TextEditingController _cepController;
  late TextEditingController _logradouroController;

  @override
  void initState() {
    super.initState();
    _razaoSocialController = TextEditingController(
      text: widget.client?.razaoSocial ?? '',
    );
    _cnpjController = TextEditingController(text: widget.client?.cnpj ?? '');
    _emailController = TextEditingController(text: widget.client?.email ?? '');
    _cepController = TextEditingController(text: widget.client?.cep ?? '');
    _logradouroController = TextEditingController(
      text: widget.client?.logradouro ?? '',
    );
  }

  @override
  void dispose() {
    _razaoSocialController.dispose();
    _cnpjController.dispose();
    _emailController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    super.dispose();
  }
  Future<void> _buscarEndereco() async {
    final cep = _cepController.text.trim();
    if (cep.isEmpty) return;

    setState(() {
      _isSearchingCep = true;
    });

    try {
      final address = await _apiService.getAddressByCep(cep);
      setState(() {
        _logradouroController.text =
            "${address.logradouro}, ${address.bairro} - ${address.cidade}";
        _isSearchingCep = false;
      });
    } catch (e) {
      setState(() {
        _isSearchingCep = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao buscar CEP: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;
    final client = Client(
      id: widget.client?.id ?? const Uuid().v4(),
      razaoSocial: _razaoSocialController.text,
      cnpj: _cnpjController.text,
      email: _emailController.text,
      cep: _cepController.text,
      logradouro: _logradouroController.text,
    );

    try {
      await ref.read(clientProvider.notifier).saveClient(client);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cliente salvo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client == null ? 'Novo Cliente' : 'Editar Cliente'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _razaoSocialController,
                decoration: const InputDecoration(
                  labelText: 'Razão Social',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a Razão Social';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cnpjController,
                decoration: const InputDecoration(
                  labelText: 'CNPJ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.assignment_ind),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o CNPJ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o E-mail';
                  }
                  if (!value.contains('@')) {
                    return 'Insira um e-mail válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Endereço (API ViaCEP)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cepController,
                      decoration: const InputDecoration(
                        labelText: 'CEP',
                        border: OutlineInputBorder(),
                        hintText: 'Apenas números',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 80,
                    height: 56,
                    child: _isSearchingCep
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _buscarEndereco,
                            child: const Text('Buscar'),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _logradouroController,
                decoration: const InputDecoration(
                  labelText: 'Logradouro / Bairro - Cidade',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.map),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveClient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Salvar Cliente',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
