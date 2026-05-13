library;

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:piliotto/utils/download.dart';
import 'package:share_plus/share_plus.dart';
import 'package:status_bar_control_plus/status_bar_control_plus.dart';
import 'custom_dismissible.dart';
import 'interactive_viewer_boundary.dart';

/// Builds a carousel controlled by a [PageView] for the tweet media sources.
///
/// Used for showing a full screen view of the [TweetMedia] sources.
///
/// The sources can be panned and zoomed interactively using an
/// [InteractiveViewer].
/// An [InteractiveViewerBoundary] is used to detect when the boundary of the
/// source is hit after zooming in to disable or enable the swiping gesture of
/// the [PageView].
///
typedef IndexedFocusedWidgetBuilder = Widget Function(
    BuildContext context, int index, bool isFocus, bool enablePageView);

typedef IndexedTagStringBuilder = String Function(int index);

class InteractiveviewerGallery<T> extends StatefulWidget {
  const InteractiveviewerGallery({
    required this.sources,
    required this.initIndex,
    this.itemBuilder,
    this.maxScale = 4.5,
    this.minScale = 1.0,
    this.onPageChanged,
    this.onDismissed,
    this.heroTagBuilder,
    this.showPageNavigationButtons = false,
    super.key,
  });

  /// The sources to show.
  final List<T> sources;

  /// The index of the first source in [sources] to show.
  final int initIndex;

  /// The item content
  final IndexedFocusedWidgetBuilder? itemBuilder;

  final double maxScale;

  final double minScale;

  final ValueChanged<int>? onPageChanged;

  final ValueChanged<int>? onDismissed;

  final IndexedTagStringBuilder? heroTagBuilder;

  final bool showPageNavigationButtons;

  @override
  State<InteractiveviewerGallery> createState() =>
      _InteractiveviewerGalleryState();
}

