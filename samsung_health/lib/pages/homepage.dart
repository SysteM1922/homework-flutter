import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:samsung_health/pages/secondpage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: <Widget>[
                const SliverAppBar(
                  backgroundColor: Colors.black,
                  floating: false,
                  pinned: true,
                  snap: false,
                  expandedHeight: 300.0,
                  title: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      'SAMSUNG Health',
                      style: TextStyle(color: Colors.white, fontSize: 32.0),
                    ),
                  ),
                ),
                SliverList(
                    delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Container(
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(33, 33, 33, 70),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                          ),
                          child: ListTile(
                            title: Text('Item $index'),
                            textColor: Colors.white,
                          ),
                        ),
                        ),
                      ],
                    );
                  },
                  childCount: 30,
                )),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {},
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  log('Navigating to Second Page');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const SecondPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
