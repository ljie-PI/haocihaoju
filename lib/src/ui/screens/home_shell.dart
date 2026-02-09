import 'package:flutter/material.dart';

import '../../app/app_dependencies.dart';
import 'quotes_screen.dart';
import 'scan_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.dependencies,
  });

  final AppDependencies dependencies;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      ScanScreen(dependencies: widget.dependencies),
      QuotesScreen(repository: widget.dependencies.quoteRepository),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int value) {
          setState(() {
            _index = value;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner),
            label: '扫描',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: '摘录',
          ),
        ],
      ),
    );
  }
}
