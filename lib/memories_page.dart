import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:assignment_one/database.dart'; // Import Memory from database.dart

class MemoriesPage extends StatelessWidget {
  final List<Memory> memories;

  const MemoriesPage({Key? key, required this.memories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memories'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: ListView.builder(
        itemCount: memories.length,
        itemBuilder: (context, index) {
          return MemoryCard(memory: memories[index]);
        },
      ),
    );
  }
}

class MemoryCard extends StatelessWidget {
  final Memory memory;

  const MemoryCard({Key? key, required this.memory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        children: [
          Image.file(File(memory.imagePath)),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(memory.city),
          ),
          SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: () async {
              await _shareMemory(memory);
            },
            child: Text('Share on WhatsApp'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareMemory(Memory memory) async {
    try {
      await FlutterShare.share(
        title: 'Memory from ${memory.city}',
        text: 'Check out this memory from ${memory.city}!',
        linkUrl: 'file://${memory.imagePath}', // Provide a link to the image file
      );
    } catch (e) {
      print('Error sharing memory: $e');
    }
  }
}
