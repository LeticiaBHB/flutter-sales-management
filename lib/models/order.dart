class Order {
  final String id;
  final String clienteId;
  final String clienteNome;
  final String data;
  final double valorTotal;
  final List<Map<String, dynamic>> itens;

  Order({
    required this.id,
    required this.clienteId,
    required this.clienteNome,
    required this.data,
    required this.valorTotal,
    required this.itens,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clienteId': clienteId,
      'clienteNome': clienteNome,
      'data': data,
      'valorTotal': valorTotal,
      'itens': itens,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      clienteId: map['clienteId'],
      clienteNome: map['clienteNome'] ?? 'Desconhecido',
      data: map['data'],
      valorTotal: (map['valorTotal'] as num).toDouble(),
      itens: List<Map<String, dynamic>>.from(map['itens'] ?? []),
    );
  }
}