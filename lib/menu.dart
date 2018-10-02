import 'dart:async';
import 'package:flutter/material.dart';
import 'bloc/bloc.dart';
import 'feedback.dart';
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
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FeedbackScreen()
    ));
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      AccountTile(),
      Divider(),
      ListTile(
        leading: Icon(Icons.wb_iridescent),
        title: LocalizedText(TextId.menu_my_cards),
        onTap: () => _goToMyCards(context)
      ),
      ListTile(
        leading: Icon(Icons.feedback),
        title: LocalizedText(TextId.menu_feedback),
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
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(snapshot.name,
                  style: TextStyle(fontFamily: 'Signature', fontWeight: FontWeight.w700)
                ),
                SizedBox(height: 4.0),
                Text(snapshot.email)
              ],
            )
          ),
          SizedBox(width: 8.0),
          _buildButtonIfNotBusy(
            button: OutlineButton(
              onPressed: Bloc.of(context).signOut,
              child: LocalizedText(TextId.sign_out_action),
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
          LocalizedText(
            TextId.sign_in,
            style: TextStyle(fontSize: 24.0, fontFamily: 'Signature')
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(child: LocalizedText(TextId.sign_in_body)),
              SizedBox(width: 16.0),
              _buildButtonIfNotBusy(
                button: RaisedButton(
                  color: Theme.of(context).accentColor,
                  onPressed: Bloc.of(context).signIn,
                  child: LocalizedText(TextId.sign_in_action),
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
