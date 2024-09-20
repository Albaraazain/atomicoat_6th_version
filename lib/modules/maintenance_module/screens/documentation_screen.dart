// lib/screens/documentation_screen.dart
import 'package:flutter/material.dart';
import '../models/documentation.dart';
import '../providers/documentation_provider.dart';
import 'package:provider/provider.dart';

class DocumentationScreen extends StatefulWidget {
  @override
  _DocumentationScreenState createState() => _DocumentationScreenState();
}

class _DocumentationScreenState extends State<DocumentationScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text('Documentation'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Documentation',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<DocumentationProvider>(
              builder: (ctx, documentationProvider, _) {
                if (documentationProvider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }
                if (documentationProvider.documents.isEmpty) {
                  return Center(child: Text('No documents found.'));
                }
                List<Documentation> filteredDocs = documentationProvider.documents
                    .where((doc) => doc.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    doc.content.toLowerCase().contains(_searchQuery.toLowerCase()))
                    .toList();
                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (ctx, index) {
                    return _buildDocumentItem(filteredDocs[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add new document functionality
        },
        child: Icon(Icons.add),
        tooltip: 'Add new document',
      ),
    );
  }

  Widget _buildDocumentItem(Documentation document) {
    return Card(
      child: ListTile(
        title: Text(document.title),
        subtitle: Text(document.category),
        trailing: Text('Last updated: ${document.lastUpdated.toString().substring(0, 10)}'),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DocumentDetailScreen(document: document),
            ),
          );
        },
      ),
    );
  }
}

class DocumentDetailScreen extends StatelessWidget {
  final Documentation document;

  DocumentDetailScreen({required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.title),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${document.category}', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Last Updated: ${document.lastUpdated.toString().substring(0, 10)}'),
            SizedBox(height: 16),
            Text(document.content),
          ],
        ),
      ),
    );
  }
}