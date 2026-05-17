import 'dart:developer' as dev;

/// Centralized colored logger for dq_admin.
///
/// Color scheme (ANSI — visible in Android Studio / VS Code debug console):
///   Cyan    — API Request
///   Green   — API Response / Success
///   Red     — Error (GraphQL / Network / Runtime)
///   Yellow  — Warning
///   Blue    — Info
///   Magenta — Auth / Token events
class AppLogger {
  static const _reset   = '\x1B[0m';
  static const _cyan    = '\x1B[36m';
  static const _green   = '\x1B[32m';
  static const _red     = '\x1B[31m';
  static const _yellow  = '\x1B[33m';
  static const _blue    = '\x1B[34m';
  static const _magenta = '\x1B[35m';

  // ── API Request — Cyan ────────────────────────────────────────────────────

  static void request(String operation, {Map<String, dynamic>? variables}) {
    final vars = (variables != null && variables.isNotEmpty)
        ? '\n  vars      : $variables'
        : '';
    dev.log(
      '$_cyan┌─ REQUEST  [$operation]$vars$_reset',
      name: 'API:REQ',
      level: 500,
    );
  }

  // ── API Response — Green ──────────────────────────────────────────────────

  static void response(String operation, dynamic data) {
    dev.log(
      '$_green└─ RESPONSE [$operation]\n  data      : $data$_reset',
      name: 'API:RES',
      level: 500,
    );
  }

  // ── GraphQL Error — Red ───────────────────────────────────────────────────

  static void graphqlError(String operation, List<dynamic> errors) {
    final msgs = errors.map((e) => e.message).join('\n             ');
    dev.log(
      '$_red└─ GQL ERROR [$operation]\n  messages  : $msgs$_reset',
      name: 'API:ERR',
      level: 1000,
    );
  }

  // ── Network / Link Error — Red ────────────────────────────────────────────

  static void networkError(String operation, dynamic exception) {
    dev.log(
      '$_red└─ NET ERROR [$operation]\n  exception : $exception$_reset',
      name: 'API:NET',
      level: 1000,
    );
  }

  // ── Runtime / Parse Error — Red ───────────────────────────────────────────

  static void error(String tag, dynamic err, [StackTrace? stackTrace]) {
    dev.log(
      '$_red└─ ERROR     [$tag]\n  error     : $err$_reset',
      name: 'APP:ERR',
      level: 1000,
      error: err,
      stackTrace: stackTrace,
    );
  }

  // ── Warning — Yellow ──────────────────────────────────────────────────────

  static void warning(String tag, String message) {
    dev.log(
      '$_yellow   WARNING  [$tag] $message$_reset',
      name: 'APP:WARN',
      level: 900,
    );
  }

  // ── Info — Blue ───────────────────────────────────────────────────────────

  static void info(String tag, String message) {
    dev.log(
      '$_blue   INFO     [$tag] $message$_reset',
      name: 'APP:INFO',
      level: 500,
    );
  }

  // ── Auth / Token — Magenta ────────────────────────────────────────────────

  static void auth(String message) {
    dev.log(
      '$_magenta   AUTH     $message$_reset',
      name: 'APP:AUTH',
      level: 500,
    );
  }
}
