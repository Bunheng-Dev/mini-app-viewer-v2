import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mini_app_viewer/app_state.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isInitialized = false;
  Timer? _titleMonitorTimer;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void dispose() {
    _titleMonitorTimer?.cancel();
    super.dispose();
  }

  void _initializeController() {
    final appState = Provider.of<AppState>(context, listen: false);

    if (appState.url == null || appState.url!.isEmpty) {
      return;
    }

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..addJavaScriptChannel(
            'FlutterApp',
            onMessageReceived: (JavaScriptMessage message) {
              final data = message.message;

              // Handle setHeaderColor
              if (data.startsWith('setHeaderColor:')) {
                final color = data.substring('setHeaderColor:'.length);
                if (color.startsWith('#') && mounted) {
                  try {
                    appState.updateAppBarColor(_hexToColor(color));
                  } catch (e) {
                    print('Error parsing color: $e');
                  }
                }
              }
              // Handle setTitle
              else if (data.startsWith('setTitle:')) {
                final title = data.substring('setTitle:'.length);
                if (title.isNotEmpty && mounted) {
                  appState.updatePageTitle(title);
                }
              }
            },
          )
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) async {
                // Inject Telegram user data immediately when page starts loading
                if (appState.currentMiniApp == 'Telegram') {
                  await Future.delayed(const Duration(milliseconds: 100));
                  await _injectTelegramUserData(appState);
                }
                // Inject ABA data immediately when page starts loading
                if (appState.currentMiniApp == 'ABA') {
                  await Future.delayed(const Duration(milliseconds: 100));
                  await _injectABAData(appState);
                }
              },
              onPageFinished: (url) async {
                appState.setLoading(false);

                // Inject Telegram user data multiple times to ensure it's available
                if (appState.currentMiniApp == 'Telegram') {
                  await _injectTelegramUserData(appState);
                  await Future.delayed(const Duration(milliseconds: 500));
                  await _injectTelegramUserData(appState);
                  await Future.delayed(const Duration(milliseconds: 1000));
                  await _injectTelegramUserData(appState);
                }

                // Inject ABA data multiple times to ensure it's available
                if (appState.currentMiniApp == 'ABA') {
                  await _injectABAData(appState);
                  await Future.delayed(const Duration(milliseconds: 500));
                  await _injectABAData(appState);
                  await Future.delayed(const Duration(milliseconds: 1000));
                  await _injectABAData(appState);
                }

                // Start monitoring title and color changes
                _startTitleMonitoring(appState);

                // Inject JavaScript Bridge API
                await _injectFlutterAppBridge();

                try {
                  String? colorString =
                      await _controller.runJavaScriptReturningResult('''
              (function() {
                var meta = document.querySelector('meta[name="theme-color"]');
                return meta ? meta.getAttribute('content') : null;
              })();
            ''')
                          as String?;

                  String? title =
                      await _controller.runJavaScriptReturningResult(
                            'document.title',
                          )
                          as String?;

                  if (mounted) {
                    if (colorString != null && colorString.startsWith('#')) {
                      appState.updateAppBarColor(_hexToColor(colorString));
                    }
                    if (title != null && title.isNotEmpty && title != 'null') {
                      appState.updatePageTitle(_cleanTitle(title));
                    }
                  }
                } catch (e) {
                  print('Error getting page info: $e');
                }
              },
              onWebResourceError: (error) {
                print('WebView error: ${error.description}');
              },
            ),
          );

    // For Telegram mini apps, inject the user data before loading
    if (appState.currentMiniApp == 'Telegram') {
      _controller.loadRequest(Uri.parse(appState.url!)).then((_) async {
        await Future.delayed(const Duration(milliseconds: 200));
        await _injectTelegramUserData(appState);
      });
    }
    // For ABA mini apps, inject the user data before loading
    else if (appState.currentMiniApp == 'ABA') {
      _controller.loadRequest(Uri.parse(appState.url!)).then((_) async {
        await Future.delayed(const Duration(milliseconds: 200));
        await _injectABAData(appState);
      });
    } else {
      _controller.loadRequest(Uri.parse(appState.url!));
    }

    setState(() {
      _isInitialized = true;
    });
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }

  String _cleanTitle(String title) {
    return title.replaceAll(RegExp(r'^"|"$'), '').trim();
  }

  void _startTitleMonitoring(AppState appState) {
    // Cancel existing timer if any
    _titleMonitorTimer?.cancel();

    // Monitor document.title and theme-color changes every 500ms
    _titleMonitorTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      try {
        // Monitor title changes
        final title =
            await _controller.runJavaScriptReturningResult('document.title')
                as String?;

        if (title != null && title.isNotEmpty && title != 'null') {
          final cleanedTitle = _cleanTitle(title);
          // Only update if title actually changed
          if (cleanedTitle != appState.customTitle) {
            appState.updatePageTitle(cleanedTitle);
          }
        }

        // Monitor theme-color changes
        final colorString =
            await _controller.runJavaScriptReturningResult('''
          (function() {
            var meta = document.querySelector('meta[name="theme-color"]');
            return meta ? meta.getAttribute('content') : null;
          })();
        ''')
                as String?;

        if (colorString != null && colorString.startsWith('#')) {
          final newColor = _hexToColor(colorString);
          // Only update if color actually changed
          if (newColor.value != appState.customColor.value) {
            appState.updateAppBarColor(newColor);
          }
        }
      } catch (e) {
        // Silently fail - page might not be fully loaded
      }
    });
  }

  Future<void> _injectFlutterAppBridge() async {
    try {
      final script = '''
        (function() {
          // Create FlutterApp bridge API
          window.FlutterApp = {
            setHeaderColor: function(color) {
              if (typeof color === 'string' && color.startsWith('#')) {
                window.FlutterApp.postMessage('setHeaderColor:' + color);
                console.log('✅ Header color set to:', color);
              } else {
                console.error('❌ Invalid color format. Use hex color like #FF5733');
              }
            },
            setTitle: function(title) {
              if (typeof title === 'string' && title.length > 0) {
                window.FlutterApp.postMessage('setTitle:' + title);
                console.log('✅ Title set to:', title);
              } else {
                console.error('❌ Invalid title. Must be a non-empty string');
              }
            }
          };
          
          console.log('✅ FlutterApp bridge initialized!');
          console.log('Available methods:');
          console.log('  - window.FlutterApp.setHeaderColor("#FF5733")');
          console.log('  - window.FlutterApp.setTitle("My Title")');
        })();
      ''';

      await _controller.runJavaScript(script);
      print('✅ FlutterApp JavaScript bridge injected');
    } catch (e) {
      print('❌ Error injecting FlutterApp bridge: $e');
    }
  }

  Future<void> _injectTelegramUserData(AppState appState) async {
    try {
      final user = appState.telegramUser;

      // Create Telegram WebApp initialization script
      final script = '''
        (function() {
          console.log("=== Injecting Telegram WebApp ===");
          
          // Create Telegram WebApp object
          window.Telegram = window.Telegram || {};
          
          window.Telegram.WebApp = {
            initData: "user=%7B%22id%22%3A${user.id}%2C%22first_name%22%3A%22${user.firstName}%22%2C%22last_name%22%3A%22${user.lastName}%22%2C%22username%22%3A%22${user.username}%22%2C%22language_code%22%3A%22${user.languageCode}%22%2C%22photo_url%22%3A%22${user.photoUrl}%22%7D",
            initDataUnsafe: {
              user: {
                id: ${user.id},
                first_name: "${user.firstName}",
                last_name: "${user.lastName}",
                username: "${user.username}",
                language_code: "${user.languageCode}",
                photo_url: "${user.photoUrl}"
              },
              auth_date: ${DateTime.now().millisecondsSinceEpoch ~/ 1000}
            },
            version: "6.0",
            platform: "android",
            colorScheme: "light",
            themeParams: {
              bg_color: "#ffffff",
              text_color: "#000000",
              hint_color: "#999999",
              link_color: "#2481cc",
              button_color: "#2481cc",
              button_text_color: "#ffffff"
            },
            isExpanded: true,
            viewportHeight: window.innerHeight,
            viewportStableHeight: window.innerHeight,
            headerColor: "#ffffff",
            backgroundColor: "#ffffff",
            BackButton: {
              isVisible: false,
              onClick: function(callback) { this._callbacks = this._callbacks || []; this._callbacks.push(callback); },
              offClick: function(callback) {},
              show: function() { this.isVisible = true; },
              hide: function() { this.isVisible = false; }
            },
            MainButton: {
              text: "CONTINUE",
              color: "#2481cc",
              textColor: "#ffffff",
              isVisible: false,
              isActive: true,
              isProgressVisible: false,
              setText: function(text) { this.text = text; },
              onClick: function(callback) { this._callbacks = this._callbacks || []; this._callbacks.push(callback); },
              offClick: function(callback) {},
              show: function() { this.isVisible = true; },
              hide: function() { this.isVisible = false; },
              enable: function() { this.isActive = true; },
              disable: function() { this.isActive = false; },
              showProgress: function(leaveActive) { this.isProgressVisible = true; },
              hideProgress: function() { this.isProgressVisible = false; },
              setParams: function(params) { Object.assign(this, params); }
            },
            ready: function() {
              console.log("✅ Telegram WebApp Ready - User:", this.initDataUnsafe.user);
            },
            expand: function() { console.log("Telegram WebApp expand"); },
            close: function() { console.log("Telegram WebApp close"); },
            sendData: function(data) { console.log("Telegram WebApp sendData:", data); },
            openLink: function(url) { window.open(url, '_blank'); },
            openTelegramLink: function(url) { console.log("Open Telegram link:", url); },
            showPopup: function(params, callback) { alert(params.message); if (callback) callback(); },
            showAlert: function(message, callback) { alert(message); if (callback) callback(); },
            showConfirm: function(message, callback) { if (callback) callback(confirm(message)); },
            setHeaderColor: function(color) { this.headerColor = color; console.log("Header color set to:", color); },
            setBackgroundColor: function(color) { this.backgroundColor = color; console.log("Background color set to:", color); }
          };
          
          // Trigger ready immediately
          window.Telegram.WebApp.ready();
          
          console.log("✅ Telegram WebApp injected successfully!");
          console.log("User data:", JSON.stringify(window.Telegram.WebApp.initDataUnsafe.user));
        })();
      ''';

      await _controller.runJavaScript(script);
      print('✅ Telegram user data injected for user: ${user.username}');
    } catch (e) {
      print('❌ Error injecting Telegram user data: $e');
    }
  }

  Future<void> _injectABAData(AppState appState) async {
    try {
      final profile = appState.abaProfile;
      final account = appState.abaAccount;

      // Create ABA bridge with getProfile and getDefaultAccount handlers
      final script = '''
        (function() {
          console.log("=== Injecting ABA Bridge ===");
          
          // Create ABA bridge object
          window.ABA = window.ABA || {};
          
          // Store profile and account data
          window.ABA._profileData = {
            appId: "${profile.appId}",
            firstName: "${profile.firstName}",
            middleName: "${profile.middleName}",
            lastName: "${profile.lastName}",
            fullName: "${profile.fullName}",
            sex: "${profile.sex}",
            dobShort: "${profile.dobShort}",
            nationality: "${profile.nationality}",
            phone: "${profile.phone}",
            email: "${profile.email}",
            lang: "${profile.lang}",
            id: "${profile.id}",
            appVersion: "${profile.appVersion}",
            osVersion: "${profile.osVersion}",
            address: "${profile.address}",
            city: "${profile.city}",
            country: "${profile.country}",
            dobFull: "${profile.dobFull}",
            nidNumber: "${profile.nidNumber}",
            nidType: "${profile.nidType}",
            nidExpiryDate: "${profile.nidExpiryDate}",
            nidDoc: "${profile.nidDoc}",
            occupation: "${profile.occupation}",
            addrCode: "${profile.addrCode}",
            secret_key: "${profile.secretKey}"
          };
          
          window.ABA._accountData = {
            accountName: "${account.accountName}",
            accountNumber: "${account.accountNumber}",
            currency: "${account.currency}"
          };
          
          // getProfile handler
          window.ABA.getProfile = function(callback) {
            console.log("✅ ABA getProfile called");
            if (typeof callback === 'function') {
              callback(window.ABA._profileData);
            }
            return window.ABA._profileData;
          };
          
          // getDefaultAccount handler
          window.ABA.getDefaultAccount = function(callback) {
            console.log("✅ ABA getDefaultAccount called");
            const payload = {
              currency: "USD"
            };
            if (typeof callback === 'function') {
              callback(payload, window.ABA._accountData);
            }
            return window.ABA._accountData;
          };
          
          console.log("✅ ABA Bridge injected successfully!");
          console.log("Available methods:");
          console.log("  - window.ABA.getProfile(callback)");
          console.log("  - window.ABA.getDefaultAccount(callback)");
          console.log("Profile data:", JSON.stringify(window.ABA._profileData));
          console.log("Account data:", JSON.stringify(window.ABA._accountData));
        })();
      ''';

      await _controller.runJavaScript(script);
      print(
        '✅ ABA data injected for user: ${profile.firstName} ${profile.lastName}',
      );
    } catch (e) {
      print('❌ Error injecting ABA data: $e');
    }
  }

  Future<void> _handleBack(AppState appState) async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
    } else {
      final shouldExit = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              buttonPadding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              title: const Text('Leave Mini App?'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              backgroundColor: Colors.white,
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shadowColor: Colors.black.withOpacity(0.5),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'No',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    shadowColor: Colors.red.withOpacity(0.5),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yes Leave'),
                ),
              ],
            ),
      );

      if (shouldExit == true) {
        appState.resetToHome();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (!_isInitialized && appState.url != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeController();
          });
        }

        return Scaffold(
          appBar:
              appState.showHeader
                  ? AppBar(
                    titleSpacing: 0,
                    toolbarHeight: 45,
                    actions: [
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => appState.resetToHome(),
                      ),
                    ],
                    backgroundColor: appState.customColor,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => _handleBack(appState),
                    ),
                    title: Text(
                      appState.customTitle,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: 'Roboto',
                        letterSpacing: 0.3,
                      ),
                    ),
                  )
                  : null,
          body:
              _isInitialized
                  ? Stack(
                    children: [
                      SafeArea(child: WebViewWidget(controller: _controller)),
                      // Show close button when header is hidden
                      if (!appState.showHeader)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: SafeArea(
                            child: Material(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () async {
                                  final shouldClose = await showDialog<bool>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder:
                                        (context) => AlertDialog(
                                          buttonPadding:
                                              const EdgeInsets.fromLTRB(
                                                0,
                                                0,
                                                8,
                                                8,
                                              ),
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                24,
                                                20,
                                                24,
                                                0,
                                              ),
                                          title: const Text('Leave Mini App?'),
                                          content: const Text(
                                            'Are you sure you want to close this mini app?',
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          backgroundColor: Colors.white,
                                          actions: [
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: Colors.black,
                                                shadowColor: Colors.black
                                                    .withOpacity(0.5),
                                              ),
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(false),
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: Colors.red,
                                                shadowColor: Colors.red
                                                    .withOpacity(0.5),
                                              ),
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(true),
                                              child: const Text('Yes, Close'),
                                            ),
                                          ],
                                        ),
                                  );

                                  if (shouldClose == true) {
                                    appState.resetToHome();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                  : const Center(
                    child: CircularProgressIndicator(color: Colors.blueAccent),
                  ),
        );
      },
    );
  }
}
