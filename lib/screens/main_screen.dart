import 'package:flutter/material.dart';
import 'package:mini_app_viewer/screens/home_screen.dart';
import 'package:mini_app_viewer/screens/settings_screen.dart';
import 'package:mini_app_viewer/screens/history_screen.dart';
import 'package:mini_app_viewer/app_state.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // Hide bottom nav when WebView is active
        final showBottomNav = appState.url == null;

        return Scaffold(
          body: _screens[_currentIndex],
          extendBody: true,
          bottomNavigationBar:
              showBottomNav
                  ? Theme(
                    data: Theme.of(context).copyWith(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: BottomNavigationBar(
                            currentIndex: _currentIndex,
                            onTap: (index) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                            selectedItemColor: Colors.blueAccent,
                            unselectedItemColor: Colors.grey.shade600,
                            selectedFontSize: 13,
                            unselectedFontSize: 12,
                            type: BottomNavigationBarType.fixed,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            iconSize: 24,
                            showSelectedLabels: true,
                            showUnselectedLabels: true,
                            enableFeedback: false,
                            useLegacyColorScheme: false,
                            items: const [
                              BottomNavigationBarItem(
                                icon: Icon(Icons.home_outlined),
                                activeIcon: Icon(Icons.home),
                                label: 'Home',
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.history_outlined),
                                activeIcon: Icon(Icons.history),
                                label: 'History',
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.settings_outlined),
                                activeIcon: Icon(Icons.settings),
                                label: 'Settings',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  : null,
        );
      },
    );
  }
}
