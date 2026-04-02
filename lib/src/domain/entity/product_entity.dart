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

class BulkProductInput {
  final String barcode;
  final String name;
  final String? sku;
  final double price;
  final double? mrp;
  final int stock;
  final String? brand;
  final String? gender;
  final String? color;
  final String? categoryMain;
  final String? categorySub;
  final String? sizeGarment;
  final String? sizeActual;

  const BulkProductInput({
    required this.barcode,
    required this.name,
    this.sku,
    required this.price,
    this.mrp,
    required this.stock,
    this.brand,
    this.gender,
    this.color,
    this.categoryMain,
    this.categorySub,
    this.sizeGarment,
    this.sizeActual,
  });
}

class BulkProductErrorEntity {
  final String barcode;
  final String message;
  const BulkProductErrorEntity({required this.barcode, required this.message});
}

class BulkUpsertResultEntity {
  final int created;
  final int updated;
  final int skipped;
  final List<BulkProductErrorEntity> errors;
  const BulkUpsertResultEntity({required this.created, required this.updated, required this.skipped, required this.errors});
}

class UploadLogEntity {
  final String id;
  final String storeId;
  final String? storeName;
  final String uploadedByName;
  final String fileName;
  final DateTime uploadedAt;
  final int totalRows;
  final int totalColumns;
  final int created;
  final int updated;
  final int skipped;
  final int errorCount;
  final List<BulkProductErrorEntity> errors;

  const UploadLogEntity({
    required this.id,
    required this.storeId,
    this.storeName,
    required this.uploadedByName,
    required this.fileName,
    required this.uploadedAt,
    required this.totalRows,
    required this.totalColumns,
    required this.created,
    required this.updated,
    required this.skipped,
    required this.errorCount,
    required this.errors,
  });
}
