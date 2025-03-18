import 'package:flutter/material.dart';
import 'iconlist.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final Map<String, IconData> _iconMap = IconDictionary.icons;

  IconData _selectedIcon = IconDictionary.icons['home'] ?? Icons.home;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    List<String> filteredIcons = _iconMap.keys
        .where((key) => key.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Icon Picker")),
      body: Column(
        children: [
          const SizedBox(height: 20),

          Center(
            child: Icon(
              _selectedIcon,
              size: 100,
              color: Colors.blueAccent,
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Search Icon",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: filteredIcons.length,
              itemBuilder: (context, index) {
                String iconName = filteredIcons[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = _iconMap[iconName]!;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_iconMap[iconName], size: 40, color: Colors.black),
                      Text(iconName, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}