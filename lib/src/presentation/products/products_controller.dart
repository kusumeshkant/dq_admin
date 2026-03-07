import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entity/product_entity.dart';
import '../../domain/entity/store_entity.dart';
import '../../domain/usecase/get_store_products_usecase.dart';
import '../../domain/usecase/create_product_usecase.dart';
import '../../domain/usecase/update_product_usecase.dart';
import '../../domain/usecase/delete_product_usecase.dart';

class ProductsController extends GetxController {
  final StoreEntity store;
  final GetStoreProductsUseCase getStoreProductsUseCase;
  final CreateProductUseCase createProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;

  ProductsController({
    required this.store,
    required this.getStoreProductsUseCase,
    required this.createProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
  });

  final isLoading = false.obs;
  final products = <ProductEntity>[].obs;

  // Form controllers
  final barcodeCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final stockCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  @override
  void onClose() {
    barcodeCtrl.dispose();
    nameCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    stockCtrl.dispose();
    super.onClose();
  }

  Future<void> loadProducts() async {
    isLoading.value = true;
    try {
      products.value = await getStoreProductsUseCase.execute(store.id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load products',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void _clearForm() {
    barcodeCtrl.clear();
    nameCtrl.clear();
    descCtrl.clear();
    priceCtrl.clear();
    stockCtrl.clear();
  }

  void showCreateDialog() {
    _clearForm();
    _showProductDialog(title: 'New Product', lockBarcode: false, onSave: () async {
      final barcode = barcodeCtrl.text.trim();
      final name = nameCtrl.text.trim();
      final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
      final stock = int.tryParse(stockCtrl.text.trim()) ?? 0;
      if (barcode.isEmpty || name.isEmpty) return;
      final product = await createProductUseCase.execute(
        storeId: store.id,
        barcode: barcode,
        name: name,
        description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
        price: price,
        stock: stock,
      );
      products.add(product);
      Get.back();
      Get.snackbar('Done', 'Product added',
          backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
    });
  }

  void showEditDialog(ProductEntity product) {
    barcodeCtrl.text = product.barcode;
    nameCtrl.text = product.name;
    descCtrl.text = product.description ?? '';
    priceCtrl.text = product.price.toString();
    stockCtrl.text = product.stock.toString();
    _showProductDialog(title: 'Edit Product', lockBarcode: true, onSave: () async {
      final updated = await updateProductUseCase.execute(
        id: product.id,
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
        price: double.tryParse(priceCtrl.text.trim()),
        stock: int.tryParse(stockCtrl.text.trim()),
      );
      final idx = products.indexWhere((p) => p.id == product.id);
      if (idx != -1) products[idx] = updated;
      Get.back();
      Get.snackbar('Done', 'Product updated',
          backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
    });
  }

  void confirmDelete(ProductEntity product) {
    Get.defaultDialog(
      title: 'Delete Product',
      middleText: 'Delete "${product.name}"?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        await deleteProductUseCase.execute(product.id);
        products.removeWhere((p) => p.id == product.id);
        Get.snackbar('Done', 'Product deleted',
            backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
      },
    );
  }

  void _showProductDialog({required String title, required bool lockBarcode, required Future<void> Function() onSave}) {
    final isSaving = false.obs;
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1040),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(barcodeCtrl, 'Barcode', readOnly: lockBarcode),
              const SizedBox(height: 10),
              _field(nameCtrl, 'Product Name'),
              const SizedBox(height: 10),
              _field(descCtrl, 'Description (optional)'),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _field(priceCtrl, 'Price', numeric: true)),
                const SizedBox(width: 8),
                Expanded(child: _field(stockCtrl, 'Stock', numeric: true, integer: true)),
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          Obx(() => ElevatedButton(
                onPressed: isSaving.value
                    ? null
                    : () async {
                        isSaving.value = true;
                        try {
                          await onSave();
                        } catch (e) {
                          Get.snackbar('Error', e.toString(),
                              backgroundColor: Colors.red.withValues(alpha: 0.8),
                              colorText: Colors.white);
                        } finally {
                          isSaving.value = false;
                        }
                      },
                child: isSaving.value
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save'),
              )),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, {bool numeric = false, bool integer = false, bool readOnly = false}) {
    return TextField(
      controller: ctrl,
      readOnly: readOnly,
      style: TextStyle(color: readOnly ? Colors.grey : Colors.white),
      keyboardType: integer
          ? TextInputType.number
          : numeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFCDB4DB)),
        filled: true,
        fillColor: const Color(0x26FFFFFF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0x33FFFFFF))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0x33FFFFFF))),
      ),
    );
  }
}