class _InteractiveviewerGalleryState extends State<InteractiveviewerGallery>
    with SingleTickerProviderStateMixin {
  PageController? _pageController;
  TransformationController? _transformationController;

  /// The controller to animate the transformation value of the
  /// [InteractiveViewer] when it should reset.
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  /// `true` when an source is zoomed in and not at the at a horizontal boundary
  /// to disable the [PageView].
  bool _enablePageView = true;

  /// `true` when an source is zoomed in to disable the [CustomDismissible].
  bool _enableDismiss = true;

  late Offset _doubleTapLocalPosition;

  int? currentIndex;

  // PC interaction
  final FocusNode _focusNode = FocusNode();

  // Rotation state per image
  final Map<int, double> _rotationAngles = {};

  // Toolbar visibility
  bool _toolbarVisible = true;
  Timer? _toolbarTimer;

  // Batch selection mode
  bool _batchMode = false;
  final Set<int> _selectedIndices = {};

  // Image info cache
  final Map<int, ImageInfoData> _imageInfoCache = {};

  // Swipe to dismiss enabled
  late bool _swipeToDismissEnabled;

  // Show page navigation buttons
  late bool _showPageNavigationButtons;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: widget.initIndex);

    _transformationController = TransformationController();

    // PC端默认禁用滑动退出
    _swipeToDismissEnabled = !Platform.isWindows && !Platform.isMacOS && !Platform.isLinux;

    _showPageNavigationButtons = widget.showPageNavigationButtons;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )
      ..addListener(() {
        _transformationController!.value =
            _animation?.value ?? Matrix4.identity();
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed && !_enableDismiss) {
          setState(() {
            _enableDismiss = true;
          });
        }
      });

    currentIndex = widget.initIndex;
    setStatusBar();
    _startToolbarTimer();
  }

  Future<void> setStatusBar() async {
    if (Platform.isIOS || Platform.isAndroid) {
      await StatusBarControlPlus.setHidden(true,
          animation: StatusBarAnimation.FADE);
    }
  }

  @override
  void dispose() {
    _pageController!.dispose();
    _animationController.dispose();
    _focusNode.dispose();
    _toolbarTimer?.cancel();
    if (Platform.isIOS || Platform.isAndroid) {
      try {
        StatusBarControlPlus.setHidden(false,
            animation: StatusBarAnimation.FADE);
      } catch (_) {}
    }
    super.dispose();
  }

  void _startToolbarTimer() {
    _toolbarTimer?.cancel();
    _toolbarTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _toolbarVisible) {
        setState(() {
          _toolbarVisible = false;
        });
      }
    });
  }

  void _showToolbar() {
    if (!_toolbarVisible) {
      setState(() {
        _toolbarVisible = true;
      });
    }
    _startToolbarTimer();
  }

  /// When the source gets scaled up, the swipe up / down to dismiss gets
  /// disabled.
  ///
  /// When the scale resets, the dismiss and the page view swiping gets enabled.
  void _onScaleChanged(double scale) {
    final bool initialScale = scale <= widget.minScale;

    if (initialScale) {
      if (!_enableDismiss) {
        setState(() {
          _enableDismiss = true;
        });
      }

      if (!_enablePageView) {
        setState(() {
          _enablePageView = true;
        });
      }
    } else {
      if (_enableDismiss) {
        setState(() {
          _enableDismiss = false;
        });
      }

      if (_enablePageView) {
        setState(() {
          _enablePageView = false;
        });
      }
    }
  }

  /// When the left boundary has been hit after scaling up the source, the page
  /// view swiping gets enabled if it has a page to swipe to.
  void _onLeftBoundaryHit() {
    if (!_enablePageView && _pageController!.page!.floor() > 0) {
      setState(() {
        _enablePageView = true;
      });
    }
  }

  /// When the right boundary has been hit after scaling up the source, the page
  /// view swiping gets enabled if it has a page to swipe to.
  void _onRightBoundaryHit() {
    if (!_enablePageView &&
        _pageController!.page!.floor() < widget.sources.length - 1) {
      setState(() {
        _enablePageView = true;
      });
    }
  }

  /// When the source has been scaled up and no horizontal boundary has been hit,
  /// the page view swiping gets disabled.
  void _onNoBoundaryHit() {
    if (_enablePageView) {
      setState(() {
        _enablePageView = false;
      });
    }
  }

  /// When the page view changed its page, the source will animate back into the
  /// original scale if it was scaled up.
  ///
  /// Additionally the swipe up / down to dismiss gets enabled.
  void _onPageChanged(int page) {
    setState(() {
      currentIndex = page;
    });
    widget.onPageChanged?.call(page);
    if (_transformationController!.value != Matrix4.identity()) {
      // animate the reset for the transformation of the interactive viewer

      _animation = Matrix4Tween(
        begin: _transformationController!.value,
        end: Matrix4.identity(),
      ).animate(
        CurveTween(curve: Curves.easeOut).animate(_animationController),
      );

      _animationController.forward(from: 0);
    }
  }

  void _goToPrevious() {
    if (currentIndex! > 0) {
      _pageController!.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    if (currentIndex! < widget.sources.length - 1) {
      _pageController!.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _close() {
    Navigator.of(context).pop();
    widget.onDismissed?.call(_pageController!.page!.floor());
  }

  void _rotateImage() {
    setState(() {
      _rotationAngles[currentIndex!] =
          (_rotationAngles[currentIndex!] ?? 0) + math.pi / 2;
    });
  }

  Future<void> _showImageInfo() async {
    final url = widget.sources[currentIndex!].toString();
    ImageInfoData? info = _imageInfoCache[currentIndex!];

    if (info == null) {
      try {
        final response = await Dio().head(url);
        final contentLength = response.headers.value('content-length');
        final contentType = response.headers.value('content-type');

        // Try to get image dimensions
        final imageProvider = CachedNetworkImageProvider(url);
        final imageStream = imageProvider.resolve(ImageConfiguration.empty);
        final completer = Completer<Size>();
        late ImageStreamListener listener;
        listener = ImageStreamListener((ImageInfo imageInfo, bool _) {
          if (!completer.isCompleted) {
            completer.complete(Size(
              imageInfo.image.width.toDouble(),
              imageInfo.image.height.toDouble(),
            ));
          }
          imageStream.removeListener(listener);
        });
        imageStream.addListener(listener);

        final size = await completer.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            imageStream.removeListener(listener);
            return Size.zero;
          },
        );

        info = ImageInfoData(
          width: size.width > 0 ? size.width.toInt() : null,
          height: size.height > 0 ? size.height.toInt() : null,
          fileSize: contentLength != null ? int.tryParse(contentLength) : null,
          format: contentType?.split('/').last ?? 'unknown',
        );
        _imageInfoCache[currentIndex!] = info;
      } catch (e) {
        info = ImageInfoData(
          width: null,
          height: null,
          fileSize: null,
          format: 'unknown',
        );
      }
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '图片信息',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow('URL', url, context),
              if (info != null && info.width != null && info.height != null)
                _buildInfoRow('尺寸', '${info.width} x ${info.height}', context),
              if (info != null && info.fileSize != null)
                _buildInfoRow('大小', _formatFileSize(info.fileSize!), context),
              if (info != null)
                _buildInfoRow('格式', info.format.toUpperCase(), context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _toggleBatchMode() {
    setState(() {
      _batchMode = !_batchMode;
      if (!_batchMode) {
        _selectedIndices.clear();
      }
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  Future<void> _batchDownload() async {
    if (_selectedIndices.isEmpty) {
      SmartDialog.showToast('请先选择图片');
      return;
    }

    SmartDialog.showLoading(msg: '下载中...');
    try {
      for (final index in _selectedIndices) {
        await DownloadUtils.downloadImg(widget.sources[index]);
      }
      SmartDialog.dismiss();
      SmartDialog.showToast('已保存 ${_selectedIndices.length} 张图片');
    } catch (e) {
      SmartDialog.dismiss();
      SmartDialog.showToast('下载失败: $e');
    }

    setState(() {
      _batchMode = false;
      _selectedIndices.clear();
    });
  }

  Future<void> _batchShare() async {
    if (_selectedIndices.isEmpty) {
      SmartDialog.showToast('请先选择图片');
      return;
    }

    SmartDialog.showLoading(msg: '准备中...');
    try {
      final files = <XFile>[];
      for (final index in _selectedIndices) {
        final url = widget.sources[index].toString();
        final response = await Dio()
            .get(url, options: Options(responseType: ResponseType.bytes));
        final temp = await getTemporaryDirectory();
        final imgName =
            "plpl_pic_${DateTime.now().millisecondsSinceEpoch}_$index.jpg";
        final path = '${temp.path}/$imgName';
        await File(path).writeAsBytes(response.data);
        files.add(XFile(path));
      }
      SmartDialog.dismiss();
      SharePlus.instance.share(ShareParams(files: files));
    } catch (e) {
      SmartDialog.dismiss();
      SmartDialog.showToast('分享失败: $e');
    }

    setState(() {
      _batchMode = false;
      _selectedIndices.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowLeft:
              _goToPrevious();
              break;
            case LogicalKeyboardKey.arrowRight:
              _goToNext();
              break;
            case LogicalKeyboardKey.escape:
              _close();
              break;
          }
        }
      },
      child: MouseRegion(
        onHover: (_) => _showToolbar(),
        child: Stack(children: [
          InteractiveViewerBoundary(
            controller: _transformationController,
            boundaryWidth: MediaQuery.of(context).size.width,
            onScaleChanged: _onScaleChanged,
            onLeftBoundaryHit: _onLeftBoundaryHit,
            onRightBoundaryHit: _onRightBoundaryHit,
            onNoBoundaryHit: _onNoBoundaryHit,
            maxScale: widget.maxScale,
            minScale: widget.minScale,
            child: CustomDismissible(
              onDismissed: _close,
              enabled: _enableDismiss && _swipeToDismissEnabled,
              onDragUpdate: (progress) {
                // Background opacity follows dismiss progress
              },
              child: PageView.builder(
                onPageChanged: _onPageChanged,
                controller: _pageController,
                physics: _enablePageView
                    ? null
                    : const NeverScrollableScrollPhysics(),
                itemCount: widget.sources.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onDoubleTapDown: (TapDownDetails details) {
                      _doubleTapLocalPosition = details.localPosition;
                    },
                    onDoubleTap: onDoubleTap,
                    onLongPress: onLongPress,
                    child: widget.itemBuilder != null
                        ? widget.itemBuilder!(
                            context,
                            index,
                            index == currentIndex,
                            _enablePageView,
                          )
                        : _itemBuilder(widget.sources, index),
                  );
                },
              ),
            ),
          ),
          // Page indicators
          if (widget.sources.length > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _toolbarVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${currentIndex! + 1} / ${widget.sources.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Batch mode selection indicator
          if (_batchMode)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '已选择 ${_selectedIndices.length} 张',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          // Page navigation buttons
          if (_showPageNavigationButtons && widget.sources.length > 1)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _toolbarVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Row(
                  children: [
                    if (currentIndex! > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _ToolbarButton(
                          icon: Icons.chevron_left,
                          onPressed: _goToPrevious,
                        ),
                      ),
                    const Spacer(),
                    if (currentIndex! < widget.sources.length - 1)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _ToolbarButton(
                          icon: Icons.chevron_right,
                          onPressed: _goToNext,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          // Bottom toolbar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _toolbarVisible ? 0 : -100,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7)
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: _batchMode
                    ? _buildBatchToolbar()
                    : _buildNormalToolbar(),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildNormalToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ToolbarButton(
          icon: Icons.close,
          onPressed: _close,
        ),
        _ToolbarButton(
          icon: Icons.rotate_right,
          onPressed: _rotateImage,
        ),
        if (widget.sources.length > 1)
          _ToolbarButton(
            icon: Icons.checklist,
            onPressed: _toggleBatchMode,
          ),
        _ToolbarButton(
          icon: Icons.more_horiz,
          onPressed: () => _showMoreMenu(),
        ),
      ],
    );
  }

  Widget _buildBatchToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ToolbarButton(
          icon: Icons.close,
          onPressed: _toggleBatchMode,
        ),
        _ToolbarButton(
          icon: Icons.download,
          onPressed: _batchDownload,
        ),
        _ToolbarButton(
          icon: Icons.share,
          onPressed: _batchShare,
        ),
      ],
    );
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 35,
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Center(
                        child: Container(
                          width: 32,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.outline,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showImageInfo();
                    },
                    title: const Text('图片信息'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.share),
                    onTap: () {
                      onShareImg(widget.sources[currentIndex!]);
                      Navigator.of(context).pop();
                    },
                    title: const Text('分享图片'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.copy),
                    onTap: () {
                      onCopyImg(widget.sources[currentIndex!].toString());
                      Navigator.of(context).pop();
                    },
                    title: const Text('复制图片'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.download),
                    onTap: () {
                      DownloadUtils.downloadImg(widget.sources[currentIndex!]);
                      Navigator.of(context).pop();
                    },
                    title: const Text('保存图片'),
                  ),
                  SwitchListTile(
                    secondary: Icon(
                      _swipeToDismissEnabled
                          ? Icons.swipe
                          : Icons.swipe_outlined,
                    ),
                    title: const Text('滑动退出'),
                    subtitle: const Text('上下滑动关闭图片查看器'),
                    value: _swipeToDismissEnabled,
                    onChanged: (value) {
                      setState(() {
                        _swipeToDismissEnabled = value;
                      });
                      setModalState(() {});
                    },
                  ),
                  if (widget.sources.length > 1)
                    SwitchListTile(
                      secondary: Icon(
                        _showPageNavigationButtons
                            ? Icons.navigate_before
                            : Icons.navigate_before_outlined,
                      ),
                      title: const Text('切换按钮'),
                      subtitle: const Text('显示左右切换图片按钮'),
                      value: _showPageNavigationButtons,
                      onChanged: (value) {
                        setState(() {
                          _showPageNavigationButtons = value;
                        });
                        setModalState(() {});
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 图片分享
  void onShareImg(String imgUrl) async {
    SmartDialog.showLoading();
    var response = await Dio()
        .get(imgUrl, options: Options(responseType: ResponseType.bytes));
    final temp = await getTemporaryDirectory();
    SmartDialog.dismiss();
    String imgName =
        "plpl_pic_${DateTime.now().toString().split('-').join()}.jpg";
    var path = '${temp.path}/$imgName';
    File(path).writeAsBytesSync(response.data);
    SharePlus.instance.share(
      ShareParams(
        files: [XFile(path)],
        subject: imgUrl,
      ),
    );
  }

  // 复制图片
  void onCopyImg(String imgUrl) {
    Clipboard.setData(
            ClipboardData(text: widget.sources[currentIndex!].toString()))
        .then((value) {
      SmartDialog.showToast('已复制到粘贴板');
    }).catchError((err) {
      SmartDialog.showNotify(
        msg: err.toString(),
        notifyType: NotifyType.error,
      );
    });
  }

  Widget _itemBuilder(List<dynamic> sources, int index) {
    final heroTag = widget.heroTagBuilder?.call(index);
    final useHero = heroTag != null && heroTag.isNotEmpty;
    final rotationAngle = _rotationAngles[index] ?? 0;

    final imageWidget = AnimatedRotation(
      turns: rotationAngle / (2 * math.pi),
      duration: const Duration(milliseconds: 300),
      child: CachedNetworkImage(
        fadeInDuration: const Duration(milliseconds: 0),
        imageUrl: sources[index],
        fit: BoxFit.contain,
        placeholder: (context, url) => Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.black,
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
          ),
        ),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_batchMode) {
          _toggleSelection(index);
        } else if (_enablePageView) {
          _close();
        }
      },
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            useHero
                ? Hero(
                    tag: heroTag,
                    flightShuttleBuilder: (flightContext, animation,
                        flightDirection, fromHeroContext, toHeroContext) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: animation.value,
                            child: child,
                          );
                        },
                        child: imageWidget,
                      );
                    },
                    child: imageWidget,
                  )
                : imageWidget,
            if (_batchMode)
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => _toggleSelection(index),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedIndices.contains(index)
                          ? Theme.of(context).colorScheme.primary
                          : Colors.black.withValues(alpha: 0.5),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: _selectedIndices.contains(index)
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void onDoubleTap() {
    Matrix4 matrix = _transformationController!.value.clone();
    double currentScale = matrix.row0.x;

    double targetScale = widget.minScale;

    if (currentScale <= widget.minScale) {
      targetScale = widget.maxScale * 0.7;
    }

    double offSetX = targetScale == 1.0
        ? 0.0
        : -_doubleTapLocalPosition.dx * (targetScale - 1);
    double offSetY = targetScale == 1.0
        ? 0.0
        : -_doubleTapLocalPosition.dy * (targetScale - 1);

    matrix = Matrix4.fromList([
      targetScale,
      matrix.row1.x,
      matrix.row2.x,
      matrix.row3.x,
      matrix.row0.y,
      targetScale,
      matrix.row2.y,
      matrix.row3.y,
      matrix.row0.z,
      matrix.row1.z,
      targetScale,
      matrix.row3.z,
      offSetX,
      offSetY,
      matrix.row2.w,
      matrix.row3.w
    ]);

    _animation = Matrix4Tween(
      begin: _transformationController!.value,
      end: matrix,
    ).animate(
      CurveTween(curve: Curves.easeOut).animate(_animationController),
    );
    _animationController
        .forward(from: 0)
        .whenComplete(() => _onScaleChanged(targetScale));
  }

  void onLongPress() {
    if (_batchMode) return;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => Get.back(),
                child: Container(
                  height: 35,
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Center(
                    child: Container(
                      width: 32,
                      height: 3,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outline,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(3))),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.share),
                onTap: () {
                  onShareImg(widget.sources[currentIndex!]);
                  Navigator.of(context).pop();
                },
                title: const Text('分享图片'),
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                onTap: () {
                  onCopyImg(widget.sources[currentIndex!].toString());
                  Navigator.of(context).pop();
                },
                title: const Text('复制图片'),
              ),
              ListTile(
                leading: const Icon(Icons.download),
                onTap: () {
                  DownloadUtils.downloadImg(widget.sources[currentIndex!]);
                  Navigator.of(context).pop();
                },
                title: const Text('保存图片'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      onPressed: onPressed,
      splashRadius: 24,
    );
  }
}

class ImageInfoData {
  final int? width;
  final int? height;
  final int? fileSize;
  final String format;

  ImageInfoData({
    this.width,
    this.height,
    this.fileSize,
    required this.format,
  });
}
