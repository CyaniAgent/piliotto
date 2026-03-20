// TODO: 迁移到 Ottohub API（如果有历史记录功能）

class Data {
  static Future init() async {
    await historyStatus();
  }

  static Future historyStatus() async {
    // Ottohub API 暂不支持历史记录功能
  }
}
