import 'package:flutter/material.dart';
import '../bloc/bloc.dart';
import '../feedback.dart';
import '../localize.dart';
import 'deck_selector.dart';
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
      elevation: 2.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: MediaQuery.of(context).padding.top),
          appBar,
          PlayerInput()
        ],
      )
    );

    return Container(
      child: ListView(
        padding: EdgeInsets.only(top: 0.0, bottom: 48.0 + 24.0),
        children: <Widget>[ topPart, DeckSelector() ],
      ),
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
  void _giveFeedback(BuildContext context) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FeedbackScreen()
    ));
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
              LocalizedText(TextId.beta_box_title,
                style: TextStyle(color: Colors.red, fontSize: 16.0, fontFamily: 'Assistant')
              ),
              SizedBox(height: 16.0),
              LocalizedText(TextId.beta_box_body),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.centerRight,
                child: RaisedButton(
                  color: Colors.red,
                  onPressed: () => _giveFeedback(context),
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
