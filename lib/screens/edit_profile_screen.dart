import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _gender = 'Nam';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final accountsRaw = prefs.getString('accounts');
    if (accountsRaw != null) {
      // Giả lập lấy dữ liệu user từ local
      final accounts = List<Map<String, dynamic>>.from(
        (accountsRaw.isNotEmpty) ? List<Map<String, dynamic>>.from(List<dynamic>.from(accountsRaw.codeUnits.map((e) => String.fromCharCode(e)).join() == '' ? [] : List<dynamic>.from(List<dynamic>.from(List<dynamic>.from(accountsRaw.codeUnits.map((e) => String.fromCharCode(e)).join() == '' ? [] : List<dynamic>.from([])))))) : []);
      if (accounts.isNotEmpty) {
        setState(() {
          _nameController.text = accounts[0]['username'] ?? '';
          _nicknameController.text = accounts[0]['nickname'] ?? '';
          _emailController.text = accounts[0]['email'] ?? '';
          _phoneController.text = accounts[0]['phone'] ?? '';
          _gender = accounts[0]['gender'] ?? 'Nam';
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();
    final accountsRaw = prefs.getString('accounts');
    if (accountsRaw != null) {
      final accounts = List<Map<String, dynamic>>.from(
        (accountsRaw.isNotEmpty) ? List<Map<String, dynamic>>.from(List<dynamic>.from(accountsRaw.codeUnits.map((e) => String.fromCharCode(e)).join() == '' ? [] : List<dynamic>.from(List<dynamic>.from(List<dynamic>.from(accountsRaw.codeUnits.map((e) => String.fromCharCode(e)).join() == '' ? [] : List<dynamic>.from([])))))) : []);
      if (accounts.isNotEmpty) {
        accounts[0]['username'] = _nameController.text;
        accounts[0]['nickname'] = _nicknameController.text;
        accounts[0]['email'] = _emailController.text;
        accounts[0]['phone'] = _phoneController.text;
        accounts[0]['gender'] = _gender;
        await prefs.setString('accounts', accounts.toString());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu thông tin thành công!')));
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _EditProfileHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _EditProfileTextField(label: 'Họ và tên', controller: _nameController),
                      const SizedBox(height: 12),
                      _EditProfileTextField(label: 'Nick name', controller: _nicknameController),
                      const SizedBox(height: 12),
                      _EditProfileTextField(label: 'email', controller: _emailController, keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 12),
                      _EditProfileTextField(label: 'Số điện thoại', controller: _phoneController, keyboardType: TextInputType.phone, suffix: const Icon(Icons.flag)),
                      const SizedBox(height: 12),
                      _GenderDropdown(value: _gender, onChanged: (v) => setState(() => _gender = v)),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _saveProfile,
                          child: const Text('Lưu thông tin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Borel', color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Image.asset('assets/images/paw.png', width: screenWidth * 0.3),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 90,
          decoration: const BoxDecoration(
            color: Color(0xFFFFCC00),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 36,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 36,
          child: Center(
            child: Text('Chỉnh sửa thông tin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, fontFamily: 'Borel', color: Colors.black)),
          ),
        ),
      ],
    );
  }
}

class _EditProfileTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final Widget? suffix;
  const _EditProfileTextField({required this.label, required this.controller, this.keyboardType, this.suffix});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (v) => (v == null || v.isEmpty) ? 'Không được để trống' : null,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

class _GenderDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _GenderDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: const [
        DropdownMenuItem(value: 'Nam', child: Text('Nam')),
        DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
        DropdownMenuItem(value: 'Khác', child: Text('Khác')),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Giới tính',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
} 