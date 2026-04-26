import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'page_result.dart';
import 'paginated_state.dart';

/// Abstract base controller for any paginated list screen.
///
/// Subclass and override [fetchPage]. All pagination machinery — debounce,
/// scroll detection, race-condition guard, pull-to-refresh, filter reset —
/// is handled here so subclasses stay lean.
///
/// Usage:
/// ```dart
/// class ProductsController extends PaginatedController<ProductEntity> {
///   @override
///   Future<PageResult<ProductEntity>> fetchPage(PageParams p) async {
///     return repo.getProductsPage(storeId, p);
///   }
/// }
/// ```
abstract class PaginatedController<T> extends GetxController {
  // ── Public state ────────────────────────────────────────────────────────────

  final items      = <T>[].obs;
  final state      = PaginatedState.idle.obs;
  final errorMsg   = ''.obs;
  final totalCount = Rxn<int>();

  // ── Filter / search / sort state ────────────────────────────────────────────

  final searchQuery = ''.obs;
  final sortBy      = Rxn<String>();
  final sortDir     = 'asc'.obs;
  final filters     = <String, dynamic>{}.obs;

  // ── Scroll controller (attach to ListView / GridView) ───────────────────────

  late final ScrollController scrollController;

  // ── Internals ────────────────────────────────────────────────────────────────

  static const int _pageSize = 30;
  static const double _loadMoreThreshold = 250;

  String? _nextCursor;
  bool _hasNext = false;
  bool _isFetching = false;
  int _epoch = 0; // invalidates in-flight requests on reset
  Timer? _searchDebounce;

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController()..addListener(_onScroll);
    loadInitial();
  }

  @override
  void onClose() {
    scrollController.dispose();
    _searchDebounce?.cancel();
    super.onClose();
  }

  // ── Abstract ─────────────────────────────────────────────────────────────────

  /// The only method subclasses must implement.
  Future<PageResult<T>> fetchPage(PageParams params);

  // ── Public API ───────────────────────────────────────────────────────────────

  /// Full reset + reload. Also called by pull-to-refresh.
  Future<void> loadInitial() async {
    if (_isFetching && state.value == PaginatedState.loading) return;
    _epoch++;
    final myEpoch = _epoch;
    _isFetching = true;
    _nextCursor = null;
    _hasNext = false;
    state.value = PaginatedState.loading;
    errorMsg.value = '';

    try {
      final result = await fetchPage(_buildParams(cursor: null));
      if (myEpoch != _epoch) return; // superseded by a newer call
      items.assignAll(result.items);
      _nextCursor = result.nextCursor;
      _hasNext = result.hasNext;
      totalCount.value = result.totalCount;
      state.value = result.items.isEmpty ? PaginatedState.empty : PaginatedState.success;
    } catch (e) {
      if (myEpoch != _epoch) return;
      errorMsg.value = _clean(e);
      state.value = PaginatedState.error;
    } finally {
      if (myEpoch == _epoch) _isFetching = false;
    }
  }

  /// Appends the next page. No-op if no more pages or already fetching.
  Future<void> loadMore() async {
    if (_isFetching || !_hasNext) return;
    _isFetching = true;
    state.value = PaginatedState.loadingMore;
    final myEpoch = _epoch;

    try {
      final result = await fetchPage(_buildParams(cursor: _nextCursor));
      if (myEpoch != _epoch) return;
      items.addAll(result.items);
      _nextCursor = result.nextCursor;
      _hasNext = result.hasNext;
      if (result.totalCount != null) totalCount.value = result.totalCount;
      state.value = PaginatedState.success;
    } catch (_) {
      if (myEpoch != _epoch) return;
      // Keep existing items — don't destroy what the user already sees.
      state.value = PaginatedState.success;
    } finally {
      if (myEpoch == _epoch) _isFetching = false;
    }
  }

  /// Alias used by RefreshIndicator and pull-to-refresh.
  @override
  Future<void> refresh() => loadInitial();

  /// Call from a search TextField's onChanged.
  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (searchQuery.value != value.trim()) {
        searchQuery.value = value.trim();
        loadInitial();
      }
    });
  }

  /// Apply or clear a single filter key. Pass null to clear.
  void applyFilter(String key, dynamic value) {
    if (value == null) {
      filters.remove(key);
    } else {
      filters[key] = value;
    }
    loadInitial();
  }

  /// Replace the entire filter map at once.
  void applyFilters(Map<String, dynamic> newFilters) {
    filters.assignAll(newFilters);
    loadInitial();
  }

  /// Clear all active filters and search.
  void clearFilters() {
    filters.clear();
    searchQuery.value = '';
    sortBy.value = null;
    sortDir.value = 'asc';
    loadInitial();
  }

  /// Change sort field / direction and reload from page 1.
  void applySort(String field, {String dir = 'asc'}) {
    sortBy.value = field;
    sortDir.value = dir;
    loadInitial();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  void _onScroll() {
    final pos = scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - _loadMoreThreshold) {
      loadMore();
    }
  }

  PageParams _buildParams({required String? cursor}) => PageParams(
        limit: _pageSize,
        cursor: cursor,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        sortBy: sortBy.value,
        sortDir: sortDir.value,
        filters: Map.unmodifiable(filters),
      );

  String _clean(Object e) =>
      e.toString().replaceAll('Exception: ', '').trim();
}
