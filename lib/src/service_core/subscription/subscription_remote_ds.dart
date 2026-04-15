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

    return SubscriptionInfo(
      status:            subJson['status'] as String? ?? 'none',
      planName:          subJson['plan']?['name'] as String? ?? '',
      planDisplayName:   subJson['plan']?['displayName'] as String? ?? '',
      features:          features,
      trialEndsAt:       _parseDate(subJson['trialEndsAt']),
      gracePeriodEndsAt: _parseDate(subJson['gracePeriodEndsAt']),
      currentPeriodEnd:  _parseDate(subJson['currentPeriodEnd']),
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
