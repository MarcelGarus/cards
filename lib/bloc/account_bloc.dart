import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

/// The connectivity state of the account.
enum SignInState {
  SIGNING_OUT,
  SIGNED_OUT,
  SIGNING_IN,
  SIGNED_IN,
}

/// A snapshot of a specific user's account.
class Account {
  Account({ this.name, this.email, this.photoUrl });

  final String name;
  final String email;
  final String photoUrl;
}

/// The state of the account BLoC.
class AccountState {
  AccountState({ this.signInState, this.account });

  final SignInState signInState;
  final Account account;
}


/// The account BLoC.
class AccountBloc {
  final GoogleSignIn _googleSignIn = GoogleSignIn.standard(
    scopes: [ 'email', 'https://www.googleapis.com/auth/drive.appdata' ]
  );

  GoogleSignInAccount _account;
  SignInState _connectionState = SignInState.SIGNED_OUT;

  final accountSubject = BehaviorSubject<AccountState>();


  Future<void> initialize() async {
    _account = await _googleSignIn.signInSilently();

    _update((_account == null)
      ? SignInState.SIGNED_OUT
      : SignInState.SIGNED_IN
    );
  }

  void dispose() {
    accountSubject.close();
  }


  Future<void> signIn() async {
    _update(SignInState.SIGNING_IN);

    try {
      // Sign in.
      _account = await _googleSignIn.signIn();

      print('Successfully signed in: $_account');
      _update(SignInState.SIGNED_IN);
    } catch (error) {
      print('Error while signing in: $error');
      _update(SignInState.SIGNED_OUT);
    }
  }

  Future<void> signOut() async {
    _update(SignInState.SIGNING_OUT);
    await _googleSignIn.signOut();

    print('Signed out.');
    _update(SignInState.SIGNED_OUT);
  }

  void _update(SignInState state) {
    _connectionState = state;

    accountSubject.add(
      AccountState(
        signInState: _connectionState,
        account: _account == null ? null : Account(
          name: _account.displayName,
          email: _account.email,
          photoUrl: _account.photoUrl
        )
      )
    );
  }
}
