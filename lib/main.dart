import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/theme.dart';
import 'providers/jar_provider.dart';
import 'providers/theme_provider.dart';
import 'ui/screens/main_wrapper.dart';
import 'ui/screens/login_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JarProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const SavingsJarApp(),
    ),
  );
}

class SavingsJarApp extends StatelessWidget {
  const SavingsJarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Savings Jar',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            // Tell JarProvider to fetch data once logged in
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<JarProvider>(context, listen: false).fetchJars();
              Provider.of<JarProvider>(context, listen: false).fetchTransactions();
            });
            return const MainWrapper();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
