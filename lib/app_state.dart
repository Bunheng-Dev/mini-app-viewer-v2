import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mini_app_viewer/data/mock_data.dart';
import 'package:mini_app_viewer/models/telegram_user.dart';
import 'package:mini_app_viewer/models/aba_profile.dart';
import 'package:mini_app_viewer/models/aba_account.dart';
import 'package:mini_app_viewer/models/history_item.dart';

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
  String? _currentMiniApp; // Track which mini app is being opened

  // Editable data initialized from mock_data.dart
  TelegramUser telegramUser = mockTelegramUser;
  ABAProfile abaProfile = mockABAProfile;
  ABAAccount abaAccount = mockABAAccount;

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
  String? get currentMiniApp => _currentMiniApp;

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

      // Load showHeader setting (default to true if not set)
      _showHeader = prefs.getBool('showHeader') ?? true;

      // Load Telegram user data
      final telegramJson = prefs.getString('telegramUser');
      if (telegramJson != null) {
        try {
          final data = Map<String, dynamic>.from(
            Uri.splitQueryString(telegramJson),
          );
          telegramUser = TelegramUser(
            id: int.parse(data['id'] ?? '${mockTelegramUser.id}'),
            username: data['username'] ?? mockTelegramUser.username,
            firstName: data['firstName'] ?? mockTelegramUser.firstName,
            lastName: data['lastName'] ?? mockTelegramUser.lastName,
            photoUrl: data['photoUrl'] ?? mockTelegramUser.photoUrl,
            languageCode: data['languageCode'] ?? mockTelegramUser.languageCode,
          );
        } catch (e) {
          print('Error parsing Telegram user data: $e');
        }
      }

      // Load ABA profile data
      final abaProfileJson = prefs.getString('abaProfile');
      if (abaProfileJson != null) {
        try {
          final data = Map<String, dynamic>.from(
            Uri.splitQueryString(abaProfileJson),
          );
          abaProfile = ABAProfile(
            appId: data['appId'] ?? mockABAProfile.appId,
            firstName: data['firstName'] ?? mockABAProfile.firstName,
            middleName: data['middleName'] ?? mockABAProfile.middleName,
            lastName: data['lastName'] ?? mockABAProfile.lastName,
            fullName: data['fullName'] ?? mockABAProfile.fullName,
            sex: data['sex'] ?? mockABAProfile.sex,
            dobShort: data['dobShort'] ?? mockABAProfile.dobShort,
            nationality: data['nationality'] ?? mockABAProfile.nationality,
            phone: data['phone'] ?? mockABAProfile.phone,
            email: data['email'] ?? mockABAProfile.email,
            lang: data['lang'] ?? mockABAProfile.lang,
            id: data['id'] ?? mockABAProfile.id,
            appVersion: data['appVersion'] ?? mockABAProfile.appVersion,
            osVersion: data['osVersion'] ?? mockABAProfile.osVersion,
            address: data['address'] ?? mockABAProfile.address,
            city: data['city'] ?? mockABAProfile.city,
            country: data['country'] ?? mockABAProfile.country,
            dobFull: data['dobFull'] ?? mockABAProfile.dobFull,
            nidNumber: data['nidNumber'] ?? mockABAProfile.nidNumber,
            nidType: data['nidType'] ?? mockABAProfile.nidType,
            nidExpiryDate:
                data['nidExpiryDate'] ?? mockABAProfile.nidExpiryDate,
            nidDoc: data['nidDoc'] ?? mockABAProfile.nidDoc,
            occupation: data['occupation'] ?? mockABAProfile.occupation,
            addrCode: data['addrCode'] ?? mockABAProfile.addrCode,
            secretKey: data['secretKey'] ?? mockABAProfile.secretKey,
          );
        } catch (e) {
          print('Error parsing ABA profile data: $e');
        }
      }

      // Load ABA account data
      final abaAccountJson = prefs.getString('abaAccount');
      if (abaAccountJson != null) {
        try {
          final data = Map<String, dynamic>.from(
            Uri.splitQueryString(abaAccountJson),
          );
          abaAccount = ABAAccount(
            accountName: data['accountName'] ?? mockABAAccount.accountName,
            accountNumber:
                data['accountNumber'] ?? mockABAAccount.accountNumber,
            currency: data['currency'] ?? mockABAAccount.currency,
          );
        } catch (e) {
          print('Error parsing ABA account data: $e');
        }
      }

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
  Future<void> toggleShowHeader(bool value) async {
    _showHeader = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('showHeader', value);
    } catch (e) {
      print('Error saving showHeader setting: $e');
    }
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
  void loadUrl(String url, String title, String color, {String? miniAppName}) {
    if (_isValidUrl(url)) {
      _url = url;
      _customTitle =
          title.trim().isNotEmpty ? title.trim() : _getDomainTitle(url);
      _customColor = _parseColor(color.trim());
      _isLoading = true;
      _currentMiniApp = miniAppName;

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
    // Don't reset _showHeader - keep user's preference
    _currentMiniApp = null;
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

  // Update Telegram user data
  Future<void> updateTelegramUser(TelegramUser newUser) async {
    telegramUser = newUser;

    // Save to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'id': newUser.id.toString(),
        'username': newUser.username,
        'firstName': newUser.firstName,
        'lastName': newUser.lastName,
        'photoUrl': newUser.photoUrl,
        'languageCode': newUser.languageCode,
      };
      final queryString = Uri(queryParameters: data).query;
      await prefs.setString('telegramUser', queryString);
    } catch (e) {
      print('Error saving Telegram user data: $e');
    }

    notifyListeners();
  }

  // Update ABA profile data
  Future<void> updateABAProfile(ABAProfile newProfile) async {
    abaProfile = newProfile;

    // Save to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'appId': newProfile.appId,
        'firstName': newProfile.firstName,
        'middleName': newProfile.middleName,
        'lastName': newProfile.lastName,
        'fullName': newProfile.fullName,
        'sex': newProfile.sex,
        'dobShort': newProfile.dobShort,
        'nationality': newProfile.nationality,
        'phone': newProfile.phone,
        'email': newProfile.email,
        'lang': newProfile.lang,
        'id': newProfile.id,
        'appVersion': newProfile.appVersion,
        'osVersion': newProfile.osVersion,
        'address': newProfile.address,
        'city': newProfile.city,
        'country': newProfile.country,
        'dobFull': newProfile.dobFull,
        'nidNumber': newProfile.nidNumber,
        'nidType': newProfile.nidType,
        'nidExpiryDate': newProfile.nidExpiryDate,
        'nidDoc': newProfile.nidDoc,
        'occupation': newProfile.occupation,
        'addrCode': newProfile.addrCode,
        'secretKey': newProfile.secretKey,
      };
      final queryString = Uri(queryParameters: data).query;
      await prefs.setString('abaProfile', queryString);
    } catch (e) {
      print('Error saving ABA profile data: $e');
    }

    notifyListeners();
  }

  // Update ABA account data
  Future<void> updateABAAccount(ABAAccount newAccount) async {
    abaAccount = newAccount;

    // Save to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'accountName': newAccount.accountName,
        'accountNumber': newAccount.accountNumber,
        'currency': newAccount.currency,
      };
      final queryString = Uri(queryParameters: data).query;
      await prefs.setString('abaAccount', queryString);
    } catch (e) {
      print('Error saving ABA account data: $e');
    }

    notifyListeners();
  }
}
