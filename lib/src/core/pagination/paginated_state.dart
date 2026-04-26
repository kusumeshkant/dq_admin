enum PaginatedState {
  idle,        // before first load
  loading,     // initial full-screen spinner
  loadingMore, // footer spinner while appending next page
  success,     // items visible
  empty,       // loaded OK but zero results
  error,       // initial load failed — no items to show
}
