import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.black),
        onPressed: () {},
      ),
      title: const TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm...',
          border: InputBorder.none,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {},
        ),
        const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.black,
          child: Text("A", style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}