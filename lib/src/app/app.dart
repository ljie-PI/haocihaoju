import 'package:flutter/material.dart';

import 'app_dependencies.dart';
import '../ui/screens/home_shell.dart';

class HaociHaojuApp extends StatefulWidget {
  const HaociHaojuApp({
    super.key,
    required this.dependencies,
  });

  final AppDependencies dependencies;

  @override
  State<HaociHaojuApp> createState() => _HaociHaojuAppState();
}

class _HaociHaojuAppState extends State<HaociHaojuApp> {
  late final Future<void> _setupFuture;

  @override
  void initState() {
    super.initState();
    _setupFuture = widget.dependencies.quoteRepository.initialize();
  }

  @override
  void dispose() {
    widget.dependencies.ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '好词好句',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF005A87)),
      ),
      home: FutureBuilder<void>(
        future: _setupFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return HomeShell(dependencies: widget.dependencies);
        },
      ),
    );
  }
}
