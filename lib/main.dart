import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MultiNotesApp());
}

class MultiNotesApp extends StatefulWidget {
  const MultiNotesApp({super.key});

  @override
  State<MultiNotesApp> createState() => _MultiNotesAppState();
}

class _MultiNotesAppState extends State<MultiNotesApp> {
  final _appProvider = AppProvider();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _appProvider.init().then((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return ChangeNotifierProvider.value(
      value: _appProvider,
      child: MaterialApp(
        title: 'MultiNotes',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
