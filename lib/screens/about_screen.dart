import 'package:flutter/material.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:mewmail/widgets/common/animated_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      appBar: AppBar(
        title: const Text(
          'Về chúng tôi',
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
            // App Logo & Name Section
            FadeInAnimation(
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: screenWidth * 0.25,
                      height: screenWidth * 0.25,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryYellow,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/logocat.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'MewMail',
                      style: TextStyle(
                        fontSize: AppTheme.responsiveWidth(context, 0.08),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Borel',
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                    Text(
                      'Ứng dụng quản lý email thông minh',
                      style: TextStyle(
                        fontSize: AppTheme.responsiveWidth(context, 0.04),
                        color: Colors.grey[600],
                        fontFamily: 'Borel',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.04),

            // App Info Section
            SlideInAnimation(
              delay: const Duration(milliseconds: 200),
              child: _buildInfoCard(
                context,
                'Thông tin ứng dụng',
                Icons.info_outline,
                [
                  _buildInfoRow('Phiên bản', '1.0.0'),
                  _buildInfoRow('Ngày phát hành', 'Tháng 12, 2024'),
                  _buildInfoRow('Nền tảng', 'Flutter & Spring Boot'),
                  _buildInfoRow('Loại ứng dụng', 'Email Management'),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // Developer Info Section
            SlideInAnimation(
              delay: const Duration(milliseconds: 400),
              child: _buildInfoCard(
                context,
                'Thông tin nhà phát triển',
                Icons.person_outline,
                [
                  _buildInfoRow('Họ tên', 'Nguyễn Minh Trực'),
                  _buildInfoRow('MSSV', '2251120392'),
                  _buildInfoRow('Ngày sinh', '09/10/2004'),
                  _buildInfoRow('SĐT', '0384548931'),
                  _buildInfoRow('Trường', 'ĐH Giao thông Vận tải TP.HCM'),
                  _buildInfoRow('Khoa', 'Công nghệ Thông tin'),
                  _buildInfoRow('Lớp', 'CNTT-K47'),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // Contact Info Section
            SlideInAnimation(
              delay: const Duration(milliseconds: 600),
              child: _buildInfoCard(
                context,
                'Liên hệ',
                Icons.contact_mail_outlined,
                [
                  _buildInfoRow('Email', '2251120392@ut.edu.vn'),
                  _buildInfoRow('Facebook', 'facebook.com/nguyen.truc.101966'),
                  _buildInfoRow('GitHub', 'github.com/MinhTruc09'),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // Description Section
            SlideInAnimation(
              delay: const Duration(milliseconds: 800),
              child: _buildInfoCard(
                context,
                'Mô tả ứng dụng',
                Icons.description_outlined,
                [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryYellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryYellow.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'MewMail là ứng dụng quản lý email hiện đại được phát triển bằng Flutter và Spring Boot. '
                      'Ứng dụng cung cấp các tính năng gửi/nhận email, quản lý hộp thư, tìm kiếm email, '
                      'và tích hợp AI để hỗ trợ soạn thảo email thông minh. '
                      'Đây là sản phẩm đồ án tốt nghiệp chuyên ngành Công nghệ Thông tin.',
                      style: TextStyle(
                        fontSize: AppTheme.responsiveWidth(context, 0.035),
                        color: AppTheme.primaryBlack,
                        height: 1.5,
                        fontFamily: 'Borel',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppTheme.primaryBlack, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppTheme.responsiveWidth(context, 0.045),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlack,
                    fontFamily: 'Borel',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                fontFamily: 'Borel',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.primaryBlack,
                fontFamily: 'Borel',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
