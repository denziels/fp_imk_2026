import 'package:get/get.dart';

enum RecordingState { idle, recording, recorded }

class StoryController extends GetxController {
  var currentState = RecordingState.idle.obs;

  void toggleRecording() async {
    if (currentState.value == RecordingState.idle) {
      currentState.value = RecordingState.recording;
      // Simulasi proses merekam 3 detik
      await Future.delayed(const Duration(seconds: 3));
      currentState.value = RecordingState.recorded;
    }
  }

  void reset() {
    currentState.value = RecordingState.idle;
  }
}
