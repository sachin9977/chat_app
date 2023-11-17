import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/dailogs.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginProvider extends ChangeNotifier {
  bool _isAnimate = false;
  bool get isAnimate => _isAnimate;

  bool _isLoggingIn = false;
  bool get isLoggingIn => _isLoggingIn;

  Future<void> animateLogo() async {
    await Future.delayed(Duration(milliseconds: 500));
    _isAnimate = true;
    notifyListeners();
  }

  Future<void> handleGoogleButtonClick(BuildContext context) async {
    try {
      Dialogs.showProgressbar(context);
      final UserCredential? user = await _signInWithGoogle();
      Navigator.pop(context);

      if (user != null) {
        if (await APIs.userExists()) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
          );
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          });
        }
      }
    } catch (e) {
      print('SignInFailed $e');
      Dialogs.showSnackbar(context, 'Something Went Wrong');
    }
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('SignInFailed $e');
      throw Exception('SignInFailed $e');
    }
  }
}
