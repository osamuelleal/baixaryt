import 'package:flutter/material.dart';

import 'pages/home_page.dart';

void main() => runApp(const BaixarYtApp());

class BaixarYtApp extends StatelessWidget {
  const BaixarYtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BaixarYT',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(colorSchemeSeed: Colors.red),
      darkTheme: ThemeData(colorSchemeSeed: Colors.red, brightness: Brightness.dark),
      home: const HomePage(),
    );
  }
}
