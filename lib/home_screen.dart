import 'package:flutter/material.dart';

import 'models/note.dart';
import 'note_edit_screen.dart';
import 'services/preferences_service.dart';
import 'widgets/theme_drawer.dart';

class HomeScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const HomeScreen({
    Key? key,
    required this.themeMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> _notes = [];
  final _prefsService = PreferencesService();

  String _searchTerm = '';
  Set<String> _searchFields = {'title'};

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _loadSearchFields();
  }

  Future<void> _loadNotes() async {
    final notes = await _prefsService.loadNotes();
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _saveNotes() async {
    await _prefsService.saveNotes(_notes);
  }

  Future<void> _loadSearchFields() async {
    final fields = await _prefsService.loadSearchFields();
    setState(() {
      _searchFields = fields;
    });
  }

  Future<void> _saveSearchFields() async {
    await _prefsService.saveSearchFields(_searchFields);
  }

  void _onSearchChanged(String val) {
    setState(() {
      _searchTerm = val.toLowerCase();
    });
  }

  List<Note> get _filteredNotes {
    if (_searchTerm.isEmpty) return _notes;

    return _notes.where((note) {
      bool match = false;
      if (_searchFields.contains('title')) {
        match |= note.title.toLowerCase().contains(_searchTerm);
      }
      if (_searchFields.contains('description')) {
        match |= note.description.toLowerCase().contains(_searchTerm);
      }
      return match;
    }).toList();
  }

  Future<void> _navigateToAddNote() async {
    final newNote = await Navigator.of(
      context,
    ).push<Note>(MaterialPageRoute(builder: (_) => NoteEditScreen()));

    if (newNote != null) {
      setState(() {
        _notes.add(newNote);
      });
      await _saveNotes();
    }
  }

  Future<void> _navigateToEditNote(Note note) async {
    final updatedNote = await Navigator.of(
      context,
    ).push<Note>(MaterialPageRoute(builder: (_) => NoteEditScreen(note: note)));

    if (updatedNote != null && updatedNote.toDelete != true) {
      setState(() {
        final idx = _notes.indexWhere((n) => n.id == updatedNote.id);
        if (idx >= 0) _notes[idx] = updatedNote;
      });
      await _saveNotes();
    } else {
      await _deleteNote(note);
    }
  }

  Future<void> _deleteNote(Note note) async {
    setState(() {
      _notes.removeWhere((n) => n.id == note.id);
    });
    await _saveNotes();
  }

  void _showExitConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sair'),
        content: Text('Deseja realmente sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Não'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: Text('Sim'),
          ),
        ],
      ),
    );
  }

  void _onSearchFieldsChanged(String field, bool selected) async {
    setState(() {
      if (selected) {
        _searchFields.add(field);
      } else {
        _searchFields.remove(field);
      }
    });
    await _saveSearchFields();
  }

  String _truncate(String text, int maxLength) {
    return (text.length <= maxLength)
        ? text
        : '${text.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ThemeDrawer(
        currentTheme: widget.themeMode,
        onThemeSelected: widget.onThemeChanged,
        onExit: _showExitConfirmDialog,
      ),
      appBar: AppBar(
        title: Text('Minhas anotações'),
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Menu',
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Nova anotação',
            icon: Icon(Icons.add),
            onPressed: _navigateToAddNote,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Pesquisar',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.filter_list),
                  tooltip: 'Selecionar campos de pesquisa',
                  itemBuilder: (context) => [
                    CheckedPopupMenuItem(
                      value: 'title',
                      checked: _searchFields.contains('title'),
                      child: Text('Título'),
                    ),
                    CheckedPopupMenuItem(
                      value: 'description',
                      checked: _searchFields.contains('description'),
                      child: Text('Descrição'),
                    ),
                  ],
                  onSelected: (value) {
                    bool isSelected = _searchFields.contains(value);
                    _onSearchFieldsChanged(value, !isSelected);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredNotes.isEmpty
                ? Center(child: Text('Não há anotações'))
                : ListView.builder(
                    itemCount: _filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = _filteredNotes[index];
                      return ListTile(
                        title: Text(note.title),
                        subtitle: Text(
                          _truncate(note.description, 20),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _navigateToEditNote(note),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
