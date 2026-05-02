import 'package:graphql_flutter/graphql_flutter.dart';
import '../networks/graphql_client_provider.dart';
import 'subscription_model.dart';

/// Fetches subscription data from the backend.
/// Called once at cold-start by SubscriptionManager — not called on every screen.
class SubscriptionRemoteDs {
  GraphQLClient get _client => GraphQLClientProvider.client;

  static const _featureAccessMapQuery = r'''
    query FeatureAccessMap($storeId: ID!) {
      featureAccessMap(storeId: $storeId) {
        coupons
        analytics
        bulkUpload
        advancedReports
        staffPerformanceAnalytics
        customerLtvAnalytics
        prioritySupport
        customBranding
        exportData
      }
    }
  ''';

  static const _storeSubscriptionQuery = r'''
    query StoreSubscription($storeId: ID!) {
      storeSubscription(storeId: $storeId) {
        status
        trialEndsAt
        gracePeriodEndsAt
        currentPeriodEnd
        plan {
          name
          displayName
          limits {
            maxStaff
            maxOrdersPerMonth
            maxStores
          }
        }
        usageCounters {
          staffCount
          ordersThisMonth
          storeCount
        }
      }
    }
  ''';

  /// Loads feature access map + subscription status for a store in one parallel fetch.
  Future<SubscriptionInfo> loadSubscription(String storeId) async {
    final results = await Future.wait([
      _client.query(QueryOptions(
        document: gql(_featureAccessMapQuery),
        variables: {'storeId': storeId},
        fetchPolicy: FetchPolicy.networkOnly,
      )),
      _client.query(QueryOptions(
        document: gql(_storeSubscriptionQuery),
        variables: {'storeId': storeId},
        fetchPolicy: FetchPolicy.networkOnly,
      )),
    ]);

    final mapResult = results[0];
    final subResult = results[1];

    if (mapResult.hasException || subResult.hasException) {
      final err = mapResult.exception ?? subResult.exception;
      throw Exception('Failed to load subscription: $err');
    }

    final featureJson = mapResult.data?['featureAccessMap'] as Map<String, dynamic>? ?? {};
    final subJson     = subResult.data?['storeSubscription'] as Map<String, dynamic>?;

    final features = FeatureAccessMap.fromJson(featureJson);

    if (subJson == null) {
      // Store has no subscription record yet — treat as no access
      return SubscriptionInfo(
        status: 'none',
        planName: '',
        planDisplayName: '',
        features: features,
      );
    }

    final usageJson  = subJson['usageCounters'] as Map<String, dynamic>? ?? {};
    final limitsJson = subJson['plan']?['limits']  as Map<String, dynamic>? ?? {};

    return SubscriptionInfo(
      status:            subJson['status'] as String? ?? 'none',
      planName:          subJson['plan']?['name'] as String? ?? '',
      planDisplayName:   subJson['plan']?['displayName'] as String? ?? '',
      features:          features,
      usage:             UsageCounters.fromJson(usageJson),
      limits:            PlanLimitValues.fromJson(limitsJson),
      trialEndsAt:       _parseDate(subJson['trialEndsAt']),
      gracePeriodEndsAt: _parseDate(subJson['gracePeriodEndsAt']),
      currentPeriodEnd:  _parseDate(subJson['currentPeriodEnd']),
    );
  }

  static const _availablePlansQuery = r'''
    query AvailablePlans {
      availablePlans {
        id
        name
        displayName
        description
        price { monthly annual }
        features {
          coupons analytics bulkUpload advancedReports
          staffPerformanceAnalytics customerLtvAnalytics
          prioritySupport customBranding exportData
        }
        limits { maxStaff maxOrdersPerMonth maxStores }
        isRecommended
        isCustomPricing
        displayOrder
      }
    }
  ''';

  static const _createSubscriptionOrderMutation = r'''
    mutation CreateSubscriptionOrder($storeId: ID!, $planName: String!, $billingCycle: String!) {
      createSubscriptionOrder(storeId: $storeId, planName: $planName, billingCycle: $billingCycle) {
        id
        amount
        currency
      }
    }
  ''';

  static const _confirmSubscriptionPaymentMutation = r'''
    mutation ConfirmSubscriptionPayment(
      $storeId: ID!
      $planName: String!
      $billingCycle: String!
      $razorpayOrderId: String!
      $razorpayPaymentId: String!
      $razorpaySignature: String!
    ) {
      confirmSubscriptionPayment(
        storeId: $storeId
        planName: $planName
        billingCycle: $billingCycle
        razorpayOrderId: $razorpayOrderId
        razorpayPaymentId: $razorpayPaymentId
        razorpaySignature: $razorpaySignature
      ) {
        status
        trialEndsAt
        gracePeriodEndsAt
        currentPeriodEnd
        plan {
          name
          displayName
          limits { maxStaff maxOrdersPerMonth maxStores }
        }
        usageCounters { staffCount ordersThisMonth storeCount }
      }
    }
  ''';

  Future<List<Map<String, dynamic>>> fetchAvailablePlans() async {
    final result = await _client.query(QueryOptions(
      document: gql(_availablePlansQuery),
      fetchPolicy: FetchPolicy.networkOnly,
    ));
    if (result.hasException) throw Exception('Failed to load plans: ${result.exception}');
    final data = result.data?['availablePlans'] as List<dynamic>? ?? [];
    return data.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createSubscriptionOrder(
    String storeId,
    String planName,
    String billingCycle,
  ) async {
    final result = await _client.mutate(MutationOptions(
      document: gql(_createSubscriptionOrderMutation),
      variables: {'storeId': storeId, 'planName': planName, 'billingCycle': billingCycle},
    ));
    if (result.hasException) throw Exception('Order creation failed: ${result.exception}');
    return result.data?['createSubscriptionOrder'] as Map<String, dynamic>;
  }

  Future<SubscriptionInfo> confirmSubscriptionPayment({
    required String storeId,
    required String planName,
    required String billingCycle,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final result = await _client.mutate(MutationOptions(
      document: gql(_confirmSubscriptionPaymentMutation),
      variables: {
        'storeId': storeId,
        'planName': planName,
        'billingCycle': billingCycle,
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      },
    ));
    if (result.hasException) throw Exception('Payment confirmation failed: ${result.exception}');
    final subJson = result.data?['confirmSubscriptionPayment'] as Map<String, dynamic>;
    final usageJson  = subJson['usageCounters'] as Map<String, dynamic>? ?? {};
    final limitsJson = subJson['plan']?['limits']  as Map<String, dynamic>? ?? {};
    return SubscriptionInfo(
      status:          subJson['status'] as String? ?? 'active',
      planName:        subJson['plan']?['name'] as String? ?? '',
      planDisplayName: subJson['plan']?['displayName'] as String? ?? '',
      features:        FeatureAccessMap.fromJson({}),
      usage:           UsageCounters.fromJson(usageJson),
      limits:          PlanLimitValues.fromJson(limitsJson),
      currentPeriodEnd: _parseDate(subJson['currentPeriodEnd']),
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
