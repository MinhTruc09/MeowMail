import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mewmail/services/mail_service.dart';
import 'package:mewmail/services/user_service.dart';
import 'package:mewmail/services/auth_service.dart';
import 'package:mewmail/widgets/theme.dart';

class CreateGroupDialog extends StatefulWidget {
  final VoidCallback? onGroupCreated;

  const CreateGroupDialog({super.key, this.onGroupCreated});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _subjectController = TextEditingController();
  final _emailController = TextEditingController();
  final List<String> _selectedEmails = [];
  List<String> _searchResults = [];
  bool _isLoading = false;
  bool _isCreating = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _searchEmails(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Please log in again');
      }

      final response = await UserService.searchMail(
        token: token,
        query: query.trim(),
      );

      if (response.status == 200 && response.data != null) {
        setState(() {
          _searchResults =
              response.data!
                  .where((email) => !_selectedEmails.contains(email))
                  .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  void _addEmail(String email) {
    if (!_selectedEmails.contains(email)) {
      setState(() {
        _selectedEmails.add(email);
        _emailController.clear();
        _searchResults = [];
      });
    }
  }

  void _removeEmail(String email) {
    setState(() {
      _selectedEmails.remove(email);
    });
  }

  Future<void> _createGroup() async {
    if (_subjectController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tiêu đề nhóm'),
          backgroundColor: AppTheme.primaryBlack,
        ),
      );
      return;
    }

    if (_selectedEmails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm ít nhất một email'),
          backgroundColor: AppTheme.primaryBlack,
        ),
      );
      return;
    }

    if (_selectedEmails.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nhóm cần ít nhất 2 thành viên'),
          backgroundColor: AppTheme.primaryBlack,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Please log in again');
      }

      final threadId = await MailService.createGroup(
        token: token,
        receiverEmails: _selectedEmails,
        subject: _subjectController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);

        if (threadId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tạo nhóm email thành công! Thread ID: $threadId'),
              backgroundColor: AppTheme.primaryYellow,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tạo nhóm email thành công!'),
              backgroundColor: AppTheme.primaryYellow,
            ),
          );
        }

        widget.onGroupCreated?.call();
      }
    } catch (e) {
      debugPrint('❌ Lỗi _createGroup: $e');

      if (mounted) {
        // If session expired, logout and redirect to login
        if (AuthService.shouldRedirectToLogin(e.toString())) {
          Navigator.pop(context); // Close dialog first
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phiên đăng nhập hết hạn, vui lòng đăng nhập lại'),
              backgroundColor: AppTheme.primaryYellow,
            ),
          );
          await AuthService.logout();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi tạo nhóm: $e'),
              backgroundColor: AppTheme.primaryBlack,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.group_add,
                  color: AppTheme.primaryBlack,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Tạo nhóm email',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlack,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Subject field
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Tiêu đề nhóm',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.primaryYellow),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Email search field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Thêm email thành viên',
                hintText: 'Nhập email để tìm kiếm...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.primaryYellow),
                ),
                suffixIcon:
                    _isLoading
                        ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                        : const Icon(Icons.search),
              ),
              onChanged: _searchEmails,
            ),
            const SizedBox(height: 8),

            // Search results
            if (_searchResults.isNotEmpty)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.primaryBlack.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final email = _searchResults[index];
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppTheme.primaryYellow,
                        child: Text(
                          email.isNotEmpty ? email[0].toUpperCase() : 'E',
                          style: const TextStyle(
                            color: AppTheme.primaryBlack,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(email, style: const TextStyle(fontSize: 14)),
                      trailing: IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        onPressed: () => _addEmail(email),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Selected emails
            const Text(
              'Thành viên đã chọn:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),

            Expanded(
              child:
                  _selectedEmails.isEmpty
                      ? Center(
                        child: Text(
                          'Chưa có thành viên nào',
                          style: TextStyle(
                            color: AppTheme.primaryBlack.withValues(alpha: 0.6),
                            fontSize: 14,
                            fontFamily: 'Borel',
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _selectedEmails.length,
                        itemBuilder: (context, index) {
                          final email = _selectedEmails[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 16,
                                backgroundColor: AppTheme.primaryYellow,
                                child: Text(
                                  email.isNotEmpty
                                      ? email[0].toUpperCase()
                                      : 'E',
                                  style: const TextStyle(
                                    color: AppTheme.primaryBlack,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                email,
                                style: const TextStyle(fontSize: 14),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: AppTheme.primaryBlack,
                                  size: 20,
                                ),
                                onPressed: () => _removeEmail(email),
                              ),
                            ),
                          );
                        },
                      ),
            ),

            const SizedBox(height: 16),

            // Create button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _createGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryYellow,
                  foregroundColor: AppTheme.primaryBlack,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    _isCreating
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryBlack,
                            ),
                          ),
                        )
                        : const Text(
                          'Tạo nhóm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
