import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

void main() {
  runApp(MinhasAnotacoesApp());
}

class MinhasAnotacoesApp extends StatefulWidget {
  @override
  _MinhasAnotacoesAppState createState() => _MinhasAnotacoesAppState();
}

class _MinhasAnotacoesAppState extends State<MinhasAnotacoesApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('themeMode') ?? 'system';
    setState(() {
      if (themeString == 'light') _themeMode = ThemeMode.light;
      else if (themeString == 'dark') _themeMode = ThemeMode.dark;
      else _themeMode = ThemeMode.system;
    });
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'themeMode',
      mode == ThemeMode.light ? 'light' : mode == ThemeMode.dark ? 'dark' : 'system',
    );
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minhas Anotações',
      themeMode: _themeMode,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: HomePage(setThemeMode: _setThemeMode, currentThemeMode: _themeMode),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;
  final ThemeMode currentThemeMode;

  HomePage({required this.setThemeMode, required this.currentThemeMode});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _searchInTitle = true;
  bool _searchInDescription = true;
  bool _isThemeExpanded = false;

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar saída'),
        content: Text('Você realmente deseja sair do aplicativo?'),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Sair'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          bool shouldExit = await _onWillPop();
          if (shouldExit) exit(0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Minhas Anotações'),
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              tooltip: 'Nova anotação',
              onPressed: () {
                // TODO: Implementar criação de nova anotação
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ExpansionTile(
                leading: Icon(Icons.brightness_6),
                title: Text('Tema'),
                initiallyExpanded: _isThemeExpanded,
                onExpansionChanged: (expanded) {
                  setState(() => _isThemeExpanded = expanded);
                },
                children: [
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    groupValue: widget.currentThemeMode,
                    title: Text('Claro'),
                    secondary: Icon(Icons.wb_sunny_outlined),
                    onChanged: (mode) {
                      Navigator.pop(context);
                      widget.setThemeMode(mode!);
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    groupValue: widget.currentThemeMode,
                    title: Text('Escuro'),
                    secondary: Icon(Icons.nightlight_round),
                    onChanged: (mode) {
                      Navigator.pop(context);
                      widget.setThemeMode(mode!);
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.system,
                    groupValue: widget.currentThemeMode,
                    title: Text('Sistema'),
                    secondary: Icon(Icons.settings_brightness),
                    onChanged: (mode) {
                      Navigator.pop(context);
                      widget.setThemeMode(mode!);
                    },
                  ),
                ],
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Sair do aplicativo'),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Confirmar saída'),
                      content: Text('Você realmente deseja sair do aplicativo?'),
                      actions: [
                        TextButton(
                          child: Text('Cancelar'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: Text('Sair'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            exit(0);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Pesquisar',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  PopupMenuButton<String>(
                    tooltip: 'Selecionar campos de pesquisa',
                    icon: Icon(Icons.filter_list),
                    onSelected: (String value) {
                      setState(() {
                        if (value == 'Título') _searchInTitle = !_searchInTitle;
                        if (value == 'Descrição') _searchInDescription = !_searchInDescription;
                      });
                    },
                    itemBuilder: (BuildContext context) => [
                      CheckedPopupMenuItem(
                        value: 'Título',
                        checked: _searchInTitle,
                        child: Text('Título'),
                      ),
                      CheckedPopupMenuItem(
                        value: 'Descrição',
                        checked: _searchInDescription,
                        child: Text('Descrição'),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 0,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Anotação ${index + 1}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
