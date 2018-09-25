import 'package:flutter/material.dart';
import 'bloc/bloc.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38,
      body: Theme(
        data: Theme.of(context).copyWith(textTheme: TextTheme(
          body1: TextStyle(color: Colors.black),
        )),
        child: GestureDetector(
          onTap: Navigator.of(context).pop,
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.all(32.0),
              alignment: Alignment.center,
              child:  _buildSignInDialog(context)
            )
          )
        )
      )
    );
  }

  Widget _buildSignInDialog(BuildContext context) {
    return _buildDialog(
      context: context,
      title: 'Sign in?',
      body: 'You\'ll be able to publish your cards to the world and save your '
        'progress across devices.',
      primaryAction: 'Sign in',
      primaryCallback: Bloc.of(context).signIn,
      secondaryAction: 'Not now',
      secondaryCallback: Navigator.of(context).pop
    );
  }

  Widget _buildSignOutDialog(BuildContext context) {
    return _buildDialog(
      context: context,
      title: 'Sign out?',
      body: 'The cards you published will still remain published.',
      primaryAction: 'Sign out',
      primaryCallback: Bloc.of(context).signOut,
      secondaryAction: 'Not now',
      secondaryCallback: Navigator.of(context).pop
    );
  }

  Widget _buildDialog({
    BuildContext context,
    String title,
    String body,
    String primaryAction,
    VoidCallback primaryCallback,
    String secondaryAction,
    VoidCallback secondaryCallback
  }) {
    final primaryButton = RaisedButton(
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Text(primaryAction, style: TextStyle(color: Colors.black))
      ),
      onPressed: primaryCallback,
      color: Theme.of(context).primaryColor
    );

    final secondaryButton = FlatButton(
      child: Text(secondaryAction, style: TextStyle(color: Colors.grey)),
      onPressed: secondaryCallback,
    );

    final buttonRow = Row(
      children: <Widget>[
        Spacer(),
        secondaryButton,
        SizedBox(width: 16.0),
        primaryButton
      ],
    );

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title,
          style: TextStyle(fontSize: 24.0, fontFamily: 'Assistant')
        ),
        SizedBox(height: 16.0),
        Text(body),
        SizedBox(height: 16.0),
        buttonRow
      ],
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.0),
      elevation: 16.0,
      child: Padding(padding: EdgeInsets.all(32.0), child: column)
    );
  }
}
