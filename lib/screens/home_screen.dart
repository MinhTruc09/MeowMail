import 'package:flutter/material.dart';
import 'package:mewmail/services/mail_service.dart';
import 'package:mewmail/widgets/home_appbar.dart';
import 'package:mewmail/widgets/home_bottom_nav.dart';
import 'package:mewmail/widgets/mail_list_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List inboxThreads = [];
  String? token;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    if (token != null) {
      final data = await MailService.getInbox(token!);
      setState(() {
        inboxThreads = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: HomeAppBar(),
      ),
      body: inboxThreads.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
        itemCount: inboxThreads.length,
        separatorBuilder: (_, __) => const Divider(height: 0.5),
        itemBuilder: (context, index) => MailListTile(thread: inboxThreads[index]),
      ),
      bottomNavigationBar: const HomeBottomNav(),
    );
  }
}
