import 'dart:convert';
import 'package:http/http.dart' as http;

class Address {
  final String logradouro;
  final String bairro;
  final String cidade;
  Address({required this.logradouro, required this.bairro, required this.cidade});
}

class ApiService {
  final String baseUrl = "https://viacep.com.br/ws";

  Future<Address> getAddressByCep(String cep) async {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanCep.length != 8) {
      throw Exception("CEP inválido");
    }
    final response = await http.get(Uri.parse('$baseUrl/$cleanCep/json/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey('erro')) {
        throw Exception("CEP não encontrado");
      }
      return Address(
        logradouro: data['logradouro'] ?? '',
        bairro: data['bairro'] ?? '',
        cidade: data['localidade'] ?? '',
      );
    } else {
      throw Exception("Falha ao buscar CEP");
    }
  }
}