import 'package:flutter/material.dart';
import 'package:mewmail/models/mail/inbox_thread.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<InboxThread> searchResults = [];
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    // TODO: Gọi API tìm kiếm
    setState(() {
      searchResults = []; // Giả lập kết quả tìm kiếm
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm email...',
            border: InputBorder.none,
          ),
          onChanged: _search,
        ),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final thread = searchResults[index];
          return ListTile(
            title: Text(thread.subject ?? 'Không có tiêu đề'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(thread.lastSenderEmail ?? 'Không có người gửi'),
                Text(thread.lastReceiverEmail ?? 'Không có người nhận'),
              ],
            ),
            onTap: () {
              // TODO: Xem chi tiết email
            },
          );
        },
      ),
    );
  }
}