import 'dart:io';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery/app.dart';

import 'package:photo_manager/photo_manager.dart';

void main() {
  runApp(const MyApp());
}

Future<void> _requestAssets() async {
  final PermissionState ps = await PhotoManager.requestPermissionExtend();

  if (!ps.isAuth) {
    log('Permission is not granted');
    exit(0);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    
    _requestAssets();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'Gallery',
      home: const App(),
    );
  }
}
