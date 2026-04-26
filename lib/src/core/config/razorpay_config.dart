/// Razorpay public key — replace with your live key before production.
/// Test key:  rzp_test_XXXXXXXXXX  (from Razorpay Dashboard → Settings → API Keys)
/// Live key:  rzp_live_XXXXXXXXXX
///
/// Only the key_id goes here (public). The key_secret stays on the backend only.
class RazorpayConfig {
  static const String keyId = 'rzp_test_XXXXXXXXXX'; // ← replace this
  static const String businessName = 'DQ';
}
