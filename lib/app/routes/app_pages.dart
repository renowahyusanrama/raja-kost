import 'package:get/get.dart';

import '../bindings/detail_binding.dart';
import '../bindings/payment_binding.dart';
import '../bindings/booking_history_binding.dart';
import '../bindings/home_binding.dart';
import '../../controllers/settings_controller.dart';

import '../../ui/pages/Home/home_view.dart';
import '../../ui/pages/Home/wishlist_view.dart';
import '../../ui/pages/detail/detail_view.dart';
import '../../ui/pages/payment/payment_view.dart';
import '../../ui/pages/Home/login_view.dart';
import '../../ui/pages/Home/register_view.dart';
import '../../ui/pages/history/booking_history_view.dart';
import '../../ui/pages/help/help_about_view.dart';
import '../../ui/pages/settings/settings_view.dart';
import '../../ui/pages/admin/admin_view.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/report_controller.dart';
import '../../controllers/admin_report_controller.dart';
import '../../ui/pages/reports/report_view.dart';
import '../../ui/pages/admin/admin_report_view.dart';
import '../../controllers/location_experiment_controller.dart';
import '../../ui/pages/location/location_experiment_view.dart';
import '../../ui/pages/chat/chat_page.dart';
import '../../ui/pages/chat/admin_chat_list_page.dart';

class AppPages {
  AppPages._();

  // Wajib: pakai 'initial' huruf kecil
  // ignore: constant_identifier_names
  static const String INITIAL = _Paths.home; // UPPER
  static const String initial = _Paths.home; // lower

  static final routes = <GetPage>[
    GetPage(
      name: _Paths.login,
      page: () => const LoginView(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: _Paths.register,
      page: () => const RegisterView(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: _Paths.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: _Paths.detail,
      page: () => const DetailView(),
      binding: DetailBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: _Paths.payment,
      page: () => const PaymentView(),
      binding: PaymentBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: _Paths.history,
      page: () => const BookingHistoryView(),
      binding: BookingHistoryBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: _Paths.wishlist,
      page: () => const WishlistView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: _Paths.settings,
      page: () => const SettingsView(),
      binding: BindingsBuilder(
        () {
          Get.put(SettingsController());
        },
      ),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: _Paths.help,
      page: () => const HelpAboutView(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: _Paths.admin,
      page: () => const AdminView(),
      binding: BindingsBuilder(() {
        Get.put(AdminController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: _Paths.report,
      page: () => const ReportView(),
      binding: BindingsBuilder(() {
        Get.put(ReportController());
      }),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: _Paths.adminReports,
      page: () => const AdminReportView(),
      binding: BindingsBuilder(() {
        Get.put(AdminReportController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: _Paths.locationLab,
      page: () => const LocationExperimentView(),
      binding: BindingsBuilder(() {
        Get.put(LocationExperimentController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: _Paths.chat,
      page: () => const ChatPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: _Paths.adminChats,
      page: () => const AdminChatListPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}

abstract class _Paths {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String payment = '/payment';
  static const String history = '/history';
  static const String wishlist = '/wishlist';
  static const String settings = '/settings';
  static const String help = '/help';
  static const String admin = '/admin';
  static const String report = '/report';
  static const String adminReports = '/admin/reports';
  static const String locationLab = '/location-lab';
  static const String chat = '/chat';
  static const String adminChats = '/admin/chats';
}
