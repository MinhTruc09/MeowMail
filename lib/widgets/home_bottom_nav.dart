import 'package:flutter/material.dart';

class HomeBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  const HomeBottomNav({super.key, this.currentIndex = 0, this.onTap});

  @override
  State<HomeBottomNav> createState() => _HomeBottomNavState();
}

class _HomeBottomNavState extends State<HomeBottomNav> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (widget.onTap != null) widget.onTap!(index);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      backgroundColor: const Color(0xFFFFCC00),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Tìm kiếm"),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "Lịch sử"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Cài đặt"),
      ],
    );
  }
}