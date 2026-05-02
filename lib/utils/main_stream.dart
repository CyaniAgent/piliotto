import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:piliotto/pages/home/provider.dart';
import 'package:piliotto/pages/main/view.dart';

void handleScrollEvent(ScrollController scrollController, WidgetRef ref) {
  EasyThrottle.throttle(
    'stream-throttler',
    const Duration(milliseconds: 300),
    () {
      try {
        final ScrollDirection direction =
            scrollController.position.userScrollDirection;
        final mainNotifier = ref.read(mainAppProvider.notifier);
        final homeNotifier = ref.read(homeProvider.notifier);
        if (direction == ScrollDirection.forward) {
          mainNotifier.bottomBarStream.add(true);
          homeNotifier.searchBarStream.add(true);
        } else if (direction == ScrollDirection.reverse) {
          mainNotifier.bottomBarStream.add(false);
          homeNotifier.searchBarStream.add(false);
        }
      } catch (_) {}
    },
  );
}
