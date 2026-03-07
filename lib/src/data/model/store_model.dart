import '../../domain/entity/store_entity.dart';

class StoreModel extends StoreEntity {
  const StoreModel({
    required super.id,
    super.storeCode,
    required super.name,
    super.address,
    super.latitude,
    super.longitude,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) => StoreModel(
        id: json['id'] as String,
        storeCode: json['storeCode'] as String?,
        name: json['name'] as String,
        address: json['address'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );
}
