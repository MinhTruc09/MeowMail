import 'package:flutter/material.dart';
import 'package:mewmail/services/mail_service.dart';
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
  bool isLoading = true;

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
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onTapThread(Map thread) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MailThreadScreen(threadId: thread['threadId']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: height * 0.05,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm...',
              fillColor: Colors.yellow[700],
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: width * 0.04),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: SizedBox(
                width: width * 0.1,
                height: width * 0.1,
                child: const CircularProgressIndicator(strokeWidth: 3),
              ),
            )
          : inboxThreads.isEmpty
              ? Center(
                  child: Text(
                    'Chưa có tin nhắn',
                    style: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.w500),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: height * 0.01),
                  itemCount: inboxThreads.length,
                  separatorBuilder: (_, __) => Divider(height: height * 0.01),
                  itemBuilder: (context, index) => LayoutBuilder(
                    builder: (context, constraints) => MailListTile(
                      thread: inboxThreads[index],
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      onTap: () => _onTapThread(inboxThreads[index]),
                    ),
                  ),
                ),
    );
  }
}

class MailThreadScreen extends StatelessWidget {
  final int threadId;
  const MailThreadScreen({super.key, required this.threadId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết tin nhắn')),
      body: Center(child: Text('Thread ID: $threadId')),
    );
  }
}
