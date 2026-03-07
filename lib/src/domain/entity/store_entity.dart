class StoreEntity {
  final String id;
  final String? storeCode;
  final String name;
  final String? address;
  final double? latitude;
  final double? longitude;

  const StoreEntity({
    required this.id,
    this.storeCode,
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
  });
}
