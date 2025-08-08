import 'package:get/get.dart';
import '../../Services/auth_service.dart';
import '../../routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    Future.delayed(const Duration(seconds: 2), () {
      final user = Get.find<AuthService>().currentUser;
      Get.offAllNamed(user == null ? Routes.welcome : Routes.home);
    });
  }
}
