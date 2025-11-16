import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mini_app_viewer/app_state.dart';
import 'package:provider/provider.dart';

class MiniAppModel {
  final String name;
  final String imagePath;

  MiniAppModel({required this.name, required this.imagePath});
}

class MiniAppGrid extends StatefulWidget {
  const MiniAppGrid({super.key});

  @override
  State<MiniAppGrid> createState() => _MiniAppGridState();
}

class _MiniAppGridState extends State<MiniAppGrid> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  final List<MiniAppModel> _miniApps = [
    MiniAppModel(name: 'Telegram', imagePath: 'assets/img/tg.webp'),
    MiniAppModel(name: 'ABA', imagePath: 'assets/img/aba.webp'),
    MiniAppModel(name: 'Acleda', imagePath: 'assets/img/ac.webp'),
    MiniAppModel(name: 'Wing', imagePath: 'assets/img/wing.webp'),
  ];

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null &&
        (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https'));
  }

  void _showMiniAppDialog(MiniAppModel app) {
    _urlController.clear();
    _titleController.clear();
    _colorController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<AppState>(
          builder: (context, appState, child) {
            return AlertDialog(
              title: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      app.imagePath,
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(app.name),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // URL input
                    TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        labelText: 'Mini App URL',
                        labelStyle: const TextStyle(color: Color(0xFF448AFF)),
                        hintText: 'https://example.com',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () async {
                              final data = await Clipboard.getData(
                                Clipboard.kTextPlain,
                              );
                              final pastedText = data?.text?.trim() ?? '';
                              if (pastedText.isNotEmpty) {
                                _urlController.text = pastedText;
                              }
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(26, 11, 96, 233),
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
                        suffixIconConstraints: const BoxConstraints(
                          minHeight: 32,
                          minWidth: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title input - only show when header is enabled
                    if (appState.showHeader) ...[
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'AppBar Title',
                          labelStyle: const TextStyle(color: Colors.blueAccent),
                          hintText: 'e.g. ${app.name}',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () async {
                                final data = await Clipboard.getData(
                                  Clipboard.kTextPlain,
                                );
                                final pastedText = data?.text?.trim() ?? '';
                                if (pastedText.isNotEmpty) {
                                  _titleController.text = pastedText;
                                }
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(26, 11, 96, 233),
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
                          suffixIconConstraints: const BoxConstraints(
                            minHeight: 32,
                            minWidth: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Color input
                      TextField(
                        controller: _colorController,
                        decoration: InputDecoration(
                          labelText: 'AppBar Color',
                          hintText: 'e.g. #RRGGBB',
                          labelStyle: const TextStyle(color: Colors.blueAccent),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () async {
                                final data = await Clipboard.getData(
                                  Clipboard.kTextPlain,
                                );
                                final pastedText = data?.text?.trim() ?? '';
                                if (pastedText.isNotEmpty) {
                                  _colorController.text = pastedText;
                                }
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(26, 11, 96, 233),
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
                          suffixIconConstraints: const BoxConstraints(
                            minHeight: 32,
                            minWidth: 32,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final url = _urlController.text.trim();
                    if (_isValidUrl(url)) {
                      appState.loadUrl(
                        url,
                        _titleController.text.trim(),
                        _colorController.text.trim(),
                        miniAppName: app.name,
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid URL'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Open'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1 / 0.9,
      ),
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: _miniApps.length,
      itemBuilder: (context, index) {
        final app = _miniApps[index];
        return InkWell(
          onTap: () => _showMiniAppDialog(app),
          borderRadius: BorderRadius.circular(25),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey.shade200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      app.imagePath,
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  app.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
