import 'package:asset_icon/asset_icon.dart';
import 'package:flutter/material.dart';

import 'generated/icons.g.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        iconTheme: const IconThemeData(
          color: Colors.red,
          size: 150,
          opacity: 0.4,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AssetIcon(
            iconName: AssetIcons.star,
            color: Colors.green,
            opacity: 0.7,
          ),
          AssetIcon(
            iconName: AssetIcons.cart,
          ),
        ],
      ),
    );
  }
}
