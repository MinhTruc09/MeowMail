import 'package:flutter/material.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:mewmail/widgets/common/animated_widgets.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      appBar: AppBar(
        title: const Text(
          'Chính sách bảo mật',
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
                          Icons.security,
                          color: AppTheme.primaryBlack,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Cam kết bảo mật',
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
                      'Chúng tôi cam kết bảo vệ quyền riêng tư và thông tin cá nhân của bạn khi sử dụng ứng dụng MewMail.',
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
                '1. Thông tin chúng tôi thu thập',
                '• Thông tin đăng ký: Email, họ tên, số điện thoại\n'
                    '• Thông tin email: Nội dung email, danh sách liên hệ\n'
                    '• Thông tin thiết bị: Loại thiết bị, hệ điều hành\n'
                    '• Thông tin sử dụng: Thời gian truy cập, tính năng sử dụng',
              ),
            ),

            SlideInAnimation(
              delay: const Duration(milliseconds: 400),
              child: _buildSection(
                context,
                '2. Mục đích sử dụng thông tin',
                '• Cung cấp và cải thiện dịch vụ email\n'
                    '• Xác thực và bảo mật tài khoản\n'
                    '• Hỗ trợ khách hàng khi cần thiết\n'
                    '• Phân tích và cải thiện hiệu suất ứng dụng\n'
                    '• Tuân thủ các yêu cầu pháp lý',
              ),
            ),

            SlideInAnimation(
              delay: const Duration(milliseconds: 600),
              child: _buildSection(
                context,
                '3. Bảo mật thông tin',
                'Chúng tôi áp dụng các biện pháp bảo mật tiên tiến:\n'
                    '• Mã hóa dữ liệu SSL/TLS\n'
                    '• Xác thực hai yếu tố (2FA)\n'
                    '• Kiểm soát truy cập nghiêm ngặt\n'
                    '• Sao lưu dữ liệu định kỳ\n'
                    '• Giám sát bảo mật 24/7',
              ),
            ),

            SlideInAnimation(
              delay: const Duration(milliseconds: 800),
              child: _buildSection(
                context,
                '4. Chia sẻ thông tin',
                'Chúng tôi KHÔNG chia sẻ thông tin cá nhân của bạn với bên thứ ba, trừ khi:\n'
                    '• Có sự đồng ý rõ ràng từ bạn\n'
                    '• Yêu cầu của cơ quan pháp luật\n'
                    '• Bảo vệ quyền lợi hợp pháp của chúng tôi\n'
                    '• Trường hợp khẩn cấp về an toàn',
              ),
            ),

            SlideInAnimation(
              delay: const Duration(milliseconds: 1000),
              child: _buildSection(
                context,
                '5. Quyền của người dùng',
                'Bạn có quyền:\n'
                    '• Truy cập và xem thông tin cá nhân\n'
                    '• Chỉnh sửa hoặc cập nhật thông tin\n'
                    '• Xóa tài khoản và dữ liệu\n'
                    '• Từ chối thu thập thông tin không cần thiết\n'
                    '• Khiếu nại về việc xử lý dữ liệu',
              ),
            ),

            SlideInAnimation(
              delay: const Duration(milliseconds: 1200),
              child: _buildSection(
                context,
                '6. Lưu trữ dữ liệu',
                'Thông tin của bạn được lưu trữ:\n'
                    '• Trên máy chủ bảo mật tại Việt Nam\n'
                    '• Trong thời gian cần thiết để cung cấp dịch vụ\n'
                    '• Tuân thủ quy định pháp luật về lưu trữ dữ liệu\n'
                    '• Được xóa khi bạn yêu cầu hủy tài khoản',
              ),
            ),

            SlideInAnimation(
              delay: const Duration(milliseconds: 1400),
              child: _buildSection(
                context,
                '7. Cookie và công nghệ theo dõi',
                'Ứng dụng có thể sử dụng:\n'
                    '• Cookie để ghi nhớ phiên đăng nhập\n'
                    '• Analytics để cải thiện trải nghiệm\n'
                    '• Thông báo đẩy (với sự đồng ý)\n'
                    'Bạn có thể tắt các tính năng này trong cài đặt.',
              ),
            ),

            SlideInAnimation(
              delay: const Duration(milliseconds: 1600),
              child: _buildSection(
                context,
                '8. Thay đổi chính sách',
                'Chúng tôi có thể cập nhật chính sách này để phản ánh:\n'
                    '• Thay đổi trong dịch vụ\n'
                    '• Yêu cầu pháp lý mới\n'
                    '• Cải thiện bảo mật\n'
                    'Bạn sẽ được thông báo về các thay đổi quan trọng.',
              ),
            ),

            SlideInAnimation(
              delay: const Duration(milliseconds: 1800),
              child: _buildSection(
                context,
                '9. Liên hệ',
                'Nếu bạn có câu hỏi về chính sách bảo mật:\n'
                    '• Email: 2251120392@ut.edu.vn\n'
                    '• SĐT: 0384548931\n'
                    '• Địa chỉ: ĐH Giao thông Vận tải TP.HCM\n'
                    'Chúng tôi sẽ phản hồi trong vòng 48 giờ.',
              ),
            ),

            const SizedBox(height: 24),

            SlideInAnimation(
              delay: const Duration(milliseconds: 2000),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Chính sách này có hiệu lực từ ngày 01/12/2024\n'
                  'Phiên bản: 1.0.0\n'
                  'Cập nhật lần cuối: Tháng 12, 2024\n'
                  'Tuân thủ Luật An toàn thông tin mạng Việt Nam',
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
