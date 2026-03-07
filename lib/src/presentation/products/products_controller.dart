import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entity/product_entity.dart';
import '../../domain/entity/store_entity.dart';
import '../../domain/usecase/get_store_products_usecase.dart';
import '../../domain/usecase/create_product_usecase.dart';
import '../../domain/usecase/update_product_usecase.dart';
import '../../domain/usecase/delete_product_usecase.dart';
import 'barcode_scanner_page.dart';

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
  final skuCtrl = TextEditingController();
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
    skuCtrl.dispose();
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
    skuCtrl.clear();
    nameCtrl.clear();
    descCtrl.clear();
    priceCtrl.clear();
    stockCtrl.clear();
  }

  void showCreateDialog() {
    _clearForm();
    _showProductSheet(isCreate: true, onSave: () async {
      final barcode = barcodeCtrl.text.trim();
      final name = nameCtrl.text.trim();
      final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
      final stock = int.tryParse(stockCtrl.text.trim()) ?? 0;
      if (barcode.isEmpty || name.isEmpty) return;
      final product = await createProductUseCase.execute(
        storeId: store.id,
        barcode: barcode,
        sku: skuCtrl.text.trim().isEmpty ? null : skuCtrl.text.trim(),
        name: name,
        description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
        price: price,
        stock: stock,
      );
      products.add(product);
      Get.back();
      Get.snackbar('Done', 'Product added',
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white);
    });
  }

  void showEditDialog(ProductEntity product) {
    barcodeCtrl.text = product.barcode;
    skuCtrl.text = product.sku ?? '';
    nameCtrl.text = product.name;
    descCtrl.text = product.description ?? '';
    priceCtrl.text = product.price.toString();
    stockCtrl.text = product.stock.toString();
    _showProductSheet(isCreate: false, onSave: () async {
      final updated = await updateProductUseCase.execute(
        id: product.id,
        sku: skuCtrl.text.trim().isEmpty ? null : skuCtrl.text.trim(),
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
        price: double.tryParse(priceCtrl.text.trim()),
        stock: int.tryParse(stockCtrl.text.trim()),
      );
      final idx = products.indexWhere((p) => p.id == product.id);
      if (idx != -1) products[idx] = updated;
      Get.back();
      Get.snackbar('Done', 'Product updated',
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white);
    });
  }

  void confirmDelete(ProductEntity product) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        decoration: const BoxDecoration(
          color: Color(0xFF1A0D35),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_rounded, color: Colors.red, size: 26),
            ),
            const SizedBox(height: 14),
            const Text('Delete Product',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to delete "${product.name}"?\nThis action cannot be undone.',
              style: const TextStyle(color: Color(0xFFCDB4DB), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: Get.back,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      await deleteProductUseCase.execute(product.id);
                      products.removeWhere((p) => p.id == product.id);
                      Get.snackbar('Deleted', '"${product.name}" removed.',
                          backgroundColor:
                              Colors.green.withValues(alpha: 0.8),
                          colorText: Colors.white);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Delete',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showProductSheet({
    required bool isCreate,
    required Future<void> Function() onSave,
  }) {
    final isSaving = false.obs;
    Get.bottomSheet(
      _ProductFormSheet(
        isCreate: isCreate,
        isSaving: isSaving,
        barcodeCtrl: barcodeCtrl,
        skuCtrl: skuCtrl,
        nameCtrl: nameCtrl,
        descCtrl: descCtrl,
        priceCtrl: priceCtrl,
        stockCtrl: stockCtrl,
        onSave: () async {
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
      ),
      isScrollControlled: true,
    );
  }
}

// ── Product form bottom sheet ──────────────────────────────────────────────────

class _ProductFormSheet extends StatefulWidget {
  final bool isCreate;
  final RxBool isSaving;
  final TextEditingController barcodeCtrl;
  final TextEditingController skuCtrl;
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController stockCtrl;
  final VoidCallback onSave;

  const _ProductFormSheet({
    required this.isCreate,
    required this.isSaving,
    required this.barcodeCtrl,
    required this.skuCtrl,
    required this.nameCtrl,
    required this.descCtrl,
    required this.priceCtrl,
    required this.stockCtrl,
    required this.onSave,
  });

  @override
  State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  bool _scanning = false;

  Future<void> _scanBarcode() async {
    setState(() => _scanning = true);
    try {
      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
      );
      if (result != null && result.isNotEmpty) {
        widget.barcodeCtrl.text = result;
      }
    } finally {
      setState(() => _scanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Color(0xFF1A0D35),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.isCreate
                          ? Icons.add_box_rounded
                          : Icons.edit_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.isCreate ? 'New Product' : 'Edit Product',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Barcode field + scan button
              Row(
                children: [
                  Expanded(
                    child: _field(
                      widget.barcodeCtrl,
                      'Barcode',
                      icon: Icons.barcode_reader,
                      readOnly: !widget.isCreate,
                    ),
                  ),
                  if (widget.isCreate) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _scanning ? null : _scanBarcode,
                      child: Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.35)),
                        ),
                        child: _scanning
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.orange))
                            : const Icon(Icons.qr_code_scanner_rounded,
                                color: Colors.orange, size: 22),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),

              // SKU
              _field(widget.skuCtrl, 'SKU (optional)',
                  icon: Icons.qr_code_rounded),
              const SizedBox(height: 10),

              // Name
              _field(widget.nameCtrl, 'Product Name',
                  icon: Icons.label_rounded),
              const SizedBox(height: 10),

              // Description
              _field(widget.descCtrl, 'Description (optional)',
                  icon: Icons.notes_rounded),
              const SizedBox(height: 10),

              // Price + Stock
              Row(
                children: [
                  Expanded(
                    child: _field(widget.priceCtrl, 'Price (₹)',
                        icon: Icons.currency_rupee_rounded, numeric: true),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _field(widget.stockCtrl, 'Stock',
                        icon: Icons.inventory_rounded,
                        numeric: true,
                        integer: true),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: Get.back,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Obx(() => ElevatedButton(
                          onPressed:
                              widget.isSaving.value ? null : widget.onSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: widget.isSaving.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : Text(
                                  widget.isCreate
                                      ? 'Add Product'
                                      : 'Save Changes',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    bool numeric = false,
    bool integer = false,
    bool readOnly = false,
    IconData? icon,
  }) {
    return TextField(
      controller: ctrl,
      readOnly: readOnly,
      style: TextStyle(
          color: readOnly ? Colors.white38 : Colors.white, fontSize: 14),
      keyboardType: integer
          ? TextInputType.number
          : numeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFCDB4DB), fontSize: 12),
        prefixIcon: icon != null
            ? Icon(icon, color: const Color(0xFFCDB4DB), size: 16)
            : null,
        filled: true,
        fillColor: readOnly
            ? const Color(0x0DFFFFFF)
            : const Color(0x1AFFFFFF),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0x33FFFFFF))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0x33FFFFFF))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.orange)),
      ),
    );
  }
}
