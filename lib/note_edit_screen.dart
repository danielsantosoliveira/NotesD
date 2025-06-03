import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'models/note.dart';

class NoteEditScreen extends StatefulWidget {
  final Note? note;

  const NoteEditScreen({Key? key, this.note}) : super(key: key);

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  late DateTime _createdAt;
  DateTime? _updatedAt;

  @override
  void initState() {
    super.initState();
    final note = widget.note;

    _titleController = TextEditingController(text: note?.title ?? '');
    _descriptionController = TextEditingController(
      text: note?.description ?? '',
    );
    _createdAt = note?.createdAt ?? DateTime.now();
    _updatedAt = note?.updatedAt;
  }

  void _saveNote() {
    if (_titleController.text.trim().isEmpty &&
        _descriptionController.text.trim().isEmpty) {
      // Não salva nota vazia
      Navigator.of(context).pop();
      return;
    }

    final isNew = widget.note == null;
    final now = DateTime.now();

    final note = Note(
      id: isNew ? Uuid().v4() : widget.note!.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      createdAt: _createdAt,
      updatedAt: isNew ? null : now,
    );

    Navigator.of(context).pop(note);
  }

  void _deleteNote() {
    final note = Note(
      id: widget.note!.id,
      title: "",
      description: "",
      createdAt: _createdAt,
      toDelete: true
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Deletar anotação'),
        content: Text('Deseja realmente deletar esta anotação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(
                context,
              ).pop(note);
            },
            child: Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCreationDate = _createdAt != null;
    final hasUpdatedDate = _updatedAt != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Nova anotação' : 'Editar anotação'),
        actions: [
          IconButton(
            tooltip: 'Salvar',
            icon: Icon(Icons.save),
            onPressed: _saveNote,
          ),
          if (widget.note != null)
            IconButton(
              tooltip: 'Deletar',
              icon: Icon(Icons.delete),
              onPressed: _deleteNote,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Título',
                border: UnderlineInputBorder(),
              ),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration.collapsed(
                        hintText: "Digite a descrição...",
                      ),
                      style: const TextStyle(fontSize: 16, height: 1.6),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (hasCreationDate)
                  Text(
                    'Criado: ${_createdAt.toLocal().toString().split('.')[0]}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                if (hasUpdatedDate)
                  Text(
                    'Última modificação: ${_updatedAt!.toLocal().toString().split('.')[0]}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
