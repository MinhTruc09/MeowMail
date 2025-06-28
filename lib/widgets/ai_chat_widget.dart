import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mewmail/services/ai_service.dart';
import 'package:mewmail/models/ai/ai_response.dart';
import 'package:mewmail/widgets/theme.dart';

class AiChatWidget extends StatefulWidget {
  final Function(AiGenerateResponse) onAiGenerated;

  const AiChatWidget({super.key, required this.onAiGenerated});

  @override
  State<AiChatWidget> createState() => _AiChatWidgetState();
}

class _AiChatWidgetState extends State<AiChatWidget> {
  final _promptController = TextEditingController();
  bool _isGenerating = false;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generateContent() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập yêu cầu cho AI')),
      );
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception('Vui lòng đăng nhập lại');
      }

      final aiResponse = await AiService.generateMail(
        token: token,
        prompt: prompt,
      );

      widget.onAiGenerated(aiResponse);
      _promptController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ AI đã tạo nội dung thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tạo nội dung AI: $e')));
        if (e.toString().contains('Session expired') ||
            e.toString().contains('401') ||
            e.toString().contains('403')) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryYellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryYellow.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlack,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.smart_toy,
                  color: AppTheme.primaryWhite,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'AI Trợ lý soạn thư',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlack,
                  fontSize: 16,
                  fontFamily: 'Borel',
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.auto_awesome,
                color: AppTheme.primaryYellow,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Mô tả nội dung bạn muốn soạn, AI sẽ tự động tạo email hoàn chỉnh',
            style: TextStyle(
              color: AppTheme.primaryBlack.withValues(alpha: 0.6),
              fontSize: 12,
              fontFamily: 'Borel',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _promptController,
            decoration: InputDecoration(
              hintText:
                  'VD: Hãy viết cho tôi một mail nghỉ việc, mail cảm ơn khách hàng...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: AppTheme.primaryWhite,
              isDense: true,
              prefixIcon: const Icon(Icons.chat, color: AppTheme.primaryBlack),
            ),
            maxLines: 3,
            onFieldSubmitted: (_) => _generateContent(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateContent,
              icon:
                  _isGenerating
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primaryWhite,
                        ),
                      )
                      : const Icon(Icons.auto_awesome),
              label: Text(
                _isGenerating ? 'Đang tạo nội dung...' : 'Tạo nội dung với AI',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryYellow,
                foregroundColor: AppTheme.primaryBlack,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
