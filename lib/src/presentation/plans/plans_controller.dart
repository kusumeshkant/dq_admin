import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_config.dart';
import '../../core/config/razorpay_config.dart';
import '../../service_core/auth/session_manager.dart';
import '../../service_core/subscription/subscription_manager.dart';
import '../../service_core/subscription/subscription_remote_ds.dart';

class PlansController extends GetxController {
  final SubscriptionRemoteDs _remoteDs;
  PlansController({required SubscriptionRemoteDs remoteDs}) : _remoteDs = remoteDs;

  final SessionManager _session = Get.find<SessionManager>();
  final SubscriptionManager _subManager = Get.find<SubscriptionManager>();

  final plans = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final isUpgrading = false.obs;
  final errorMessage = ''.obs;
  final billingCycle = 'monthly'.obs; // 'monthly' | 'annual'

  late final Razorpay _razorpay;
  final pendingPlanName = RxnString();

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
    fetchPlans();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  Future<void> fetchPlans() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _remoteDs.fetchAvailablePlans();
      plans.assignAll(result);
    } catch (e) {
      errorMessage.value = 'Failed to load plans. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  String get currentPlanName => _subManager.info.planName;

  bool isCurrentPlan(String planName) => currentPlanName == planName;

  /// Returns true if the given plan is an upgrade from the current plan.
  bool isUpgrade(String planName) {
    const order = ['free', 'trial', 'starter', 'growth', 'enterprise'];
    final currentIdx = order.indexOf(currentPlanName);
    final targetIdx  = order.indexOf(planName);
    return targetIdx > currentIdx;
  }

  bool isCustomPricing(String planName) {
    try {
      return plans.firstWhere((p) => p['name'] == planName)['isCustomPricing'] as bool? ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> selectPlan(String planName) async {
    // Enterprise / custom-pricing plans go to contact instead of Razorpay
    if (isCustomPricing(planName)) {
      final uri = Uri.parse('mailto:${AppConfig.enterpriseContactEmail}?subject=Enterprise%20Plan%20Enquiry');
      if (await canLaunchUrl(uri)) await launchUrl(uri);
      return;
    }

    final storeId = _session.storeId;
    if (storeId == null) {
      Get.snackbar('Error', 'No store found. Please re-login.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isUpgrading.value = true;
      pendingPlanName.value = planName;

      final order = await _remoteDs.createSubscriptionOrder(
        storeId,
        planName,
        billingCycle.value,
      );

      final options = {
        'key': RazorpayConfig.keyId,
        'order_id': order['id'] as String,
        'amount': order['amount'],
        'currency': order['currency'] ?? 'INR',
        'name': RazorpayConfig.businessName,
        'description': '${_planDisplayName(planName)} — ${billingCycle.value == 'annual' ? 'Annual' : 'Monthly'}',
        'prefill': {
          'contact': _session.currentUser.value?.phone ?? '',
          'email': _session.currentUser.value?.email ?? '',
        },
        'theme': {'color': '#7C5AFD'},
      };

      _razorpay.open(options);
    } catch (e) {
      isUpgrading.value = false;
      pendingPlanName.value = null;
      Get.snackbar(
        'Payment Failed',
        'Could not initiate payment. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final storeId = _session.storeId!;
      await _remoteDs.confirmSubscriptionPayment(
        storeId: storeId,
        planName: pendingPlanName.value ?? '',
        billingCycle: billingCycle.value,
        razorpayOrderId: response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
      );

      // Refresh global subscription state
      await _subManager.load(storeId);

      Get.back(); // close PlansPage
      Get.snackbar(
        'Plan Activated!',
        'You are now on the ${_planDisplayName(pendingPlanName.value ?? '')} plan.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Activation Error',
        'Payment received but plan activation failed. Contact ${AppConfig.supportEmail}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 6),
      );
    } finally {
      isUpgrading.value = false;
      pendingPlanName.value = null;
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    isUpgrading.value = false;
    pendingPlanName.value = null;
    if (response.code != 0) {
      // code 0 = user dismissed, not an error
      Get.snackbar(
        'Payment Failed',
        response.message ?? 'Payment was not completed.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    // External wallet selected — payment continues asynchronously
    // We do nothing here; the backend webhook will confirm eventually
    isUpgrading.value = false;
    pendingPlanName.value = null;
  }

  String _planDisplayName(String planName) {
    try {
      return plans.firstWhere((p) => p['name'] == planName)['displayName'] as String;
    } catch (_) {
      return planName;
    }
  }
}
