import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'bloc/bloc.dart';
import 'my_cards/created_cards.dart';

class Menu extends StatelessWidget {
  void _giveFeedback() async {
    print('Mailing');
    final version = Bloc.version;
    final MailOptions mailOptions = MailOptions(
      body: 'Nicht löschen: Version $version\n\nHi Marcel,\n',
      subject: 'Feedback zu Cards',
      recipients: [ 'marcel.garus@gmail.com' ],
    );

    await FlutterMailer.send(mailOptions);
    print('Mail sent');
  }

  @override
  Widget build(BuildContext context) {
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.verified_user, color: Colors.black),
          title: Text('Log in'),
          subtitle: Text('Log in to synchronize your progress across devices and in order to publish your own cards.'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.wb_iridescent, color: Colors.black),
          title: Text('My cards'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return CardListScreen();
              }
            ));
          },
        ),
        ListTile(
          leading: Icon(Icons.feedback, color: Colors.black),
          title: Text('Send feedback'),
          onTap: _giveFeedback
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
        onTap: () {},
        child: column
      )
    );
  }
}