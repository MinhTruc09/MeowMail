import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mewmail/models/file/file_upload_response.dart';
import 'package:mewmail/services/auth_service.dart';

class FileService {
  static const String baseUrl = 'https://mailflow-backend-mj3r.onrender.com';

  /// Upload file và trả về URL
  static Future<String> uploadFile({
    required String token,
    required String filePath,
  }) async {
    try {
      debugPrint('📎 Upload file: $filePath');
      
      final uri = Uri.parse('$baseUrl/api/file/upload');
      final request = http.MultipartRequest('POST', uri);
      
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['accept'] = '*/*';
      
      // Thêm file vào request
      request.files.add(
        await http.MultipartFile.fromPath('file', filePath),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📎 Upload response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        // API trả về string URL trực tiếp
        final fileUrl = response.body.replaceAll('"', ''); // Remove quotes if any
        debugPrint('✅ Upload thành công: $fileUrl');
        return fileUrl;
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        debugPrint('❌ Lỗi xác thực upload: ${response.statusCode} - ${response.body}');
        final newToken = await AuthService.refreshTokenIfNeeded(token);
        if (newToken != null) {
          return await uploadFile(
            token: newToken,
            filePath: filePath,
          );
        } else {
          throw Exception('Session expired, please log in again');
        }
      } else {
        debugPrint('❌ Lỗi upload: ${response.statusCode} - ${response.body}');
        throw Exception('Upload failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Lỗi uploadFile: $e');
      rethrow;
    }
  }

  /// Helper method để kiểm tra file size (optional)
  static bool isFileSizeValid(int fileSizeBytes, {int maxSizeMB = 10}) {
    final maxSizeBytes = maxSizeMB * 1024 * 1024;
    return fileSizeBytes <= maxSizeBytes;
  }

  /// Helper method để kiểm tra file type (optional)
  static bool isFileTypeAllowed(String fileName) {
    final allowedExtensions = [
      '.jpg', '.jpeg', '.png', '.gif', '.bmp', // Images
      '.pdf', '.doc', '.docx', '.txt', '.rtf', // Documents
      '.xls', '.xlsx', '.csv', // Spreadsheets
      '.ppt', '.pptx', // Presentations
      '.zip', '.rar', '.7z', // Archives
    ];
    
    final extension = fileName.toLowerCase().substring(fileName.lastIndexOf('.'));
    return allowedExtensions.contains(extension);
  }

  /// Helper method để lấy file extension
  static String getFileExtension(String fileName) {
    return fileName.substring(fileName.lastIndexOf('.'));
  }

  /// Helper method để format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
