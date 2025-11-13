import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mini_app_viewer/app_state.dart';
import 'package:provider/provider.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final appState = Provider.of<AppState>(context, listen: false);

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (url) async {
                appState.setLoading(false);

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
              },
            ),
          )
          ..loadRequest(Uri.parse(appState.url!));
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }

  String _cleanTitle(String title) {
    return title.replaceAll(RegExp(r'^"|"$'), '').trim();
  }

  Future<void> _handleBack(AppState appState) async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
    } else {
      final shouldExit = await showDialog<bool>(
        context: context,
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
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            toolbarHeight: 45,
            actions: [
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
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
          ),
          body: SafeArea(child: WebViewWidget(controller: _controller)),
        );
      },
    );
  }
}
