import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'bloc/bloc.dart';
import 'localize.dart';
import 'my_cards/my_cards.dart';
import 'utils.dart';

/// The full menu with the account state, as well as further buttons for
/// writing own cards, giving feedback etc.
class Menu extends StatelessWidget {
  void _goToMyCards(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => MyCardsScreen()
    ));
  }

  void _giveFeedback(BuildContext context) async {
    print('Mailing');
    final version = Bloc.version;

    final MailOptions mailOptions = MailOptions(
      subject: Bloc.of(context).getText(TextId.mail_subject),
      recipients: [ 'marcel.garus@gmail.com' ],
      body: Bloc
          .of(context)
          .getText(TextId.mail_body)
          .replaceFirst('\$version', version),
    );

    await FlutterMailer.send(mailOptions);
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      AccountTile(),
      Divider(),
      ListTile(
        leading: Icon(Icons.wb_iridescent),
        title: LocalizedText(id: TextId.menu_my_cards),
        onTap: () => _goToMyCards(context)
      ),
      ListTile(
        leading: Icon(Icons.feedback),
        title: LocalizedText(id: TextId.menu_feedback),
        onTap: () => _giveFeedback(context)
      )
    ];
    
    return Theme(
      data: Utils.mainTheme,
      child: Material(
        child: GestureDetector(
          // Prevents accidental taps from closing the bottom sheet.
          onTap: () {},
          child: Column(mainAxisSize: MainAxisSize.min, children: items)
        )
      )
    );
  }
}


/// A menu with only the account displayed. Once the user logs in, the menu
/// automatically disappears.
class SignInMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: GestureDetector(
        // Prevents accidental taps from closing the bottom sheet.
        onTap: () {},
        child: AccountTile(onSignedIn: () {
          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pop();
          });
        })
      )
    );
  }
}


/// A widget displaying the account state.
/// 
/// If signed in, the user's photo and some data will be displayed, as well as
/// a button to sign out.
/// 
/// If signed out, an encouraging text will be displayed as well as a button to
/// sign in.
class AccountTile extends StatelessWidget {
  AccountTile({ this.onSignedIn });

  final VoidCallback onSignedIn;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Bloc.of(context).account,
      builder: (context, AsyncSnapshot<AccountState> snapshot) {
        if (!snapshot.hasData)
          return Container();

        switch (snapshot.data.signInState) {
          case SignInState.SIGNED_IN:
            if (onSignedIn != null)
              onSignedIn();
            return _buildSignedIn(context, snapshot.data.account, false);
          case SignInState.SIGNED_OUT:
            return _buildSignedOut(context, false);
          case SignInState.SIGNING_IN:
            return _buildSignedOut(context, true);
          case SignInState.SIGNING_OUT:
            return _buildSignedIn(context, snapshot.data.account, true);
        }
      },
    );
  }

  _buildSignedIn(BuildContext context, Account snapshot, bool isSigningOut) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          CircleAvatar(backgroundImage: NetworkImage(snapshot.photoUrl)),
          SizedBox(width: 16.0),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(snapshot.name, style: TextStyle(fontFamily: 'Signature', fontWeight: FontWeight.w700)),
              SizedBox(height: 4.0),
              Text(snapshot.email)
            ],
          ),
          Spacer(),
          _buildButtonIfNotBusy(
            button: OutlineButton(
              onPressed: Bloc.of(context).signOut,
              child: Text(isSigningOut ? 'Signing out' : 'Sign out'),
            ),
            busy: isSigningOut
          ),
        ],
      )
    );
  }

  _buildSignedOut(BuildContext context, bool isSigningIn) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Sign in to publish your cards to the whole world',
            style: TextStyle(fontSize: 24.0, fontFamily: 'Signature')
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text('Also, you\'ll be able to synchronize your progress among multiple devices.')
              ),
              SizedBox(width: 16.0),
              _buildButtonIfNotBusy(
                button: RaisedButton(
                  color: Theme.of(context).primaryColor,
                  onPressed: Bloc.of(context).signIn,
                  child: Text(isSigningIn ? 'Signing in' : 'Sign in'),
                ),
                busy: isSigningIn
              )
            ],
          ),
        ],
      )
    );
  }

  _buildButtonIfNotBusy({ Widget button, bool busy }) {
    if (busy) {
      return Container(
        width: 24.0,
        height: 24.0,
        child: CircularProgressIndicator()
      );
    }

    return button;
  }
}
