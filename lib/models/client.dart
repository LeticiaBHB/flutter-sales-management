class Client {
  final String id;
  final String razaoSocial;
  final String cnpj;
  final String email;
  final String cep;
  final String logradouro;

  Client({
    required this.id,
    required this.razaoSocial,
    required this.cnpj,
    required this.email,
    required this.cep,
    required this.logradouro,
  });

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      razaoSocial: map['razaoSocial'],
      cnpj: map['cnpj'],
      email: map['email'],
      cep: map['cep'],
      logradouro: map['logradouro'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "razaoSocial": razaoSocial,
      "cnpj": cnpj,
      "email": email,
      "cep": cep,
      "logradouro": logradouro,
    };
  }
}