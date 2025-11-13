import 'package:flutter/material.dart';
import 'package:mini_app_viewer/home_screen.dart';
import 'package:mini_app_viewer/app_state.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final appState = AppState();
        appState.loadHistory(); // Load history on app start
        return appState;
      },
      child: MaterialApp(
        title: 'Mini App Viewer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const HomeScreen(),
      ),
    );
  }
}
