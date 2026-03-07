class Product {
  final String id;
  final String descricao;
  final double valorVenda;
  final int estoque;
  final List<String> imagens;

  Product({
    required this.id,
    required this.descricao,
    required this.valorVenda,
    required this.estoque,
    required this.imagens,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': descricao,
      'valorVenda': valorVenda,
      'estoque': estoque,
      'imagens': imagens.join(','), 
    };
  }

  // Criar do Map
  factory Product.fromMap(Map<String, dynamic> map) {
  return Product(
    id: map['id'],
    descricao: map['descricao'],
    valorVenda: map['valorVenda'],
    estoque: map['estoque'],
    imagens: map['imagens'] == null || map['imagens'] == ''
        ? []
        : map['imagens'].toString().split(','),
  );}
}