import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'bloc/bloc.dart';
import 'localize.dart';
import 'my_cards/cards_list.dart';
import 'settings.dart';

class Menu extends StatelessWidget {
  void _goToMyCards(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CardsListScreen()
    ));
  }

  /*void _goToSettings(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SettingsScreen()
    ));
  }*/

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
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Account(),
        Divider(),
        ListTile(
          leading: Icon(Icons.wb_iridescent, color: Colors.black),
          title: LocalizedText(id: TextId.menu_my_cards),
          onTap: () => _goToMyCards(context)
        ),
        /*ListTile(
          leading: Icon(Icons.settings, color: Colors.black),
          title: LocalizedText(id: TextId.menu_settings),
          onTap: () => _goToSettings(context)
        ),*/
        ListTile(
          leading: Icon(Icons.feedback, color: Colors.black),
          title: LocalizedText(id: TextId.menu_feedback),
          onTap: () => _giveFeedback(context)
        ),
        /*Row(
          children: <Widget>[
            Text('Open-source licenses'),
            Text('Privacy Policy'),
            Text('Terms of Service'),
          ],
        )*/
      ],
    );
    
    return Material(
      child: GestureDetector(
        // Prevents accidental taps from closing the bottom sheet.
        onTap: () {},
        child: column
      )
    );
  }
}

class Account extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Bloc.of(context).account,
      builder: (context, AsyncSnapshot<AccountState> snapshot) {
        if (!snapshot.hasData)
          return Container();

        switch (snapshot.data.connectionState) {
          case AccountConnectionState.SIGNED_IN:
            return _buildSignedIn(context, snapshot.data.snapshot, false);
          case AccountConnectionState.SIGNED_OUT:
            return _buildSignedOut(context, false);
          case AccountConnectionState.SIGNING_IN:
            return _buildSignedOut(context, true);
          case AccountConnectionState.SIGNING_OUT:
            return _buildSignedIn(context, snapshot.data.snapshot, true);
        }
      },
    );
  }

  _buildSignedIn(BuildContext context, AccountSnapshot snapshot, bool signingOut) {
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
          OutlineButton(
            onPressed: Bloc.of(context).signOut,
            child: Text(signingOut ? 'Signing out' : 'Sign out'),
          ),
        ],
      )
    );
  }

  _buildSignedOut(BuildContext context, bool signingIn) {
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
              RaisedButton(
                color: Theme.of(context).primaryColor,
                onPressed: Bloc.of(context).signIn,
                child: Text(signingIn ? 'Signing in' : 'Sign in'),
              ),
            ],
          ),
        ],
      )
    );
  }
}
