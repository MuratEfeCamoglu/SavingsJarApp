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
    // Enable offline persistence for faster reads when reconnecting
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
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
    // Use Selector so only theme changes trigger a rebuild here
    return Selector<ThemeProvider, ThemeMode>(
      selector: (_, p) => p.themeMode,
      builder: (context, themeMode, _) => MaterialApp(
        title: 'Savings Jar',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        home: const _AuthGate(),
      ),
    );
  }
}

/// Separate StatefulWidget so auth state changes don't rebuild MaterialApp.
class _AuthGate extends StatefulWidget {
  const _AuthGate({Key? key}) : super(key: key);

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  String? _lastUid; // Track UID to avoid re-subscribing on same user

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;

        if (user != null) {
          // Only fetch when UID actually changes (login, not every rebuild)
          if (user.uid != _lastUid) {
            _lastUid = user.uid;
            // Schedule after frame to avoid calling setState during build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final provider =
                  Provider.of<JarProvider>(context, listen: false);
              provider.fetchJars();
              provider.fetchTransactions();
            });
          }
          return const MainWrapper();
        }

        // User logged out — reset tracking
        _lastUid = null;
        return const LoginScreen();
      },
    );
  }
}
