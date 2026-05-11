import 'package:flutter/material.dart';

mixin ScrollToTopMixin<T extends StatefulWidget> on State<T> {
  void scrollToTop(ScrollController scrollController) {
    if (!scrollController.hasClients) return;
    
    if (scrollController.offset >= MediaQuery.of(context).size.height * 3) {
      scrollController.jumpTo(0);
    } else {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
}
