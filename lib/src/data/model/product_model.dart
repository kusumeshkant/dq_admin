import '../../domain/entity/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.barcode,
    super.sku,
    required super.name,
    super.description,
    super.brand,
    super.gender,
    super.color,
    super.categoryMain,
    super.categorySub,
    super.sizeGarment,
    super.sizeActual,
    required super.price,
    super.mrp,
    required super.stock,
    super.reorderLevel,
    super.isAvailable,
    super.storeId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as String,
        barcode: json['barcode'] as String,
        sku: json['sku'] as String?,
        name: json['name'] as String,
        description: json['description'] as String?,
        brand: json['brand'] as String?,
        gender: json['gender'] as String?,
        color: json['color'] as String?,
        categoryMain: (json['category'] as Map<String, dynamic>?)?['main'] as String?,
        categorySub: (json['category'] as Map<String, dynamic>?)?['sub'] as String?,
        sizeGarment: (json['size'] as Map<String, dynamic>?)?['garment'] as String?,
        sizeActual: (json['size'] as Map<String, dynamic>?)?['actual'] as String?,
        price: (json['price'] as num).toDouble(),
        mrp: (json['mrp'] as num?)?.toDouble(),
        stock: json['stock'] as int,
        reorderLevel: json['reorderLevel'] as int?,
        isAvailable: json['isAvailable'] as bool?,
        storeId: json['storeId'] as String?,
      );
}
