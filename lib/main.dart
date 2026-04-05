import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes/app_router.dart';
import 'firebase_options.dart'; 

// main: entry point of the app.
// Declared as `Future<void>` and `async` because we await asynchronous initialization (Firebase).
// A `Future` represents a value that becomes available later.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: TalkToRepairApp()));
}

// StatelessWidget: widget that does not hold mutable state. Its build only depends on constructor params.
class TalkToRepairApp extends StatelessWidget {
  const TalkToRepairApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'TalkToRepair',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 16,
          centerTitle: true,
        ),
        fontFamily: 'Roboto',
      ),
      routerConfig: appRouter,
    );
  }
}
