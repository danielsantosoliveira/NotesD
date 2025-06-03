import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final themeString = prefs.getString('app_theme') ?? 'system';

  ThemeMode themeMode = switch (themeString) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  runApp(MyApp(initialThemeMode: themeMode));
}

class MyApp extends StatefulWidget {
  final ThemeMode initialThemeMode;

  const MyApp({Key? key, required this.initialThemeMode}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  void updateTheme(ThemeMode newTheme) async {
    setState(() {
      _themeMode = newTheme;
    });

    final prefs = await SharedPreferences.getInstance();
    String themeString = 'system';
    if (newTheme == ThemeMode.light)
      themeString = 'light';
    else if (newTheme == ThemeMode.dark)
      themeString = 'dark';

    await prefs.setString('app_theme', themeString);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notas App',
      themeMode: _themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: HomeScreen(themeMode: _themeMode, onThemeChanged: updateTheme),
      debugShowCheckedModeBanner: false
    );
  }
}
