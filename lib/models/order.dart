class Order {
  final String id;
  final String clienteId;
  final String clienteNome; 
  final String data;
  final double valorTotal;

  Order({
    required this.id,
    required this.clienteId,
    required this.clienteNome,
    required this.data,
    required this.valorTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clienteId': clienteId,
      'data': data,
      'valorTotal': valorTotal,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      clienteId: map['clienteId'],
      clienteNome: map['clienteNome'] ?? 'Desconhecido',
      data: map['data'],
      valorTotal: map['valorTotal'],
    );
  }
}