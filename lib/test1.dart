import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  // Store all available icons from Lucide
  final Map<String, IconData> _iconMap = {
    'search': LucideIcons.search,
    'package': LucideIcons.package,
    'truck': LucideIcons.truck,
    'home': LucideIcons.home,
    'settings': LucideIcons.settings,
    'user': LucideIcons.userCircle2,
    'bell': LucideIcons.bell,
    'heart': LucideIcons.heart,
    'star': LucideIcons.star,
    'camera': LucideIcons.camera,
    'messageCircle': LucideIcons.messageCircle,
    'checkCircle': LucideIcons.checkCircle,
    'cloud': LucideIcons.cloud,
    'lock': LucideIcons.lock,
    'wifi': LucideIcons.wifi,
    'music': LucideIcons.music,
    'arrowLeft': LucideIcons.arrowLeft,
    'arrowRight': LucideIcons.arrowRight,
    'arrowUp': LucideIcons.arrowUp,
    'arrowDown': LucideIcons.arrowDown,
    'trash': LucideIcons.trash,
    'folder': LucideIcons.folder,
    'bookmark': LucideIcons.bookmark,
    'clock': LucideIcons.clock,
    'play': LucideIcons.play,
    'pause': LucideIcons.pause,
    'stop': LucideIcons.stopCircle,
  };

  IconData _selectedIcon = LucideIcons.home;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Filter icons based on search query
    List<String> filteredIcons = _iconMap.keys
        .where((key) => key.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Icon Picker")),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Display selected icon
          Center(
            child: Icon(
              _selectedIcon,
              size: 100,
              color: Colors.blueAccent,
            ),
          ),

          const SizedBox(height: 20),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Search Icon",
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  print(filteredIcons);
                });
              },
            ),
          ),

          // List of filtered icons
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
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












// Container(
//                   color: Colors.red,
//                   width: 200,
//                   height: 300,
//                   padding: EdgeInsets.only(
//                     left: 10,
//                     right: 10
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         width: 300,
//                         color: Colors.green,
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.start, 
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             InkWell(
//                               onTap: () {
//                                 print("Admin tapped");
//                               },
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   border: Border(
//                                     bottom: BorderSide(
//                                       color: Colors.black,
//                                       width: 2.0, 
//                                     ),
//                                   ),
//                                 ),
//                                 child: Text(
//                                   'Admin',
//                                   style: TextStyle(
//                                     fontSize: 20,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             InkWell(
//                               child: Text('Admin'),
//                             ),
//                             InkWell(
//                               child: Text('Admin'),
//                             ),
//                             InkWell(
//                               child: Text('Admin'),
//                             ),
//                           ],
//                         ),
//                       )
                      
//                     ],
//                   ),
//                 )