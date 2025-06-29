import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AvatarService {
  static const String baseUrl = 'https://mailflow-backend-mj3r.onrender.com';
  static final Map<String, String?> _avatarCache = {};

  /// Get user avatar URL by email
  static Future<String?> getUserAvatar(String email) async {
    // Check cache first
    if (_avatarCache.containsKey(email)) {
      return _avatarCache[email];
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final myEmail = prefs.getString('email');

      if (token == null || myEmail == null) return null;

      // Only load avatar for current user (since we only have my-profile endpoint)
      if (email == myEmail) {
        final response = await http
            .get(
              Uri.parse('$baseUrl/api/user/my-profile'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          if (json['data'] != null) {
            // API now returns correct field mapping
            final avatarUrl = json['data']['avatar'] as String?;

            // Validate avatar URL
            if (avatarUrl != null &&
                avatarUrl.isNotEmpty &&
                (avatarUrl.startsWith('http://') ||
                    avatarUrl.startsWith('https://'))) {
              _avatarCache[email] = avatarUrl;
              return avatarUrl;
            }
          }
        }
      }

      // Cache null result for other users or failed requests
      _avatarCache[email] = null;
      return null;
    } catch (e) {
      debugPrint('Error getting user avatar: $e');
      _avatarCache[email] = null;
      return null;
    }
  }

  /// Clear avatar cache
  static void clearCache() {
    _avatarCache.clear();
  }

  /// Generate avatar color based on email
  static Color getAvatarColor(String email) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];

    final hash = email.hashCode;
    return colors[hash.abs() % colors.length];
  }

  /// Generate avatar initials from email
  static String getAvatarInitials(String email) {
    if (email.isEmpty) return '?';

    final parts = email.split('@');
    if (parts.isEmpty) return '?';

    final username = parts[0];
    if (username.isEmpty) return '?';

    // Try to get initials from username
    if (username.contains('.')) {
      final nameParts = username.split('.');
      if (nameParts.length >= 2) {
        return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
      }
    }

    // Fallback to first two characters
    return username.length >= 2
        ? username.substring(0, 2).toUpperCase()
        : username[0].toUpperCase();
  }

  /// Clear avatar cache for specific email
  static void clearAvatarCache(String email) {
    _avatarCache.remove(email);
  }

  /// Clear all avatar cache
  static void clearAllAvatarCache() {
    _avatarCache.clear();
  }
}
