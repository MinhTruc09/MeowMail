import 'package:flutter/material.dart';
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

      if (token == null) return null;

      // For now, we'll use a placeholder since we don't have a specific
      // endpoint to get user avatar by email. In a real app, you'd have
      // an endpoint like /api/user/profile/{email} or /api/user/avatar/{email}

      // Cache the result (null for now)
      _avatarCache[email] = null;
      return null;
    } catch (e) {
      debugPrint('Error getting user avatar: $e');
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
}
