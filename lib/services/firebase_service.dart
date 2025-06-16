import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  static final _auth = FirebaseAuth.instance;

  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password.trim());
  }
  static Future<void> signOut()async{
    await _auth.signOut();
  }
  static User? get currentUser => _auth.currentUser;

}
