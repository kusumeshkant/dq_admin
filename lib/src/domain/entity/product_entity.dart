class ProductEntity {
  final String id;
  final String barcode;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? storeId;

  const ProductEntity({
    required this.id,
    required this.barcode,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.storeId,
  });
}
