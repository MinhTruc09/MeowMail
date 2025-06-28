import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mewmail/services/mail_service.dart';
import 'package:mewmail/services/file_service.dart';
import 'package:mewmail/services/user_service.dart';
import 'package:mewmail/services/ai_service.dart';
import 'package:mewmail/widgets/register/register_validator.dart';
import 'package:mewmail/widgets/theme.dart';

class SendMailDialog extends StatefulWidget {
  final VoidCallback onSend;
  const SendMailDialog({super.key, required this.onSend});

  @override
  State<SendMailDialog> createState() => _SendMailDialogState();
}

class _SendMailDialogState extends State<SendMailDialog> {
  final _formKey = GlobalKey<FormState>();
  final _receiverController = TextEditingController();
  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSending = false;
  String? _attachmentPath;
  String? _attachmentName;

  // Email suggestion variables
  List<String> _emailSuggestions = [];
  bool _isSearching = false;
  bool _showSuggestions = false;
  Timer? _debounceTimer;

  // AI suggestion variables
  bool _isGeneratingAI = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _receiverController.dispose();
    _subjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _searchEmails(String query) async {
    if (query.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _emailSuggestions = [];
          _showSuggestions = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isSearching = true;
        _showSuggestions = true;
      });
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        if (mounted) {
          setState(() {
            _emailSuggestions = [];
            _isSearching = false;
            _showSuggestions = false;
          });
        }
        return;
      }

      final response = await UserService.searchMail(
        token: token,
        query: query.trim(),
      );

      if (mounted) {
        if (response.status == 200 && response.data != null) {
          setState(() {
            _emailSuggestions = response.data!;
            _isSearching = false;
          });
        } else {
          setState(() {
            _emailSuggestions = [];
            _isSearching = false;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Lỗi search email: $e');
      if (mounted) {
        setState(() {
          _emailSuggestions = [];
          _isSearching = false;
          _showSuggestions = false;
        });
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      // Show dialog to choose between camera and gallery
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Chọn ảnh'),
              content: const Text('Chọn nguồn ảnh:'),
              actions: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Thư viện'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
              ],
            ),
      );

      if (source != null) {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (image != null && mounted) {
          setState(() {
            _attachmentPath = image.path;
            _attachmentName = image.name;
          });
          debugPrint('✅ Đã chọn ảnh: ${image.name} (${image.path})');
        }
      }
    } catch (e) {
      debugPrint('❌ Lỗi chọn ảnh: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi chọn ảnh: $e')));
      }
    }
  }

  void _removeAttachment() {
    setState(() {
      _attachmentPath = null;
      _attachmentName = null;
    });
  }

  Future<void> _generateAIContent() async {
    if (mounted) {
      setState(() => _isGeneratingAI = true);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception('Vui lòng đăng nhập lại');
      }

      // Create prompt based on current inputs
      String prompt = 'Hãy giúp tôi soạn email';

      final receiver = _receiverController.text.trim();
      final subject = _subjectController.text.trim();

      if (receiver.isNotEmpty) {
        prompt += ' gửi cho $receiver';
      }

      if (subject.isNotEmpty) {
        prompt += ' với tiêu đề "$subject"';
      }

      prompt += '. Hãy viết nội dung email một cách chuyên nghiệp và lịch sự.';

      final response = await AiService.generateAiMail(
        token: token,
        prompt: prompt,
      );

      if (mounted && response.status == 200 && response.data != null) {
        // Assuming the AI response has content field
        final aiContent = response.data!.content ?? '';
        if (aiContent.isNotEmpty) {
          setState(() {
            _contentController.text = aiContent;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✨ Đã tạo nội dung email bằng AI'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Lỗi AI: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tạo nội dung AI: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingAI = false);
      }
    }
  }

  Future<void> _sendMail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception('Vui lòng đăng nhập lại');
      }

      String? fileUrl;
      if (_attachmentPath != null) {
        // Upload file first
        fileUrl = await FileService.uploadFile(
          token: token,
          filePath: _attachmentPath!,
        );
      }

      await MailService.sendMail(
        token: token,
        receiver: _receiverController.text.trim(),
        subject: _subjectController.text.trim(),
        content: _contentController.text.trim(),
        filePath: fileUrl, // Pass the uploaded file URL
      );
      debugPrint('✅ Gửi mail thành công');
      if (mounted) {
        Navigator.pop(context);
        widget.onSend();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi gửi mail: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.1,
      ),
      child: Container(
        width: screenWidth * 0.9,
        height: screenHeight * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Soạn thư',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _receiverController,
                            decoration: InputDecoration(
                              labelText: 'Email người nhận',
                              hintText: 'example@email.com',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.primaryYellow,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              suffixIcon:
                                  _isSearching
                                      ? const Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppTheme.primaryYellow,
                                                ),
                                          ),
                                        ),
                                      )
                                      : const Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: validateEmail,
                            onChanged: (value) {
                              // Cancel previous timer
                              _debounceTimer?.cancel();

                              // Start new timer
                              _debounceTimer = Timer(
                                const Duration(milliseconds: 500),
                                () {
                                  _searchEmails(value);
                                },
                              );
                            },
                          ),
                          // Email suggestions dropdown
                          if (_showSuggestions && _emailSuggestions.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              constraints: const BoxConstraints(maxHeight: 150),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _emailSuggestions.length,
                                itemBuilder: (context, index) {
                                  final email = _emailSuggestions[index];
                                  return ListTile(
                                    dense: true,
                                    title: Text(email),
                                    onTap: () {
                                      _receiverController.text = email;
                                      setState(() {
                                        _showSuggestions = false;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _subjectController,
                        decoration: InputDecoration(
                          labelText: 'Tiêu đề',
                          hintText: 'Nhập tiêu đề email...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryYellow,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          prefixIcon: const Icon(Icons.subject_outlined),
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                      ),
                      const SizedBox(height: 20),
                      // Content field with AI button
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Nội dung',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed:
                                    _isGeneratingAI ? null : _generateAIContent,
                                icon:
                                    _isGeneratingAI
                                        ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Icon(
                                          Icons.auto_awesome,
                                          size: 16,
                                        ),
                                label: Text(
                                  _isGeneratingAI ? 'Đang tạo...' : 'AI',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryYellow,
                                  side: const BorderSide(
                                    color: AppTheme.primaryYellow,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  minimumSize: Size.zero,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _contentController,
                            decoration: InputDecoration(
                              hintText:
                                  'Nhập nội dung email hoặc nhấn AI để tạo tự động...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.primaryYellow,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 5,
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? 'Vui lòng nhập nội dung'
                                        : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Attachment section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Đính kèm ảnh',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _pickFile,
                                icon: const Icon(Icons.photo_camera),
                                label: const Text('Chọn ảnh từ thiết bị'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryYellow,
                                  side: const BorderSide(
                                    color: AppTheme.primaryYellow,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            // Show selected attachment
                            if (_attachmentName != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryYellow.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.primaryYellow.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.attach_file, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _attachmentName!,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _removeAttachment,
                                      icon: const Icon(Icons.close, size: 16),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Actions
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isSending ? null : _sendMail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    foregroundColor: AppTheme.primaryBlack,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child:
                      _isSending
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
                          : const Text('Gửi'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
