import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'bloc/bloc.dart';
import 'deck_selector.dart';
import 'localize.dart';
import 'player_input.dart';

/// The configuration page.
class ConfigureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appBar = Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Spacer(),
          Image.asset('graphics/style384.png', width: 48.0, height: 48.0),
          Text('Cards', style: TextStyle(fontSize: 24.0, fontFamily: 'Signature')),
          Spacer(),
          CoinCounter()
        ]
      ),
    );

    final topPart = Material(
      color: Colors.white,
      elevation: 2.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          appBar,
          PlayerInput(),
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
            //BetaBox(),
            SizedBox(height: 48.0 + 24.0),
          ],
        ),
      )
    );
  }
}



/// The coin counter.
class CoinCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Bloc.of(context).coins,
      builder: (BuildContext context, AsyncSnapshot<BigInt> snapshot) {
        return Material(
          shape: StadiumBorder(),
          color: Colors.black12,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(snapshot.data?.toString() ?? '0')
          )
        );
      },
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
              LocalizedText(
                id: TextId.beta_box_title,
                style: TextStyle(color: Colors.red, fontSize: 16.0, fontFamily: 'Assistant')
              ),
              SizedBox(height: 16.0),
              LocalizedText(id: TextId.beta_box_body),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.centerRight,
                child: RaisedButton(
                  color: Colors.red,
                  onPressed: _giveFeedback,
                  child: Text(
                    'Feedback senden',
                    style: TextStyle(color: Colors.white)
                  ),
                )
              ),
            ],
          )
        )
      )
    );
  }
}
