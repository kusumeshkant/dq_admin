import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'feature_keys.dart';
import 'subscription_manager.dart';

/// Wraps a widget and hides it (or shows a locked placeholder) when the
/// current plan does not include [featureKey].
///
/// Usage:
/// ```dart
/// FeatureGuard(
///   featureKey: FeatureKeys.analytics,
///   child: AnalyticsCard(),
/// )
/// ```
///
/// By default shows nothing when locked. Pass [lockedChild] to show an
/// upgrade prompt instead.
class FeatureGuard extends StatelessWidget {
  const FeatureGuard({
    super.key,
    required this.featureKey,
    required this.child,
    this.lockedChild,
  });

  final String featureKey;
  final Widget child;

  /// Shown when the feature is locked. If null, renders SizedBox.shrink().
  final Widget? lockedChild;

  @override
  Widget build(BuildContext context) {
    final manager = Get.find<SubscriptionManager>();
    return Obx(() {
      if (manager.canUse(featureKey)) return child;
      return lockedChild ?? const SizedBox.shrink();
    });
  }
}

/// Inline version — takes a builder so the child is only built when unlocked.
///
/// Usage:
/// ```dart
/// FeatureBuilder(
///   featureKey: FeatureKeys.bulkUpload,
///   builder: (context) => BulkUploadButton(),
///   lockedBuilder: (context) => UpgradeChip(label: 'Bulk Upload'),
/// )
/// ```
class FeatureBuilder extends StatelessWidget {
  const FeatureBuilder({
    super.key,
    required this.featureKey,
    required this.builder,
    this.lockedBuilder,
  });

  final String featureKey;
  final WidgetBuilder builder;
  final WidgetBuilder? lockedBuilder;

  @override
  Widget build(BuildContext context) {
    final manager = Get.find<SubscriptionManager>();
    return Obx(() {
      if (manager.canUse(featureKey)) return builder(context);
      return lockedBuilder?.call(context) ?? const SizedBox.shrink();
    });
  }
}
