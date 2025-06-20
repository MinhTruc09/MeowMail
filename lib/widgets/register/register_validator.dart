String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Vui lòng nhập email!';
  final emailRegex = RegExp(r'^\S+@\S+\.\S+ ');
  if (!emailRegex.hasMatch(value)) return 'Email không hợp lệ!';
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu!';
  if (value.length < 6) return 'Mật khẩu phải từ 6 ký tự!';
  return null;
}

String? validateRePassword(String? value, String password) {
  if (value == null || value.isEmpty) return 'Vui lòng nhập lại mật khẩu!';
  if (value != password) return 'Mật khẩu không khớp!';
  return null;
}

String? validateFullName(String? value) {
  if (value == null || value.isEmpty) return 'Vui lòng nhập họ tên!';
  return null;
} 