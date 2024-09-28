import 'package:flutter/material.dart';
import 'package:gallery/app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gallery',
      home: const App(),
    );
  }
}
