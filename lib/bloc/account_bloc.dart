import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

/// The connectivity state of the account.
enum AccountConnectionState {
  SIGNING_OUT,
  SIGNED_OUT,
  SIGNING_IN,
  SIGNED_IN,
}

/// A snapshot of a specific user's account.
class AccountSnapshot {
  AccountSnapshot({ this.name, this.email, this.photoUrl });

  final String name;
  final String email;
  final String photoUrl;
}

/// The state of the account BLoC.
class AccountState {
  AccountState({ this.connectionState, this.snapshot });

  final AccountConnectionState connectionState;
  final AccountSnapshot snapshot;
}


/// The account BLoC.
class AccountBloc {
  final GoogleSignIn _googleSignIn = GoogleSignIn.standard(
    scopes: [ 'email', 'https://www.googleapis.com/auth/drive.appdata' ]
  );

  GoogleSignInAccount _account;
  AccountConnectionState _connectionState = AccountConnectionState.SIGNED_OUT;

  final accountSubject = BehaviorSubject<AccountState>();


  Future<void> initialize() async {
    _account = await _googleSignIn.signInSilently();

    _update((_account == null)
      ? AccountConnectionState.SIGNED_OUT
      : AccountConnectionState.SIGNED_IN
    );
  }

  void dispose() {
    accountSubject.close();
  }


  Future<void> signIn() async {
    _update(AccountConnectionState.SIGNING_IN);

    try {
      // Sign in.
      _account = await _googleSignIn.signIn();

      print('Successfully signed in: $_account');
      _update(AccountConnectionState.SIGNED_IN);
    } catch (error) {
      print('Error while signing in: $error');
      _update(AccountConnectionState.SIGNED_OUT);
    }
  }

  Future<void> signOut() async {
    _update(AccountConnectionState.SIGNING_OUT);
    await _googleSignIn.signOut();

    print('Signed out.');
    _update(AccountConnectionState.SIGNED_OUT);
  }

  void _update(AccountConnectionState state) {
    _connectionState = state;

    accountSubject.add(
      AccountState(
        connectionState: _connectionState,
        snapshot: _account == null ? null : AccountSnapshot(
          name: _account.displayName,
          email: _account.email,
          photoUrl: _account.photoUrl
        )
      )
    );
  }
}
