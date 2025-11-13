import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mini_app_viewer/web_viewer.dart';
import 'package:mini_app_viewer/app_state.dart';
import 'package:mini_app_viewer/history_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null &&
        (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https'));
  }

  @override
  void initState() {
    super.initState();
    _urlController.addListener(_onUrlChanged);
  }

  @override
  void dispose() {
    _urlController.removeListener(_onUrlChanged);
    _urlController.dispose();
    _titleController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _onUrlChanged() {
    final input = _urlController.text.trim();
    if (_isValidUrl(input)) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.loadUrl(
        input,
        _titleController.text.trim(),
        _colorController.text.trim(),
      );
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final pastedText = data?.text?.trim() ?? '';
    if (pastedText.isNotEmpty) {
      _urlController.text = pastedText;
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Clipboard is empty")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar:
              appState.url == null
                  ? AppBar(
                    title: Text(
                      'Mini App Viewer'.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        fontFamily: 'Roboto',
                        letterSpacing: 0.3,
                      ),
                    ),
                    centerTitle: true,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    actions: [
                      Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.history,
                            color: Color(0xFF448AFF),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HistoryScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(0.5),
                      child: Container(
                        color: Colors.grey.shade200,
                        height: 0.5,
                      ),
                    ),
                  )
                  : null,
          backgroundColor: Colors.white,
          body:
              appState.url == null
                  ? SafeArea(
                    child: LayoutBuilder(
                      builder:
                          (context, constraints) => SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: IntrinsicHeight(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 20),
                                    Image.asset(
                                      'assets/img/mini_app_banner.png',
                                      width: double.infinity,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(height: 40),

                                    // Title input
                                    TextField(
                                      controller: _titleController,
                                      decoration: InputDecoration(
                                        labelText: 'AppBar Title',
                                        labelStyle: const TextStyle(
                                          color: Colors.blueAccent,
                                        ),
                                        hintText: 'e.g. My Mini App',
                                        filled: true,
                                        fillColor: Colors.grey.shade100,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Color input
                                    TextField(
                                      controller: _colorController,
                                      decoration: InputDecoration(
                                        labelText: 'AppBar Color',
                                        hintText: 'e.g. #RRGGBB',
                                        labelStyle: const TextStyle(
                                          color: Colors.blueAccent,
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade100,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // URL input
                                    TextField(
                                      controller: _urlController,
                                      decoration: InputDecoration(
                                        labelText: 'Mini App URL',
                                        labelStyle: const TextStyle(
                                          color: Color(0xFF448AFF),
                                        ),
                                        hintText: 'https://example.com',
                                        filled: true,
                                        fillColor: Colors.grey.shade100,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 10,
                                            ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          child: GestureDetector(
                                            onTap: _pasteFromClipboard,
                                            child: Container(
                                              width: 28,
                                              height: 28,
                                              decoration: const BoxDecoration(
                                                color: Color.fromARGB(
                                                  26,
                                                  11,
                                                  96,
                                                  233,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.paste,
                                                color: Colors.blueAccent,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        suffixIconConstraints:
                                            const BoxConstraints(
                                              minHeight: 32,
                                              minWidth: 32,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 50),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    ),
                  )
                  : Stack(
                    children: [
                      const WebViewPage(),
                      if (appState.isLoading)
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.white,
                          child: const Center(
                            child: CircularProgressIndicator(
                              value: null,
                              strokeWidth: 2,
                              color: Colors.blueAccent,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                    ],
                  ),
        );
      },
    );
  }
}
