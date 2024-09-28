import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:gallery/pages/homepage.dart';
import 'package:gallery/pages/secondpage.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String _currentPage = "home";

    void checkActivePage(BuildContext context) {
      if (ModalRoute.of(context)!.settings.name == '/') {
        _currentPage = 'home';
      } else if (ModalRoute.of(context)!.settings.name == '/secondpage') {
        _currentPage = 'secondpage';
      }
    }

    checkActivePage(context);

    return BottomAppBar(
      color: Colors.black,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextButton(
              onPressed: () {
                log('Navigating to Home Page');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const MyHomePage(),
                  ),
                );
              },
              child: Container(
                decoration: _currentPage == 'home'
                    ? BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 2.0, // Thickness of the underline
                          ),
                        ),
                      )
                    : null,
                child: Text(
                  'Home',
                  style: TextStyle(
                    fontSize: 18.0,
                    decoration: _currentPage == 'home'
                        ? TextDecoration.none
                        : TextDecoration.none,
                    color: _currentPage == 'home'
                        ? Colors.white
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () {
                log('Navigating to Second Page');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const SecondPage(),
                  ),
                );
              },
              child: Container(
                decoration: _currentPage == 'secondpage'
                    ? BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 2.0, // Thickness of the underline
                          ),
                        ),
                      )
                    : null,
                child: Text(
                  'Second Page',
                  style: TextStyle(
                    fontSize: 18.0,
                    decoration: _currentPage == 'secondpage'
                        ? TextDecoration.none
                        : TextDecoration.none,
                    color: _currentPage == 'secondpage'
                        ? Colors.white
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
