class ProductEntity {
  final String id;
  final String barcode;
  final String? sku;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? storeId;

  const ProductEntity({
    required this.id,
    required this.barcode,
    this.sku,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.storeId,
  });
}
