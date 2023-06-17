import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Handles the Google Sign-In functionality using Firebase Authentication and Firestore
class GoogleSignInProvider extends ChangeNotifier {
  static const String _loadingMsg = "Loading";

  final googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    try {
      // Show loading dialog
      SmartDialog.showLoading(
        msg: _loadingMsg,
        maskColor: const Color(0xffebecf3),
      );

      // Sign in with Google
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }
      _user = googleUser;

      final googleAuth = await googleUser.authentication;

      // Get credential from Google authentication
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase Auth using the credential
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        if (userCredential.additionalUserInfo!.isNewUser) {
          // Add the data to Firebase Firestore for new users
          await _firestore.collection('users').doc(user.uid).set({
            'username': user.displayName,
            'uid': user.uid,
            'profilePhoto': user.photoURL,
          });
        }
      }
    } catch (e) {
      print(e.toString());
    }

    // Dismiss the loading dialog
    SmartDialog.dismiss();
    notifyListeners();
  }

  Future logout() async {
    // Disconnect Google Sign-In and sign out from Firebase Auth
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }
}
