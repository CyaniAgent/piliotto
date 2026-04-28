import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:piliotto/ottohub/api/models/danmaku.dart';
import 'package:piliotto/pages/danmaku/index.dart';
import 'package:piliotto/plugin/pl_player/index.dart';
import 'package:piliotto/utils/storage.dart';

class PlDanmaku extends StatefulWidget {
  final int? vid;
  final int? cid;
  final PlPlayerController playerController;
  final String type;
  final Function(DanmakuController)? createdController;

  const PlDanmaku({
    super.key,
    this.vid,
    this.cid,
    required this.playerController,
    this.type = 'video',
    this.createdController,
  });

  @override
  State<PlDanmaku> createState() => _PlDanmakuState();
}

class _PlDanmakuState extends State<PlDanmaku> {
  late PlPlayerController playerController;
  late PlDanmakuController _plDanmakuController;
  DanmakuController? _controller;
  Box setting = GStrorage.setting;
  late bool enableShowDanmaku;
  late List blockTypes;
  late double showArea;
  late double opacityVal;
  late double fontSizeVal;
  late double danmakuDurationVal;
  late double strokeWidth;
  int latestAddedPosition = -1;

  int get _videoId => widget.vid ?? widget.cid ?? 0;

  @override
  void initState() {
    super.initState();
    enableShowDanmaku =
        setting.get(SettingBoxKey.enableShowDanmaku, defaultValue: false);
    _plDanmakuController = PlDanmakuController(_videoId);
    playerController = widget.playerController;
    if (mounted && widget.type == 'video') {
      if (enableShowDanmaku || playerController.isOpenDanmu.value) {
        _plDanmakuController.initiate(
            playerController.duration.value.inMilliseconds,
            playerController.position.value.inMilliseconds);
      }
      playerController
        ..addStatusLister(playerListener)
        ..addPositionListener(videoPositionListen);
    }
    if (widget.type == 'video') {
      playerController.isOpenDanmu.listen((p0) {
        if (p0 && !_plDanmakuController.initiated) {
          _plDanmakuController.initiate(
              playerController.duration.value.inMilliseconds,
              playerController.position.value.inMilliseconds);
        }
      });
    }
    blockTypes = playerController.blockTypes;
    showArea = playerController.showArea;
    opacityVal = playerController.opacityVal;
    fontSizeVal = playerController.fontSizeVal;
    strokeWidth = playerController.strokeWidth;
    danmakuDurationVal = playerController.danmakuDurationVal;
  }

  void playerListener(PlayerStatus? status) {
    if (_controller == null) return;
    if (status == PlayerStatus.paused) {
      _controller!.pause();
    }
    if (status == PlayerStatus.playing) {
      _controller!.resume();
    }
  }

  void videoPositionListen(Duration position) {
    if (!playerController.isOpenDanmu.value || _controller == null) {
      return;
    }
    int currentPosition = position.inMilliseconds;
    currentPosition -= currentPosition % 100;

    if (currentPosition == latestAddedPosition) {
      return;
    }
    latestAddedPosition = currentPosition;

    List<Danmaku>? currentDanmakuList =
        _plDanmakuController.getCurrentDanmaku(currentPosition);

    if (currentDanmakuList != null && currentDanmakuList.isNotEmpty) {
      for (var e in currentDanmakuList) {
        if (_shouldBlockDanmaku(e)) {
          continue;
        }

        DanmakuItemType danmakuType = _parseDanmakuType(e.mode);
        Color danmakuColor = _parseColor(e.color);

        _controller!.addDanmaku(DanmakuContentItem(
          e.text,
          color: danmakuColor,
          type: danmakuType,
        ));
      }
    }
  }

  bool _shouldBlockDanmaku(Danmaku danmaku) {
    if (playerController.blockTypes.contains(6) && danmaku.color != '#ffffff') {
      return true;
    }
    return false;
  }

  DanmakuItemType _parseDanmakuType(String mode) {
    switch (mode.toLowerCase()) {
      case 'top':
        return DanmakuItemType.top;
      case 'bottom':
        return DanmakuItemType.bottom;
      default:
        return DanmakuItemType.scroll;
    }
  }

  Color _parseColor(String colorStr) {
    if (colorStr.isEmpty) {
      return Colors.white;
    }
    try {
      String hex = colorStr.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
      return Colors.white;
    } catch (e) {
      return Colors.white;
    }
  }

  @override
  void dispose() {
    playerController.removePositionListener(videoPositionListen);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      return Obx(
        () => AnimatedOpacity(
          opacity: playerController.isOpenDanmu.value ? 1 : 0,
          duration: const Duration(milliseconds: 100),
          child: DanmakuScreen(
            createdController: (DanmakuController e) async {
              playerController.danmakuController = _controller = e;
              widget.createdController?.call(e);
              if (!_plDanmakuController.initiated) {
                _plDanmakuController.initiate(
                    playerController.duration.value.inMilliseconds,
                    playerController.position.value.inMilliseconds);
              }
            },
            option: DanmakuOption(
              fontSize: 15 * playerController.fontSizeVal,
              area: playerController.showArea,
              opacity: playerController.opacityVal,
              hideTop: playerController.blockTypes.contains(5),
              hideScroll: playerController.blockTypes.contains(2),
              hideBottom: playerController.blockTypes.contains(4),
              duration: playerController.danmakuDurationVal /
                  playerController.playbackSpeed,
              strokeWidth: playerController.strokeWidth,
            ),
          ),
        ),
      );
    });
  }
}
