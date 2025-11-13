import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryItem {
  final String url;
  final String title;
  final DateTime timestamp;

  HistoryItem({
    required this.url,
    required this.title,
    required this.timestamp,
  });

  // Get favicon URL for the domain
  String get faviconUrl {
    try {
      final uri = Uri.parse(url);
      return 'https://www.google.com/s2/favicons?domain=${uri.host}&sz=64';
    } catch (e) {
      return '';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      url: json['url'],
      title: json['title'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class AppState extends ChangeNotifier {
  String? _url;
  String _customTitle = 'Mini App';
  Color _customColor = Colors.blue;
  bool _isLoading = false;
  String _urlInput = '';
  String _titleInput = '';
  String _colorInput = '';
  List<HistoryItem> _history = [];
  bool _showHeader = true;

  // Getters
  String? get url => _url;
  String get customTitle => _customTitle;
  Color get customColor => _customColor;
  bool get isLoading => _isLoading;
  String get urlInput => _urlInput;
  String get titleInput => _titleInput;
  String get colorInput => _colorInput;
  List<HistoryItem> get history => _history;
  bool get showHeader => _showHeader;

  // Initialize and load history from shared preferences
  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('history') ?? [];
      _history =
          historyJson.map((item) {
            final Map<String, dynamic> json = {
              'url': item.split('|||')[0],
              'title': item.split('|||')[1],
              'timestamp': item.split('|||')[2],
            };
            return HistoryItem.fromJson(json);
          }).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading history: $e');
    }
  }

  // Save history to shared preferences
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson =
          _history.map((item) {
            return '${item.url}|||${item.title}|||${item.timestamp.toIso8601String()}';
          }).toList();
      await prefs.setStringList('history', historyJson);
    } catch (e) {
      print('Error saving history: $e');
    }
  }

  // Add URL to history
  Future<void> _addToHistory(String url, String title) async {
    // Remove duplicate if exists
    _history.removeWhere((item) => item.url == url);

    // Add new item at the beginning
    _history.insert(
      0,
      HistoryItem(url: url, title: title, timestamp: DateTime.now()),
    );

    // Keep only last 50 items
    if (_history.length > 50) {
      _history = _history.sublist(0, 50);
    }

    await _saveHistory();
    notifyListeners();
  }

  // Clear all history
  Future<void> clearHistory() async {
    _history.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('history');
    notifyListeners();
  }

  // Delete single history item
  Future<void> deleteHistoryItem(HistoryItem item) async {
    _history.remove(item);
    await _saveHistory();
    notifyListeners();
  }

  // Restore (undo) deleted history item
  Future<void> restoreHistoryItem(HistoryItem item, int index) async {
    _history.insert(index, item);
    await _saveHistory();
    notifyListeners();
  }

  // Update URL input
  void updateUrlInput(String value) {
    _urlInput = value;
    notifyListeners();
  }

  // Update title input
  void updateTitleInput(String value) {
    _titleInput = value;
    notifyListeners();
  }

  // Update color input
  void updateColorInput(String value) {
    _colorInput = value;
    notifyListeners();
  }

  // Toggle show header
  void toggleShowHeader(bool value) {
    _showHeader = value;
    notifyListeners();
  }

  // Extract domain name from URL for title
  String _getDomainTitle(String url) {
    try {
      final uri = Uri.parse(url);
      String host = uri.host;

      // Remove 'www.' prefix if present
      if (host.startsWith('www.')) {
        host = host.substring(4);
      }

      // Capitalize first letter
      if (host.isNotEmpty) {
        return host[0].toUpperCase() + host.substring(1);
      }

      return host;
    } catch (e) {
      return 'Mini App';
    }
  }

  // Validate and load URL
  void loadUrl(String url, String title, String color) {
    if (_isValidUrl(url)) {
      _url = url;
      _customTitle =
          title.trim().isNotEmpty ? title.trim() : _getDomainTitle(url);
      _customColor = _parseColor(color.trim());
      _isLoading = true;

      // Add to history
      _addToHistory(url, _customTitle);

      notifyListeners();
    }
  }

  // Reset to home screen
  void resetToHome() {
    _url = null;
    _isLoading = true;
    _urlInput = '';
    _titleInput = '';
    _colorInput = '';
    _customTitle = 'Mini App';
    _customColor = Colors.blue;
    _showHeader = true;
    notifyListeners();
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Update app bar color dynamically from WebView
  void updateAppBarColor(Color color) {
    _customColor = color;
    notifyListeners();
  }

  // Update page title dynamically from WebView
  void updatePageTitle(String title) {
    if (title.isNotEmpty && title != 'null') {
      _customTitle = title;
      notifyListeners();
    }
  }

  // Validate URL
  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null &&
        (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https'));
  }

  // Parse color from string
  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(
          int.parse(colorString.substring(1), radix: 16) + 0xFF000000,
        );
      }
    } catch (_) {}
    return Colors.blue;
  }
}
