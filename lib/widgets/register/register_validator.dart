String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Vui lòng nhập email';
  }
  final emailRegex = RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
  if (!emailRegex.hasMatch(value)) {
    return 'Email không hợp lệ';
  }
  return null;
}

String? validateFullName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Vui lòng nhập họ và tên';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.length < 6) {
    return 'Mật khẩu phải từ 6 ký tự';
  }
  return null;
}

String? validateRePassword(String? value, String password) {
  if (value != password) {
    return 'Mật khẩu nhập lại không khớp';
  }
  return null;
}