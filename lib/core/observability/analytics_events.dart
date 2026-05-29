/// Centralized event name constants for Firebase Analytics — dq_admin.
///
/// All event names must be snake_case and ≤ 40 characters (Firebase limit).
/// All parameter names must be snake_case and ≤ 40 characters.
///
/// Never hardcode event names as strings elsewhere in the codebase.
/// Always import and use these constants.
abstract final class AnalyticsEvents {
  // ── Auth ────────────────────────────────────────────────────────────────────
  static const String loginSuccess   = 'login_success';
  static const String loginFailed    = 'login_failed';
  static const String logout         = 'logout';
  static const String sessionExpired = 'session_expired';

  // ── Store management ─────────────────────────────────────────────────────────
  static const String storeCreated = 'store_created';
  static const String storeUpdated = 'store_updated';
  static const String storeDeleted = 'store_deleted';

  // ── Products ─────────────────────────────────────────────────────────────────
  static const String productCreated     = 'product_created';
  static const String productUpdated     = 'product_updated';
  static const String productDeleted     = 'product_deleted';
  static const String bulkUploadStarted  = 'bulk_upload_started';
  static const String bulkUploadSuccess  = 'bulk_upload_success';
  static const String bulkUploadFailed   = 'bulk_upload_failed';

  // ── Staff management ──────────────────────────────────────────────────────────
  static const String staffInvited = 'staff_invited';
  static const String staffRemoved = 'staff_removed';

  // ── Subscription / Plans ──────────────────────────────────────────────────────
  static const String planViewed   = 'plan_viewed';
  static const String planSelected = 'plan_selected';
  static const String planUpgraded = 'plan_upgraded';

  // ── Navigation ───────────────────────────────────────────────────────────────
  static const String screenView = 'screen_view';

  // ── Errors ───────────────────────────────────────────────────────────────────
  static const String apiError     = 'api_error';
  static const String networkError = 'network_error';

  // ── Performance ──────────────────────────────────────────────────────────────
  static const String frameJankDetected = 'frame_jank_detected';
  static const String anrDetected       = 'anr_detected';
  static const String slowStartup       = 'slow_startup';
}

/// Centralized parameter name constants for Firebase Analytics — dq_admin.
abstract final class AnalyticsParams {
  static const String screenName    = 'screen_name';
  static const String userId        = 'user_id';
  static const String storeId       = 'store_id';
  static const String planName      = 'plan_name';
  static const String billingCycle  = 'billing_cycle';
  static const String productCount  = 'product_count';
  static const String errorCode     = 'error_code';
  static const String errorMessage  = 'error_message';
  static const String operationName = 'operation_name';
  static const String flavor        = 'flavor';
  static const String correlationId = 'cid';

  // ── Performance parameters ────────────────────────────────────────────────────
  static const String jankyFrameCount = 'janky_frames';
  static const String slowFrameCount  = 'slow_frames';
  static const String totalFrameCount = 'total_frames';
  static const String maxFrameMs      = 'max_frame_ms';
  static const String avgFrameMs      = 'avg_frame_ms';
  static const String startupMs              = 'startup_ms';
  static const String sessionId              = 'session_id';
  static const String severity               = 'severity';
  static const String consecutiveJankyFrames = 'consecutive_janky_frames';
}
