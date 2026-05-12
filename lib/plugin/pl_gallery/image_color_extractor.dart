import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 从图片 URL 提取主色调，并生成适合作为遮罩的颜色
/// 
/// 返回的颜色保证对比度足够高（不会太浅），适合作为图片查看器的遮罩背景
class ImageColorExtractor {
  /// 从图片 URL 提取主色调并处理为遮罩颜色
  /// 
  /// [imageUrl] 图片 URL
  /// [defaultColor] 提取失败时的默认颜色
  /// [alpha] 遮罩不透明度 (0.0 - 1.0)
  static Future<Color> extractOverlayColor(
    String imageUrl, {
    Color defaultColor = Colors.black,
    double alpha = 0.5,
  }) async {
    try {
      final color = await _extractDominantColor(imageUrl);
      return _processColorForOverlay(color, alpha);
    } catch (e) {
      return defaultColor.withValues(alpha: alpha);
    }
  }

  /// 从图片 URL 提取主色调
  static Future<Color> _extractDominantColor(String imageUrl) async {
    final ByteData data = await NetworkAssetBundle(Uri.parse(imageUrl))
        .load(imageUrl);
    final Uint8List bytes = data.buffer.asUint8List();
    
    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 50,
      targetHeight: 50,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    
    if (byteData == null) {
      throw Exception('Failed to get image bytes');
    }

    final Uint32List pixels = byteData.buffer.asUint32List();
    
    // 使用简单的颜色量化算法提取主色调
    final Map<int, int> colorCounts = {};
    
    for (final pixel in pixels) {
      // 量化颜色，减少颜色数量
      final int r = ((pixel >> 16) & 0xFF) ~/ 32 * 32;
      final int g = ((pixel >> 8) & 0xFF) ~/ 32 * 32;
      final int b = (pixel & 0xFF) ~/ 32 * 32;
      
      // 跳过太暗或太亮的颜色
      final int brightness = (r + g + b) ~/ 3;
      if (brightness < 30 || brightness > 225) continue;
      
      final int quantizedColor = (r << 16) | (g << 8) | b;
      colorCounts[quantizedColor] = (colorCounts[quantizedColor] ?? 0) + 1;
    }

    if (colorCounts.isEmpty) {
      throw Exception('No valid colors found');
    }

    // 找到出现次数最多的颜色
    final int dominantColor = colorCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return Color(dominantColor | 0xFF000000);
  }

  /// 处理颜色以确保对比度足够
  /// 
  /// 规则：
  /// 1. 降低饱和度（避免颜色过于鲜艳）
  /// 2. 降低亮度（确保对比度足够）
  /// 3. 应用指定的不透明度
  static Color _processColorForOverlay(Color color, double alpha) {
    // 转换为 HSL
    final HSLColor hsl = HSLColor.fromColor(color);
    
    // 降低饱和度到 30-50% 范围
    final double saturation = math.max(0.15, math.min(0.35, hsl.saturation * 0.4));
    
    // 降低亮度到 20-35% 范围（确保对比度足够）
    final double lightness = math.max(0.15, math.min(0.30, hsl.lightness * 0.5));
    
    return hsl
        .withSaturation(saturation)
        .withLightness(lightness)
        .toColor()
        .withValues(alpha: alpha);
  }

  /// 同步获取默认遮罩颜色（用于首次显示时）
  static Color getDefaultOverlayColor({double alpha = 0.5}) {
    return Colors.black.withValues(alpha: alpha);
  }
}
