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
        ListTile(
          leading: Icon(Icons.verified_user, color: Colors.black),
          title: LocalizedText(id: TextId.menu_log_in),
          subtitle: LocalizedText(id: TextId.menu_log_in_text),
          onTap: () => _logIn(context),
        ),
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
}
