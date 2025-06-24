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
    return ProfileResponseDto(
      email: json['email'] ?? '',
      fullname: json['fullname'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
} 