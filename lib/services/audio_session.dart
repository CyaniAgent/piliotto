import 'package:audio_session/audio_session.dart';

class AudioSessionHandler {
  late AudioSession session;

  void setActive(bool active) {
    session.setActive(active);
  }

  AudioSessionHandler() {
    initSession();
  }

  Future<void> initSession() async {
    session = await AudioSession.instance;
    session.configure(const AudioSessionConfiguration.music());
  }
}
