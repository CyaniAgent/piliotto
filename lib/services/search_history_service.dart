import 'package:hive/hive.dart';
import 'package:piliotto/utils/storage.dart';

class SearchHistoryService {
  static const String _historyKey = 'searchHistory';
  static const int _maxHistoryCount = 20;

  final Box _historyBox = GStrorage.historyword;
  List<String> _searchHistory = [];

  List<String> loadSearchHistory() {
    final history = _historyBox.get(_historyKey, defaultValue: <String>[]);
    _searchHistory = List<String>.from(history);
    return _searchHistory;
  }

  void saveSearchHistory(String keyword) {
    if (keyword.trim().isEmpty) return;

    _searchHistory.remove(keyword);
    _searchHistory.insert(0, keyword);

    if (_searchHistory.length > _maxHistoryCount) {
      _searchHistory = _searchHistory.sublist(0, _maxHistoryCount);
    }

    _historyBox.put(_historyKey, _searchHistory);
  }

  void clearSearchHistory() {
    _searchHistory.clear();
    _historyBox.put(_historyKey, <String>[]);
  }

  void removeSearchHistory(String keyword) {
    _searchHistory.remove(keyword);
    _historyBox.put(_historyKey, _searchHistory);
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
