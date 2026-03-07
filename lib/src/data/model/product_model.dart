import '../../domain/entity/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.barcode,
    required super.name,
    super.description,
    required super.price,
    required super.stock,
    super.storeId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as String,
        barcode: json['barcode'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        price: (json['price'] as num).toDouble(),
        stock: json['stock'] as int,
        storeId: json['storeId'] as String?,
      );
}
