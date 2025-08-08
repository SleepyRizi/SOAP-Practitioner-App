import 'package:get/get.dart';
import '../Services/auth_service.dart';
import '../Services/firestore_service.dart';


class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthService(), permanent: true);
    Get.put(FirestoreService(), permanent: true);
  }
}
