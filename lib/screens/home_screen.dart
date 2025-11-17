import 'package:flutter/material.dart';
import 'package:mini_app_viewer/web_viewer.dart';
import 'package:mini_app_viewer/app_state.dart';
import 'package:mini_app_viewer/widgets/mini_app_grid.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                    bottomOpacity: 0,
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(0.4),
                      child: Container(
                        color: Colors.grey.shade200,
                        height: 0.4,
                      ),
                    ),
                  )
                  : null,
          backgroundColor: Colors.white,
          body:
              appState.url == null
                  ? SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          Image.asset(
                            'assets/img/mini_app_banner.png',
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 30),

                          // Text(
                          //   'Select Mini App',
                          //   style: TextStyle(
                          //     fontSize: 20,
                          //     fontWeight: FontWeight.w600,
                          //     color: Colors.grey.shade800,
                          //   ),
                          //   textAlign: TextAlign.center,
                          // ),
                          // const SizedBox(height: 20),

                          // Grid of Mini Apps
                          const Expanded(child: MiniAppGrid()),
                        ],
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
