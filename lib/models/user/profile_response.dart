class ProfileResponseDto {
  final String email;
  final String fullname;
  final String phone;
  final String avatar;

  ProfileResponseDto({
    required this.email,
    required this.fullname,
    required this.phone,
    required this.avatar,
  });

  factory ProfileResponseDto.fromJson(Map<String, dynamic> json) {
    // API now returns correct field mapping
    return ProfileResponseDto(
      email: json['email'] ?? '',
      fullname: json['fullname'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'] ?? '',
    );
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
            .map(
              (part) =>
                  part.isNotEmpty
                      ? part[0].toUpperCase() + part.substring(1).toLowerCase()
                      : '',
            )
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
