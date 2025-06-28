import 'package:flutter/material.dart';
import 'package:mewmail/widgets/ai_chat_widget.dart';
import 'package:mewmail/models/ai/ai_response.dart';
import 'package:mewmail/widgets/theme.dart';

class AiDemoScreen extends StatefulWidget {
  const AiDemoScreen({super.key});

  @override
  State<AiDemoScreen> createState() => _AiDemoScreenState();
}

class _AiDemoScreenState extends State<AiDemoScreen> {
  AiGenerateResponse? _lastResponse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Demo'),
        backgroundColor: AppTheme.primaryBlack,
        foregroundColor: AppTheme.primaryWhite,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AiChatWidget(
              onAiGenerated: (response) {
                setState(() {
                  _lastResponse = response;
                });
              },
            ),
            const SizedBox(height: 20),
            if (_lastResponse != null) ...[
              const Divider(),
              const Text(
                'Kết quả AI:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email người nhận:',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlack,
                          fontFamily: 'Borel',
                        ),
                      ),
                      Text(_lastResponse!.receiverEmail),
                      const SizedBox(height: 8),
                      Text(
                        'Tiêu đề:',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlack,
                          fontFamily: 'Borel',
                        ),
                      ),
                      Text(_lastResponse!.subject),
                      const SizedBox(height: 8),
                      Text(
                        'Nội dung:',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlack,
                          fontFamily: 'Borel',
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryYellow.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _lastResponse!.content,
                          style: const TextStyle(height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
