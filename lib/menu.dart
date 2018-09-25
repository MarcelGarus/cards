import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'bloc/bloc.dart';
import 'localize.dart';
import 'my_cards/cards_list.dart';
import 'settings.dart';

class Menu extends StatelessWidget {
  void _logIn(BuildContext context) {
    Bloc.of(context).signIn();
  }

  void _goToMyCards(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CardsListScreen()
    ));
  }

  void _goToSettings(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SettingsScreen()
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
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildAccountPart(),
        ListTile(
          leading: Icon(Icons.wb_iridescent, color: Colors.black),
          title: LocalizedText(id: TextId.menu_my_cards),
          onTap: () => _goToMyCards(context)
        ),
        ListTile(
          leading: Icon(Icons.settings, color: Colors.black),
          title: LocalizedText(id: TextId.menu_settings),
          onTap: () => _goToSettings(context)
        ),
        ListTile(
          leading: Icon(Icons.feedback, color: Colors.black),
          title: LocalizedText(id: TextId.menu_feedback),
          onTap: () => _giveFeedback(context)
        ),
        Row(
          children: <Widget>[
            Text('Open-source licenses'),
            Text('Privacy Policy'),
            Text('Terms of Service'),
          ],
        )
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

  _buildAccountPart() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Sign in to publish your cards to the whole world',
          style: TextStyle(fontSize: 24.0, fontFamily: 'Signature')
        ),
        Text('Also, youll be able to synchronize your progress among multiple devices.')        
      ],
    );
  }
}
