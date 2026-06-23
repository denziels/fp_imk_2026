import 'package:get/get.dart';

enum TracingState { idle, success, failed }

class TracingController extends GetxController {
  var currentState = TracingState.idle.obs;

  void completeTracing(bool isSuccess) {
    if (isSuccess) {
      currentState.value = TracingState.success;
    } else {
      currentState.value = TracingState.failed;
    }
  }

  void reset() {
    currentState.value = TracingState.idle;
  }
}
