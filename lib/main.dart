import 'package:flutter/material.dart';

void main() {
  runApp(MinhasAnotacoesApp());
}

class MinhasAnotacoesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minhas Anotações',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _searchInTitle = true;
  bool _searchInDescription = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minhas Anotações'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Nova anotação',
            onPressed: () {
              // Nova anotação
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: 'Configurações',
            onPressed: () {
              // Configurações
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Campo de pesquisa + popup de filtros
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
            // Lista de anotações (ainda vazia)
            Expanded(
              child: ListView.builder(
                itemCount: 0, // Ainda sem dados
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
    );
  }
}
