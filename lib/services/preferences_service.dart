import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/note.dart';

class PreferencesService {
  static const _notesKey = 'notes';
  static const _searchFieldsKey = 'search_fields';

  Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString(_notesKey);
    if (notesString == null) return [];
    final List<dynamic> jsonList = jsonDecode(notesString);
    return jsonList.map((e) => Note.fromJson(e)).toList();
  }

  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(notes.map((e) => e.toJson()).toList());
    await prefs.setString(_notesKey, jsonString);
  }

  Future<Set<String>> loadSearchFields() async {
    final prefs = await SharedPreferences.getInstance();
    final fields = prefs.getStringList(_searchFieldsKey);
    if (fields == null || fields.isEmpty) {
      // Default é título
      return {'title'};
    }
    return fields.toSet();
  }

  Future<void> saveSearchFields(Set<String> fields) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_searchFieldsKey, fields.toList());
  }
}
