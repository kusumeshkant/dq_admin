import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../domain/entity/store_entity.dart';
import '../../domain/usecase/get_all_stores_usecase.dart';
import '../../domain/usecase/create_store_usecase.dart';
import '../../domain/usecase/update_store_usecase.dart';
import '../../domain/usecase/delete_store_usecase.dart';
import '../../service_core/auth/session_manager.dart';
import 'map_picker_page.dart';

class StoresController extends GetxController {
  final GetAllStoresUseCase getAllStoresUseCase;
  final CreateStoreUseCase createStoreUseCase;
  final UpdateStoreUseCase updateStoreUseCase;
  final DeleteStoreUseCase deleteStoreUseCase;

  StoresController({
    required this.getAllStoresUseCase,
    required this.createStoreUseCase,
    required this.updateStoreUseCase,
    required this.deleteStoreUseCase,
  });

  final isLoading = false.obs;
  final stores = <StoreEntity>[].obs;

  // Form fields
  final nameCtrl = TextEditingController();
  final storeCodeCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final latCtrl = TextEditingController();
  final lonCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadStores();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    storeCodeCtrl.dispose();
    addressCtrl.dispose();
    latCtrl.dispose();
    lonCtrl.dispose();
    super.onClose();
  }

  Future<void> loadStores() async {
    isLoading.value = true;
    try {
      final all = await getAllStoresUseCase.execute();
      final storeId = Get.find<SessionManager>().storeId;
      // Scoped admin: only show their own store
      stores.value = (storeId != null && storeId.isNotEmpty)
          ? all.where((s) => s.id == storeId).toList()
          : all;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load stores',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void _clearForm() {
    nameCtrl.clear();
    storeCodeCtrl.clear();
    addressCtrl.clear();
    latCtrl.clear();
    lonCtrl.clear();
  }

  /// Generates a unique store code: [NAME_3]-[CITY_3]-[4_DIGITS]
  /// e.g. Style Studio, Mumbai → STY-MUM-4821
  static String generateStoreCode(String name, String city) {
    final rng = Random();
    final nameLetters = name.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    final cityLetters = city.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    final namePrefix = nameLetters.substring(0, nameLetters.length.clamp(0, 3)).toUpperCase().padRight(3, 'X');
    final cityPrefix = cityLetters.substring(0, cityLetters.length.clamp(0, 3)).toUpperCase().padRight(3, 'X');
    final digits = (1000 + rng.nextInt(9000)).toString();
    return '$namePrefix-$cityPrefix-$digits';
  }

  /// Legacy: prefix-only from name (used internally for auto-suggest while typing)
  static String suggestCodePrefix(String name) {
    final letters = name.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    return letters.substring(0, letters.length.clamp(0, 3)).toUpperCase().padRight(3, 'X');
  }

  void showCreateDialog() {
    _clearForm();
    _showStoreDialog(isCreate: true, title: 'New Store', onSave: () async {
      final name = nameCtrl.text.trim();
      final address = addressCtrl.text.trim();
      final lat = double.tryParse(latCtrl.text.trim()) ?? 0.0;
      final lon = double.tryParse(lonCtrl.text.trim()) ?? 0.0;
      final code = storeCodeCtrl.text.trim();
      if (name.isEmpty || address.isEmpty) return;
      final store = await createStoreUseCase.execute(
          name: name, address: address, lat: lat, lon: lon,
          storeCode: code.isNotEmpty ? code : null);
      stores.add(store);
      Get.back();
      Get.snackbar('Done', 'Store created  ·  ${store.storeCode ?? ''}',
          backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
    });
  }

  void showEditDialog(StoreEntity store) {
    nameCtrl.text = store.name;
    storeCodeCtrl.text = store.storeCode ?? '';
    addressCtrl.text = store.address ?? '';
    latCtrl.text = store.latitude?.toString() ?? '';
    lonCtrl.text = store.longitude?.toString() ?? '';
    _showStoreDialog(isCreate: false, title: 'Edit Store', onSave: () async {
      final updated = await updateStoreUseCase.execute(
        id: store.id,
        name: nameCtrl.text.trim(),
        address: addressCtrl.text.trim(),
        lat: double.tryParse(latCtrl.text.trim()),
        lon: double.tryParse(lonCtrl.text.trim()),
        storeCode: storeCodeCtrl.text.trim().isNotEmpty ? storeCodeCtrl.text.trim() : null,
      );
      final idx = stores.indexWhere((s) => s.id == store.id);
      if (idx != -1) stores[idx] = updated;
      Get.back();
      Get.snackbar('Done', 'Store updated', backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
    });
  }

  void confirmDelete(StoreEntity store) {
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
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
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
            const Text('Delete Store',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to delete "${store.name}"?\nThis action cannot be undone.',
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      await deleteStoreUseCase.execute(store.id);
                      stores.removeWhere((s) => s.id == store.id);
                      Get.snackbar('Deleted', '"${store.name}" has been removed.',
                          backgroundColor: Colors.green.withValues(alpha: 0.8),
                          colorText: Colors.white);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _showStoreDialog({
    required String title,
    required bool isCreate,
    required Future<void> Function() onSave,
  }) {
    final isSaving = false.obs;

    Get.bottomSheet(
      _StoreFormSheet(
        title: title,
        isCreate: isCreate,
        isSaving: isSaving,
        nameCtrl: nameCtrl,
        storeCodeCtrl: storeCodeCtrl,
        addressCtrl: addressCtrl,
        latCtrl: latCtrl,
        lonCtrl: lonCtrl,
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

// ── Store form bottom sheet ────────────────────────────────────────────────────

class _StoreFormSheet extends StatefulWidget {
  final String title;
  final bool isCreate;
  final RxBool isSaving;
  final TextEditingController nameCtrl;
  final TextEditingController storeCodeCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController latCtrl;
  final TextEditingController lonCtrl;
  final VoidCallback onSave;

  const _StoreFormSheet({
    required this.title,
    required this.isCreate,
    required this.isSaving,
    required this.nameCtrl,
    required this.storeCodeCtrl,
    required this.addressCtrl,
    required this.latCtrl,
    required this.lonCtrl,
    required this.onSave,
  });

  @override
  State<_StoreFormSheet> createState() => _StoreFormSheetState();
}

class _StoreFormSheetState extends State<_StoreFormSheet> {
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    if (widget.isCreate) {
      widget.nameCtrl.addListener(_onNameChanged);
    }
  }

  @override
  void dispose() {
    if (widget.isCreate) {
      widget.nameCtrl.removeListener(_onNameChanged);
    }
    super.dispose();
  }

  void _onNameChanged() {
    // Only auto-suggest when user hasn't manually typed a code
    final suggested = StoresController.suggestCodePrefix(widget.nameCtrl.text);
    // Don't override if user has manually edited the code field to something custom
    final current = widget.storeCodeCtrl.text;
    if (current.isEmpty || current == StoresController.suggestCodePrefix(_lastAutoSuggestName)) {
      widget.storeCodeCtrl.text = suggested;
    }
    _lastAutoSuggestName = widget.nameCtrl.text;
  }

  String _lastAutoSuggestName = '';

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Location Off', 'Please enable location services.',
            backgroundColor: Colors.orange.withValues(alpha: 0.85),
            colorText: Colors.white);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Permission Denied', 'Location permission is required.',
              backgroundColor: Colors.red.withValues(alpha: 0.85),
              colorText: Colors.white);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Permission Denied', 'Enable location in app settings.',
            backgroundColor: Colors.red.withValues(alpha: 0.85),
            colorText: Colors.white);
        return;
      }

      Position? pos;
      try {
        pos = await Geolocator.getLastKnownPosition();
      } catch (_) {}

      pos ??= await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 10)));

      widget.latCtrl.text = pos.latitude.toStringAsFixed(6);
      widget.lonCtrl.text = pos.longitude.toStringAsFixed(6);
    } catch (e) {
      Get.snackbar('Error', 'Could not get location.',
          backgroundColor: Colors.red.withValues(alpha: 0.85),
          colorText: Colors.white);
    } finally {
      setState(() => _locating = false);
    }
  }

  Future<void> _pickOnMap() async {
    final initialLat = double.tryParse(widget.latCtrl.text) ?? 12.9716;
    final initialLon = double.tryParse(widget.lonCtrl.text) ?? 77.5946;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerPage(
          initialLat: initialLat,
          initialLon: initialLon,
        ),
      ),
    );

    if (result != null) {
      widget.latCtrl.text = result.latitude.toStringAsFixed(6);
      widget.lonCtrl.text = result.longitude.toStringAsFixed(6);
      if (result.address.isNotEmpty &&
          result.address != 'Could not fetch address' &&
          result.address != 'Tap on the map to place the pin' &&
          widget.addressCtrl.text.trim().isEmpty) {
        widget.addressCtrl.text = result.address;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B2FBE).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.isCreate
                          ? Icons.add_business_rounded
                          : Icons.edit_rounded,
                      color: const Color(0xFFCDB4DB),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(widget.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),

              // Store Name
              _field(widget.nameCtrl, 'Store Name',
                  icon: Icons.storefront_rounded),
              const SizedBox(height: 10),

              // Store Code
              _field(
                widget.storeCodeCtrl,
                'Store Code (e.g. NIK001)',
                icon: Icons.tag_rounded,
                hint: widget.isCreate ? 'Auto-generated from name' : null,
                uppercase: true,
              ),
              const SizedBox(height: 10),

              // Address
              _field(widget.addressCtrl, 'Address',
                  icon: Icons.location_on_outlined),
              const SizedBox(height: 14),

              // Coordinates label + action buttons
              Row(
                children: [
                  const Text('Coordinates',
                      style: TextStyle(
                          color: Color(0xFFCDB4DB),
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  const Spacer(),
                  // Current location button
                  GestureDetector(
                    onTap: _locating ? null : _useCurrentLocation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _locating
                              ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: Colors.blueAccent))
                              : const Icon(Icons.my_location_rounded,
                                  color: Colors.blueAccent, size: 13),
                          const SizedBox(width: 4),
                          const Text('Current',
                              style: TextStyle(
                                  color: Colors.blueAccent, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Pick on map button
                  GestureDetector(
                    onTap: _pickOnMap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.map_rounded,
                              color: Colors.greenAccent, size: 13),
                          SizedBox(width: 4),
                          Text('Pick on Map',
                              style: TextStyle(
                                  color: Colors.greenAccent, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Lat / Lon fields
              Row(
                children: [
                  Expanded(
                      child: _field(widget.latCtrl, 'Latitude',
                          numeric: true,
                          icon: Icons.south_america_rounded)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _field(widget.lonCtrl, 'Longitude',
                          numeric: true, icon: Icons.explore_rounded)),
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
                                      ? 'Create Store'
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

  Widget _field(TextEditingController ctrl, String label,
      {bool numeric = false, IconData? icon, String? hint, bool uppercase = false}) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true, signed: true)
          : TextInputType.text,
      textCapitalization: uppercase ? TextCapitalization.characters : TextCapitalization.none,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF6B5B8E), fontSize: 12),
        labelStyle: const TextStyle(color: Color(0xFFCDB4DB), fontSize: 12),
        prefixIcon: icon != null
            ? Icon(icon, color: const Color(0xFFCDB4DB), size: 16)
            : null,
        filled: true,
        fillColor: const Color(0x1AFFFFFF),
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
            borderSide: const BorderSide(color: Color(0xFF7B2FBE))),
      ),
    );
  }
}
