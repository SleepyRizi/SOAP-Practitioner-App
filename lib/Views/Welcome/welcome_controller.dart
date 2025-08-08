import 'package:get/get.dart';
import '../../routes/app_pages.dart';

class WelcomeController extends GetxController {
  void toSignup() => Get.toNamed(Routes.signup);
  void toLogin()  => Get.toNamed(Routes.login);
}
