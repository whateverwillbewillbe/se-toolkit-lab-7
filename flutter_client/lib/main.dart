import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/lms_service.dart';
import 'screens/home_screen.dart';
import 'screens/learners_screen.dart';
import 'screens/interactions_screen.dart';

void main() {
  runApp(const LmsApp());
}

class LmsApp extends StatelessWidget {
  const LmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LmsService(
            apiUrl: const String.fromEnvironment(
              'LMS_API_URL',
              defaultValue: 'http://10.0.2.2:42002',
            ),
            apiKey: const String.fromEnvironment(
              'LMS_API_KEY',
              defaultValue: 'my-secret-api-key',
            ),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'LMS Client',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            elevation: 4,
          ),
        ),
        home: const MainNavigationScreen(),
      ),
    );
  }
}

/// Main screen with bottom navigation bar.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const LearnersScreen(),
    const InteractionsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Labs',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Learners',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'Interactions',
          ),
        ],
      ),
    );
  }
}
