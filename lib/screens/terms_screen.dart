import 'package:flutter/material.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:mewmail/widgets/common/animated_widgets.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      appBar: AppBar(
        title: const Text(
          'Điều khoản dịch vụ',
          style: TextStyle(
            color: AppTheme.primaryWhite,
            fontFamily: 'Borel',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryBlack,
        foregroundColor: AppTheme.primaryWhite,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.responsivePadding(context, 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInAnimation(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryYellow.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryBlack,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Thông báo quan trọng',
                          style: TextStyle(
                            fontSize: AppTheme.responsiveWidth(context, 0.045),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlack,
                            fontFamily: 'Borel',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bằng việc sử dụng ứng dụng MewMail, bạn đồng ý với các điều khoản và điều kiện được nêu dưới đây.',
                      style: TextStyle(
                        fontSize: AppTheme.responsiveWidth(context, 0.035),
                        color: AppTheme.primaryBlack,
                        height: 1.5,
                        fontFamily: 'Borel',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            SlideInAnimation(
              delay: const Duration(milliseconds: 200),
              child: _buildSection(
                context,
                '1. Giới thiệu',
                'MewMail là ứng dụng quản lý email được phát triển bởi Nguyễn Minh Trực, sinh viên Đại học Giao thông Vận tải TP.HCM. Ứng dụng này được tạo ra với mục đích học tập và nghiên cứu.',
              ),
            ),

            SlideInAnimation(
              delay: const Duration(milliseconds: 400),
              child: _buildSection(
                context,
                '2. Phạm vi sử dụng',
                'Ứng dụng MewMail được cung cấp miễn phí cho mục đích học tập và sử dụng cá nhân. Người dùng có thể sử dụng ứng dụng để gửi, nhận và quản lý email một cách thuận tiện.',
              ),
            ),

            SlideInAnimation(
              delay: const Duration(milliseconds: 600),
              child: _buildSection(
                context,
                '3. Quyền và trách nhiệm của người dùng',
                '• Người dùng có trách nhiệm bảo mật thông tin đăng nhập của mình\n'
                    '• Không sử dụng ứng dụng cho các mục đích bất hợp pháp\n'
                    '• Tôn trọng quyền riêng tư của người khác\n'
                    '• Không gửi spam hoặc nội dung có hại',
              ),
            ),

            SlideInAnimation(
              delay: const Duration(milliseconds: 800),
              child: _buildSection(
                context,
                '4. Bảo mật thông tin',
                'Chúng tôi cam kết bảo vệ thông tin cá nhân của người dùng. Mọi dữ liệu được mã hóa và lưu trữ an toàn. Chúng tôi không chia sẻ thông tin cá nhân với bên thứ ba mà không có sự đồng ý của người dùng.',
              ),
            ),

            SlideInAnimation(
              delay: const Duration(milliseconds: 1000),
              child: _buildSection(
                context,
                '5. Giới hạn trách nhiệm',
                'Ứng dụng MewMail được cung cấp "như hiện tại" mà không có bất kỳ bảo đảm nào. Chúng tôi không chịu trách nhiệm về bất kỳ thiệt hại nào có thể phát sinh từ việc sử dụng ứng dụng.',
              ),
            ),

            SlideInAnimation(
              delay: const Duration(milliseconds: 1200),
              child: _buildSection(
                context,
                '6. Thay đổi điều khoản',
                'Chúng tôi có quyền thay đổi các điều khoản này bất kỳ lúc nào. Người dùng sẽ được thông báo về các thay đổi quan trọng qua email hoặc thông báo trong ứng dụng.',
              ),
            ),

            SlideInAnimation(
              delay: const Duration(milliseconds: 1400),
              child: _buildSection(
                context,
                '7. Liên hệ',
                'Nếu bạn có bất kỳ câu hỏi nào về các điều khoản này, vui lòng liên hệ với chúng tôi qua:\n'
                    '• Email: 2251120392@ut.edu.vn\n'
                    '• SĐT: 0384548931',
              ),
            ),

            const SizedBox(height: 24),

            SlideInAnimation(
              delay: const Duration(milliseconds: 1600),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Điều khoản này có hiệu lực từ ngày 01/12/2024\n'
                  'Phiên bản: 1.0.0\n'
                  'Cập nhật lần cuối: Tháng 12, 2024',
                  style: TextStyle(
                    fontSize: AppTheme.responsiveWidth(context, 0.03),
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Borel',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppTheme.responsiveWidth(context, 0.04),
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlack,
              fontFamily: 'Borel',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: AppTheme.responsiveWidth(context, 0.035),
              color: AppTheme.primaryBlack,
              height: 1.6,
              fontFamily: 'Borel',
            ),
          ),
        ],
      ),
    );
  }
}
