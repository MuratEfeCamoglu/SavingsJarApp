import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/theme.dart';
import 'providers/jar_provider.dart';
import 'ui/screens/main_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JarProvider()),
      ],
      child: const SavingsJarApp(),
    ),
  );
}

class SavingsJarApp extends StatelessWidget {
  const SavingsJarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Savings Jar',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const MainWrapper(),
    );
  }
}
