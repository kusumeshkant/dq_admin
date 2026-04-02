import '../entity/product_entity.dart';
import '../repo/product_repository.dart';

class GetUploadLogsUseCase {
  final ProductRepository repo;
  GetUploadLogsUseCase(this.repo);

  Future<List<UploadLogEntity>> execute(String storeId) => repo.getUploadLogs(storeId);
}
