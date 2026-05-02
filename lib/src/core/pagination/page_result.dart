/// Generic page envelope returned by every paginated data source.
///
/// [nextCursor] is opaque — callers must not parse it. Pass it back as-is
/// in the next [fetchPage] call. Null means no more pages.
class PageResult<T> {
  final List<T> items;
  final bool hasNext;
  final String? nextCursor;
  final int? totalCount;

  const PageResult({
    required this.items,
    required this.hasNext,
    this.nextCursor,
    this.totalCount,
  });

  factory PageResult.empty() =>
      const PageResult(items: [], hasNext: false);
}

/// Parameters passed from [PaginatedController] to [fetchPage].
class PageParams {
  final int limit;
  final String? cursor;
  final String? search;
  final String? sortBy;
  final String sortDir;
  final Map<String, dynamic> filters;

  const PageParams({
    this.limit = 30,
    this.cursor,
    this.search,
    this.sortBy,
    this.sortDir = 'asc',
    this.filters = const {},
  });
}
