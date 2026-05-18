import 'package:get/get.dart';
import '../presentation/analytics/analytics_binding.dart';
import '../presentation/analytics/analytics_page.dart';
import '../presentation/auth/login/login_binding.dart';
import '../presentation/auth/login/login_page.dart';
import '../presentation/auth/signup/signup_binding.dart';
import '../presentation/auth/signup/signup_page.dart';
import '../presentation/dashboard/dashboard_binding.dart';
import '../presentation/dashboard/dashboard_page.dart';
import '../presentation/onboarding/onboarding_binding.dart';
import '../presentation/onboarding/onboarding_page.dart';
import '../presentation/orders/orders_binding.dart';
import '../presentation/orders/orders_page.dart';
import '../presentation/permissions/permissions_binding.dart';
import '../presentation/permissions/permissions_page.dart';
import '../presentation/plans/plans_binding.dart';
import '../presentation/plans/plans_page.dart';
import '../presentation/profile_setup/profile_setup_binding.dart';
import '../presentation/profile_setup/profile_setup_page.dart';
import '../presentation/staff/staff_binding.dart';
import '../presentation/staff/staff_page.dart';
import '../presentation/staff_management/staff_management_binding.dart';
import '../presentation/staff_management/staff_management_page.dart';
import '../presentation/stores/stores_binding.dart';
import '../presentation/stores/stores_page.dart';
import '../presentation/subscription/subscription_binding.dart';
import '../presentation/subscription/subscription_page.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupPage(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: AppRoutes.profileSetup,
      page: () => const ProfileSetupPage(),
      binding: ProfileSetupBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingPage(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.stores,
      page: () => const StoresPage(),
      binding: StoresBinding(),
    ),
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrdersPage(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: AppRoutes.analytics,
      page: () => const AnalyticsPage(),
      binding: AnalyticsBinding(),
    ),
    GetPage(
      name: AppRoutes.staff,
      page: () => const StaffPage(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AppRoutes.staffManagement,
      page: () => const StaffManagementPage(),
      binding: StaffManagementBinding(),
    ),
    GetPage(
      name: AppRoutes.permissions,
      page: () => const PermissionsPage(),
      binding: PermissionsBinding(),
    ),
    GetPage(
      name: AppRoutes.subscription,
      page: () => const SubscriptionPage(),
      binding: SubscriptionBinding(),
    ),
    GetPage(
      name: AppRoutes.plans,
      page: () => const PlansPage(),
      binding: PlansBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
