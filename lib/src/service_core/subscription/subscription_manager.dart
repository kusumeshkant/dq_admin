import 'package:get/get.dart';
import 'subscription_model.dart';
import 'subscription_remote_ds.dart';

/// Master switch — set to true to begin enforcing subscription plan limits.
/// When false, canUse() always returns true regardless of the store's plan.
/// Flip this (and SUBSCRIPTION_ENABLED on the backend) together when ready.
const bool _subscriptionEnabled = false;

/// SubscriptionManager — single source of truth for the current store's plan.
///
/// Lifecycle:
///   1. Registered as a lazy singleton in main.dart initialServices().
///   2. load(storeId) called once in the cold-start routing flow, after
///      SessionManager confirms the admin is logged in and has a storeId.
///   3. All screens read canUse() / info — no direct GraphQL calls needed.
///   4. refresh() can be called from the Subscription settings screen.
///
/// Passive only — no UI, no navigation. Other controllers read this.
class SubscriptionManager extends GetxService {
  final _ds = SubscriptionRemoteDs();

  final Rx<SubscriptionInfo> _info = Rx<SubscriptionInfo>(
    const SubscriptionInfo.loading(),
  );

  final RxBool isLoading  = false.obs;
  final RxBool hasError   = false.obs;
  String? _lastError;

  /// The current subscription info. Reactive — bind with Obx if needed.
  SubscriptionInfo get info => _info.value;

  /// Whether the manager has loaded at least once (not still in initial state).
  bool get isLoaded => _info.value.status != 'loading';

  String? get lastError => _lastError;

  /// Loads subscription data for [storeId].
  /// Safe to call multiple times — always fetches fresh from network.
  Future<void> load(String storeId) async {
    isLoading.value = true;
    hasError.value  = false;
    _lastError      = null;

    try {
      final result    = await _ds.loadSubscription(storeId);
      _info.value     = result;
    } catch (e) {
      hasError.value = true;
      _lastError     = e.toString();
      // Keep existing info if available, otherwise leave as locked
      if (!isLoaded) {
        _info.value = const SubscriptionInfo(
          status: 'error',
          planName: '',
          planDisplayName: '',
          features: FeatureAccessMap.locked(),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Returns true if the current plan includes [featureKey].
  /// When _subscriptionEnabled is false, always returns true (open access).
  bool canUse(String featureKey) {
    if (!_subscriptionEnabled) return true;
    return _info.value.features[featureKey];
  }

  /// Whether subscription enforcement is currently active.
  bool get isSubscriptionEnabled => _subscriptionEnabled;

  /// Clears the cached subscription — call on logout.
  void clear() {
    _info.value     = const SubscriptionInfo.loading();
    hasError.value  = false;
    _lastError      = null;
  }

  /// Refreshes from network — call after a plan change or from settings screen.
  Future<void> refresh(String storeId) => load(storeId);
}
