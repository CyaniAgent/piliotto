import 'package:audio_service/audio_service.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/utils/storage.dart';

Future<VideoPlayerServiceHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => VideoPlayerServiceHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.cyaniagent.piliotto.audio',
      androidNotificationChannelName: 'Audio Service PiliOtto',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      fastForwardInterval: Duration(seconds: 10),
      rewindInterval: Duration(seconds: 10),
      androidNotificationChannelDescription: 'Media notification channel',
      androidNotificationIcon: 'drawable/ic_notification_icon',
    ),
  );
}

class VideoPlayerServiceHandler extends BaseAudioHandler with SeekHandler {
  static final List<MediaItem> _item = [];
  Box setting = GStrorage.setting;
  bool enableBackgroundPlay = false;

  VideoPlayerServiceHandler() {
    revalidateSetting();
  }

  void revalidateSetting() {
    enableBackgroundPlay =
        setting.get(SettingBoxKey.enableBackgroundPlay, defaultValue: false);
  }

  Future<void> setMediaItem(MediaItem newMediaItem) async {
    if (!enableBackgroundPlay) return;
    mediaItem.add(newMediaItem);
  }

  void clear() {
    if (!enableBackgroundPlay) return;

    mediaItem.add(null);
    playbackState.add(PlaybackState(
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
    _item.clear();
  }

  void onPositionChange(Duration position) {
    if (!enableBackgroundPlay) return;

    playbackState.add(playbackState.value.copyWith(
      updatePosition: position,
    ));
  }
}
