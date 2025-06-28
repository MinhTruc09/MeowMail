class UserProfile {
  final String email;
  final String fullname;
  final String phone;
  final String avatar;

  UserProfile({
    required this.email,
    required this.fullname,
    required this.phone,
    required this.avatar,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Handle server mapping bug - fields are swapped
    return UserProfile(
      email: json['fullname'] ?? '', // Server puts email in fullname field
      fullname: json['phone'] ?? '', // Server puts fullname in phone field  
      phone: json['avatar'] ?? '', // Server puts phone in avatar field
      avatar: json['email'] ?? '', // Server puts avatar URL in email field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'fullname': fullname,
      'phone': phone,
      'avatar': avatar,
    };
  }

  // Helper method to get display name
  String get displayName {
    if (fullname.isNotEmpty && fullname != '(không xác định)') {
      return fullname;
    }
    if (email.isNotEmpty && email.contains('@')) {
      final parts = email.split('@');
      final namePart = parts[0];
      if (namePart.contains('.')) {
        return namePart
            .split('.')
            .map((part) => part.isNotEmpty
                ? part[0].toUpperCase() + part.substring(1).toLowerCase()
                : '')
            .join(' ');
      }
      return namePart.isNotEmpty
          ? namePart[0].toUpperCase() + namePart.substring(1).toLowerCase()
          : 'Unknown';
    }
    return 'Unknown User';
  }

  // Helper method to get avatar initials
  String get avatarInitials {
    final name = displayName;
    if (name.contains(' ')) {
      final parts = name.split(' ');
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  // Helper method to check if avatar URL is valid
  bool get hasValidAvatar {
    return avatar.isNotEmpty && 
           (avatar.startsWith('http://') || avatar.startsWith('https://'));
  }
}
