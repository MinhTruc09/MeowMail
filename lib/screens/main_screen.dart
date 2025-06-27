import 'package:flutter/material.dart';
import 'package:mewmail/screens/home_screen.dart';
import 'package:mewmail/screens/search_screen.dart';
import 'package:mewmail/screens/history_screen.dart';
import 'package:mewmail/screens/settings_screen.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:mewmail/widgets/common/custom_bottom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(), // ⬅ vẫn dùng màn hình cũ
    SearchScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // KHÔNG có AppBar ở đây → AppBar từng tab tự quản lý
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
