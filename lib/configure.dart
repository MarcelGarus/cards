import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'bloc/bloc.dart';
import 'deck_selector.dart';
import 'name_selector.dart';

/// The configuration page.
class ConfigureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPart = Material(
      color: Colors.white,
      elevation: 2.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 8.0),
          Row(
            children: <Widget>[
              Expanded(child: Container()),
              Image.asset('graphics/style384.png', width: 48.0, height: 48.0),
              Text('Cards', style: TextStyle(fontSize: 24.0)),
              Expanded(child: Container()),
            ]
          ),
          SizedBox(height: 8.0),
          NameSelector(),
        ],
      )
    );

    return Theme(
      data: Theme.of(context).copyWith(primaryColor: Colors.black),
      child: Container(
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            topPart,
            DeckSelector(),
            BetaBox(),
            SizedBox(height: 48.0 + 24.0)
          ],
        ),
      )
    );
  }
}



/// A greeting to beta testers.
class BetaBox extends StatelessWidget {
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
    return Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: Material(
        elevation: 2.0,
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Dankeschön für\'s Beta-Testen!', style: TextStyle(color: Colors.red, fontSize: 16.0)),
              SizedBox(height: 16.0),
              Text('Wie du siehst, funktioniert die grundlegende Spielmechanik bereits, allerdings mangelt es noch sehr an Inhalten, bislang gibt es nämlich nur 100 Karten.'),
              SizedBox(height: 4.0),
              Text('Deshalb wäre es nett, wenn du neue Karten erstellst (dazu unten auf\'s Menü gehen) und veröffentlichst. Als Gegenleistung kannst du deinen Namen auch auf den veröffentlichten Karten verewigen lassen.'),
              SizedBox(height: 4.0),
              Text('Oh, und falls du Bugs findest, Ideen für neue Kartendecks oder für einen besseren App-Namen als "Cards" hast oder wenn du einfach Feedback geben willst, schreib mir ruhig.'),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.centerRight,
                child: RaisedButton(
                  color: Colors.red,
                  onPressed: _giveFeedback,
                  child: Text('Feedback senden', style: TextStyle(color: Colors.white)),
                )
              ),
            ],
          )
        )
      )
    );
  }
}
