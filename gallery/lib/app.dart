import 'package:flutter/material.dart';

import 'package:gallery/pages/albums.dart';
import 'package:gallery/pages/photos.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String currentPage = 'home';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      animationDuration: const Duration(milliseconds: 0),
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            PhotosPage(),
            AlbumsPage(),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          height: 60.0,
          child: TabBar(
            labelColor: Colors.white,
            overlayColor: WidgetStateProperty.all(Colors.grey.withOpacity(0.1)),
            splashBorderRadius: BorderRadius.circular(20.0),
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            indicatorPadding: const EdgeInsets.only(bottom: 10.0),
            dividerHeight: 0.0,
            indicator: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white,
                  width: 2.0, // Thickness of the underline
                ),
              ),
            ),
            tabs: <Widget>[
              Tab(
                text: 'Photos',
              ),
              Tab(
                text: 'Albums',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
