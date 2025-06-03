import 'package:flutter/material.dart';

class ThemeDrawer extends StatelessWidget {
  final ThemeMode currentTheme;
  final ValueChanged<ThemeMode> onThemeSelected;
  final VoidCallback onExit;

  const ThemeDrawer({
    Key? key,
    required this.currentTheme,
    required this.onThemeSelected,
    required this.onExit,
  }) : super(key: key);

  Widget _buildThemeOption(BuildContext context, String title, ThemeMode mode) {
    // final selected = mode == currentTheme;
    return ExpansionTile(
      title: Text('Tema'),
      children: [
        RadioListTile<ThemeMode>(
          title: Text('Claro'),
          value: ThemeMode.light,
          groupValue: currentTheme,
          onChanged: (v) {
            if (v != null) onThemeSelected(v);
            Navigator.of(context).pop();
          },
        ),
        RadioListTile<ThemeMode>(
          title: Text('Escuro'),
          value: ThemeMode.dark,
          groupValue: currentTheme,
          onChanged: (v) {
            if (v != null) onThemeSelected(v);
            Navigator.of(context).pop();
          },
        ),
        RadioListTile<ThemeMode>(
          title: Text('Tema do sistema'),
          value: ThemeMode.system,
          groupValue: currentTheme,
          onChanged: (v) {
            if (v != null) onThemeSelected(v);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Text(
              'Menu',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
          _buildThemeOption(context, 'Tema', currentTheme),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Sair'),
            onTap: () {
              Navigator.of(context).pop();
              onExit();
            },
          ),
        ],
      ),
    );
  }
}
