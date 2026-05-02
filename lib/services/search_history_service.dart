import 'package:piliotto/utils/storage.dart';

class SearchHistoryService {
  static const String _historyKey = 'searchHistory';
  static const int _maxHistoryCount = 20;

  List<String> _searchHistory = [];

  List<String> loadSearchHistory() {
    try {
      final history =
          GStrorage.historyword.get(_historyKey, defaultValue: <String>[]);
      _searchHistory = List<String>.from(history);
    } catch (_) {
      _searchHistory = [];
    }
    return _searchHistory;
  }

  void saveSearchHistory(String keyword) {
    if (keyword.trim().isEmpty) return;

    _searchHistory.remove(keyword);
    _searchHistory.insert(0, keyword);

    if (_searchHistory.length > _maxHistoryCount) {
      _searchHistory = _searchHistory.sublist(0, _maxHistoryCount);
    }

    try {
      GStrorage.historyword.put(_historyKey, _searchHistory);
    } catch (_) {}
  }

  void clearSearchHistory() {
    _searchHistory.clear();
    try {
      GStrorage.historyword.put(_historyKey, <String>[]);
    } catch (_) {}
  }

  void removeSearchHistory(String keyword) {
    _searchHistory.remove(keyword);
    try {
      GStrorage.historyword.put(_historyKey, _searchHistory);
    } catch (_) {}
  }

  List<String> filterSearchHistory(String query) {
    if (query.isEmpty) {
      return _searchHistory;
    }
    return _searchHistory
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<String> get currentHistory => List.unmodifiable(_searchHistory);
}
