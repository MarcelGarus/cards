import 'package:flutter/material.dart';
import '../bloc/bloc.dart';
import '../bloc/model.dart';
import '../cards/inline_card.dart';
import '../localize.dart';
import '../utils.dart';
import 'guidelines.dart';

/// The screen for publishing the card.
class PublishCardScreen extends StatelessWidget {
  PublishCardScreen({ @required this.card, this.account }) : assert(card != null);
  
  final MyCard card;
  final AccountState account;

  void _publish(BuildContext context) {
    Bloc.of(context).publishCard(card).then((success) {
      if (success) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = <Widget>[];

    content.addAll([
      LocalizedText(TextId.publish_body, style: TextStyle(fontSize: 24.0)),
      SizedBox(height: 16.0),
      InlineCard(card.gameCard, showFollowup: false)
    ]);

    if (card.gameCard.hasFollowup) {
      content.addAll([
        SizedBox(height: 8.0),
        Center(
          child: Material(
            color: Colors.white,
            elevation: 2.0,
            shape: StadiumBorder(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: LocalizedText(TextId.publish_time)
            )
          )
        ),
        SizedBox(height: 8.0),
        InlineCard(card.gameCard.createFollowup())
      ]);
    }

    content.addAll([
      SizedBox(height: 16.0),
      Guidelines(),
      SizedBox(height: 16.0),
      LocalizedText(
        TextId.publish_conditions,
        style: TextStyle(fontSize: 10.0),
        textAlign: TextAlign.justify,
      ),
      SizedBox(height: 16.0),
      Center(child: PublishButton(onPublish: () => _publish(context)))
    ]);

    return Theme(
      data: Utils.myCardsTheme,
      child: Scaffold(
        appBar: AppBar(title: LocalizedText(TextId.publish_title)),
        body: SafeArea(
          child: ListView(padding: EdgeInsets.all(16.0), children: content)
        )
      ),
    );
  }
}


class PublishButton extends StatefulWidget {
  PublishButton({ @required this.onPublish });

  final VoidCallback onPublish;

  @override
  _PublishButtonState createState() => _PublishButtonState();
}

class _PublishButtonState extends State<PublishButton> {
  bool clicked = false;

  @override
  Widget build(BuildContext context) {
    if (clicked)
      return CircularProgressIndicator();

    return FloatingActionButton.extended(
      icon: Icon(Icons.cloud_upload),
      label: LocalizedText(TextId.publish_action),
      onPressed: () {
        setState(() => clicked = true);
        widget.onPublish();
      },
    );
  }
}