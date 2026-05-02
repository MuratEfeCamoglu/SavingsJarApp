import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/theme_provider.dart';
import 'home_screen.dart';
import 'create_jar_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({Key? key}) : super(key: key);

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final pages = [
      const HomeScreen(),
      const HistoryScreen(),
      // Pass callback: after jar created, jump back to Home (tab 0)
      CreateJarScreen(onJarCreated: () => _goToPage(0)),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        physics: const NeverScrollableScrollPhysics(),
        children: pages,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold);
            }
            return TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary, fontSize: 12);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _goToPage,
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          indicatorColor: AppTheme.tabActiveBg,
          height: 65,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined,
                  color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary),
              selectedIcon: const Icon(Icons.home, color: AppTheme.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined,
                  color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary),
              selectedIcon: const Icon(Icons.history, color: AppTheme.primary),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline,
                  color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary),
              selectedIcon: const Icon(Icons.add_circle, color: AppTheme.primary),
              label: 'New Jar',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined,
                  color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary),
              selectedIcon: const Icon(Icons.settings, color: AppTheme.primary),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
