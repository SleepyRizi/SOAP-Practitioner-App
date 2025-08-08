import 'dart:async';
import 'package:get/get.dart';

class OtpTimerController extends GetxController {
  final int seconds;
  late Timer _timer;
  final RxInt timeLeft = 0.obs;

  OtpTimerController(this.seconds) {
    timeLeft.value = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (timeLeft > 0) {
        timeLeft.value--;
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void onClose() {
    _timer.cancel();
    super.onClose();
  }
}
