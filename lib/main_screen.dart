import 'package:flutter/material.dart';
import 'package:mini_app_viewer/home_screen.dart';
import 'package:mini_app_viewer/screens/settings_screen.dart';
import 'package:mini_app_viewer/app_state.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [const HomeScreen(), const SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // Hide bottom nav when WebView is active
        final showBottomNav = appState.url == null;

        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar:
              showBottomNav
                  ? BottomNavigationBar(
                    currentIndex: _currentIndex,
                    onTap: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    selectedItemColor: Colors.blueAccent,
                    unselectedItemColor: Colors.grey.shade600,
                    selectedFontSize: 14,
                    unselectedFontSize: 12,
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Colors.white,
                    elevation: 8,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined),
                        activeIcon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.settings_outlined),
                        activeIcon: Icon(Icons.settings),
                        label: 'Settings',
                      ),
                    ],
                  )
                  : null,
        );
      },
    );
  }
}
