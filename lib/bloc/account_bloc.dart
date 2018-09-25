import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

class AccountBloc {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.standard(
    scopes: [ 'email', 'https://www.googleapis.com/auth/drive.appdata' ]
  );

  GoogleSignInAccount _account;

  final accountSubject = BehaviorSubject<GoogleSignInAccount>();


  Future<void> initialize() async {
    _account = await _googleSignIn.signInSilently();
    accountSubject.add(_account);
  }

  void dispose() {
    accountSubject.close();
  }


  Future<bool> signIn() async {
    try {
      _account = await _googleSignIn.signIn();
      accountSubject.add(_account);
      print('Successfully signed in: $_account');
    } catch (error) {
      print('Error while signing in: $error');
      return false;
    }
    return true;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    print('Signed out');
  }
}
