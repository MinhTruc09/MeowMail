import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  static Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw Exception("Google sign-in cancelled");
    }

    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  static Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  static User? get currentUser => _auth.currentUser;

  static Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final userCred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    // Lưu thông tin user vào Firestore
    await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
      'email': email.trim(),
      'name': name.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return userCred;
  }
  static Future<void> passwordReset({
    required BuildContext context,
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Đặt lại mật khẩu"),
            content: const Text("Vui lòng kiểm tra email của bạn để đặt lại mật khẩu."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Lỗi"),
            content: Text("Không thể gửi email đặt lại mật khẩu: $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Đóng"),
              ),
            ],
          );
        },
      );
    }
  }

}
