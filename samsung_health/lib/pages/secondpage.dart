import 'package:flutter/material.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  tooltip: 'Back',
                  child: const Icon(Icons.arrow_back)),
            ),
          ],
        ),
      ),
    );
  }
}
