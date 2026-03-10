// 定时关闭服务
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class ShutdownTimerService {
  static final ShutdownTimerService _instance =
      ShutdownTimerService._internal();
  Timer? _shutdownTimer;
  Timer? _autoCloseDialogTimer;
  //定时退出
  int scheduledExitInMinutes = -1;
  bool exitApp = false;
  bool waitForPlayingCompleted = false;
  bool isWaiting = false;

  factory ShutdownTimerService() => _instance;

  ShutdownTimerService._internal();

  void startShutdownTimer() {
    cancelShutdownTimer(); // Cancel any previous timer
    if (scheduledExitInMinutes == -1) {
      //使用toast提示用户已取消
      SmartDialog.showToast("取消定时关闭");
      return;
    }
    SmartDialog.showToast("设置 $scheduledExitInMinutes 分钟后定时关闭");
    _shutdownTimer = Timer(
        Duration(minutes: scheduledExitInMinutes), () => _shutdownDecider());
  }

  void _showTimeUpButPauseDialog() {
    SmartDialog.show(
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('定时关闭'),
          content: const Text('时间到啦！'),
          actions: <Widget>[
            TextButton(
              child: const Text('确认'),
              onPressed: () {
                cancelShutdownTimer();
                SmartDialog.dismiss();
              },
            ),
          ],
        );
      },
    );
  }

  void _showShutdownDialog() {
    SmartDialog.show(
      builder: (BuildContext dialogContext) {
        // Start the 10-second timer to auto close the dialog
        _autoCloseDialogTimer?.cancel();
        _autoCloseDialogTimer = Timer(const Duration(seconds: 10), () {
          SmartDialog.dismiss(); // Close the dialog
          _executeShutdown();
        });
        return AlertDialog(
          title: const Text('定时关闭'),
          content: const Text('将在10秒后执行，是否需要取消？'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消关闭'),
              onPressed: () {
                _autoCloseDialogTimer?.cancel(); // Cancel the auto-close timer
                cancelShutdownTimer(); // Cancel the shutdown timer
                SmartDialog.dismiss(); // Close the dialog
              },
            ),
          ],
        );
      },
    ).then((_) {
      // Cleanup when the dialog is dismissed
      _autoCloseDialogTimer?.cancel();
    });
  }

  void _shutdownDecider() {
    if (exitApp && !waitForPlayingCompleted) {
      _showShutdownDialog();
      return;
    }
    if (!exitApp && !waitForPlayingCompleted) {
      // 仅提示用户
      _showTimeUpButPauseDialog();
      return;
    }
    // waitForPlayingCompleted
    SmartDialog.showToast("定时关闭时间已到，等待当前视频播放完成");
    // 监听播放完成
    isWaiting = true;
  }

  void handleWaitingFinished() {
    if (isWaiting) {
      _showShutdownDialog();
      isWaiting = false;
    }
  }

  void _executeShutdown() {
    if (exitApp) {
      // 退出app
      exit(0);
    } else {
      // 暂停播放
      SmartDialog.showToast("定时关闭时间已到");
    }
  }

  void cancelShutdownTimer() {
    isWaiting = false;
    _shutdownTimer?.cancel();
  }
}

final shutdownTimerService = ShutdownTimerService();
