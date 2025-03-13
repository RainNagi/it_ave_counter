import 'package:cupertino_sidebar/cupertino_sidebar.dart';
// import 'package:example/pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show DefaultTabController;

class TabBarExample extends StatefulWidget {
  const TabBarExample({super.key});

  @override
  State<TabBarExample> createState() => _TabBarExampleState();
}

class _TabBarExampleState extends State<TabBarExample> {
  // A list of pages to be displayed as the tab content.
  final _pages = const [
    Text('Page 1'),
    Text('Page 2'),
    Text('Page 3'),
    Text('Page 4'),
    Text('Page 5'),
  ];

  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // We use a Stack to display the tab bar in front of the tab content.
      child: Stack(
        children: [
          Center(
            child: CupertinoTabTransitionBuilder(
              child: _pages.elementAt(_selectedIndex),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              // [CupertinoFloatingTabBar] takes the nearest [DefaultTabController] as its controller.
              // Alternately you can pass the controller explicitly.
              child: DefaultTabController(
                length: 5,
                child: Builder(
                  builder: (context) {
                    return CupertinoFloatingTabBar(
                      // Use a material instead of a static color. This creates a blur effect behind the bar.
                      isVibrant: true,
                      onDestinationSelected: (value) {
                        // Update the selected index.
                        setState(() {
                          _selectedIndex = value;
                        });
                      },
                      // A list of tabs to be displayed as the tab bar.
                      tabs: const [
                        CupertinoFloatingTab(
                          child: Text('Today'),
                        ),
                        CupertinoFloatingTab(
                          child: Text('Games'),
                        ),
                        CupertinoFloatingTab(
                          child: Text('Apps'),
                        ),
                        CupertinoFloatingTab(
                          child: Text('Arcade'),
                        ),
                        CupertinoFloatingTab.icon(
                          icon: Icon(CupertinoIcons.search),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}