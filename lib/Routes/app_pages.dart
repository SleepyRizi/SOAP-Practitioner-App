import 'package:get/get.dart';

/* ── Auth ───────────────────────────────────────────── */
import '../Views/Auth/ForgotPassword/forgot_password_controller.dart';
import '../Views/Auth/ForgotPassword/forgot_password_view.dart';
import '../Views/Auth/Login/login_controller.dart';
import '../Views/Auth/Login/login_view.dart';
import '../Views/Auth/Otp/otp_controller.dart';
import '../Views/Auth/Otp/otp_view.dart';
import '../Views/Auth/Password/password_controller.dart';
import '../Views/Auth/Password/password_view.dart';
import '../Views/Auth/ResetSuccess/reset_success_view.dart';
import '../Views/Auth/Signup/signup_controller.dart';
import '../Views/Auth/Signup/signup_view.dart';
import '../Views/Auth/Success/success_view.dart';

/* ── Core / misc ────────────────────────────────────── */
import '../Views/Settings/settings_view.dart';
import '../Views/Splash/splash_controller.dart';
import '../Views/Splash/splash_view.dart';
import '../Views/Users/users_view.dart';
import '../Views/Welcome/welcome_controller.dart';
import '../Views/Welcome/welcome_view.dart';
import '../Views/Home/home_view.dart';

/* ── Patient-related ────────────────────────────────── */
import '../Views/Assessment/assessment_view.dart';          // ← “Start” destination
import '../Views/PatientDetail/form_detail_view.dart';       // pending-forms destination
// (If you still need the old PatientDetailView give it a **different** route)

part 'app_routes.dart';

class AppPages {
  static final routes = [

    /* Splash */
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: BindingsBuilder.put(() => SplashController()),
    ),

    /* Welcome */
    GetPage(
      name: Routes.welcome,
      page: () => const WelcomeView(),
      binding: BindingsBuilder.put(() => WelcomeController()),
    ),

    /* Login / Sign-up */
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder.put(() => LoginController()),
    ),
    GetPage(
      name: Routes.signup,
      page: () => SignupView(),
      binding: BindingsBuilder.put(() => SignupController()),
    ),

    /* Password / OTP */
    GetPage(
      name: Routes.otp,
      page: () => OtpView(),
      binding: BindingsBuilder.put(() => OtpController()),
    ),
    GetPage(
      name: Routes.pickPassword,
      page: () => const PasswordView(),
      binding: BindingsBuilder.put(() => PasswordController()),
    ),
    GetPage(
      name: Routes.forgot,
      page: () => const ForgotPasswordView(),
      binding: BindingsBuilder.put(() => ForgotPasswordController()),
    ),
    GetPage(
      name: Routes.resetSuccess,
      page: () => const ResetSuccessView(),
    ),
    GetPage(
      name: Routes.passwordUpdateSuccess,
      page: () => const PasswordUpdateSuccessView(),
    ),

    /* Home */
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
    ),

    GetPage(name: Routes.users, page: () => const UsersView()),

    GetPage(name: Routes.settings, page: () => const SettingsView()),
    /* Patient / Assessment flow */
    GetPage(
      name: Routes.patientDetail,             // <- used by the “Start” chip
      page: () => const AssessmentView(),
    ),
    GetPage(
      name: Routes.formDetail,                // <- used by the “Complete” chip
      page: () => const FormDetailView(),
    ),
  ];
}
