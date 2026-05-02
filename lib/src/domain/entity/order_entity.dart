class OrderItemEntity {
  final String barcode;
  final String name;
  final double price;
  final int quantity;

  const OrderItemEntity({
    required this.barcode,
    required this.name,
    required this.price,
    required this.quantity,
  });
}

class StaffActionEntity {
  final String? staffId;
  final String? staffName;
  final String action;
  final String timestamp;
  final String? note;

  const StaffActionEntity({
    this.staffId,
    this.staffName,
    required this.action,
    required this.timestamp,
    this.note,
  });
}

class FlaggedIssueEntity {
  final String reason;
  final String? note;
  final String? staffName;
  final String timestamp;

  const FlaggedIssueEntity({
    required this.reason,
    this.note,
    this.staffName,
    required this.timestamp,
  });
}

class OrderEntity {
  final String id;
  final String? storeId;
  final String? storeName;
  final double total;
  final double tax;
  final double grandTotal;
  final String status;
  final String createdAt;
  final List<OrderItemEntity> items;
  final List<StaffActionEntity> staffActions;
  final FlaggedIssueEntity? flaggedIssue;

  const OrderEntity({
    required this.id,
    this.storeId,
    this.storeName,
    required this.total,
    required this.tax,
    required this.grandTotal,
    required this.status,
    required this.createdAt,
    required this.items,
    required this.staffActions,
    this.flaggedIssue,
  });

  bool get isFlagged => flaggedIssue != null;

  String get formattedDate {
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day/$month/${dt.year}  $hour:$minute';
    } catch (_) {
      return createdAt;
    }
  }
}
