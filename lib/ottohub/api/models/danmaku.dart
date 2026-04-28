class Danmaku {
  final int danmakuId;
  final String text;
  final double time;
  final String mode;
  final String color;
  final String fontSize;
  final String render;

  Danmaku({
    required this.danmakuId,
    required this.text,
    required this.time,
    required this.mode,
    required this.color,
    required this.fontSize,
    required this.render,
  });

  factory Danmaku.fromJson(Map<String, dynamic> json) {
    return Danmaku(
      danmakuId: json['danmaku_id'],
      text: json['text'],
      time: json['time'].toDouble(),
      mode: json['mode'],
      color: json['color'],
      fontSize: json['font_size'],
      render: json['render'],
    );
  }
}
