import 'package:flutter/material.dart';
import '../bloc/bloc.dart';
import '../cards/inline_card.dart';
import '../localize.dart';
import '../utils.dart';

/// The screen for publishing the card.
class PublishedCardScreen extends StatelessWidget {
  PublishedCardScreen({ @required this.card }) : assert(card != null);
  
  final MyCard card;

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: LocalizedText(TextId.published_title),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            Bloc.of(context).deleteCard(card);
            Navigator.of(context).pop();
          },
        )
      ],
    );

    final content = <Widget>[];

    content.addAll([
      LocalizedText(TextId.published_body, style: TextStyle(fontSize: 24.0)),
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

    return Theme(
      data: Utils.myCardsTheme,
      child: Scaffold(
        appBar: appBar,
        body: SafeArea(
          child: ListView(padding: EdgeInsets.all(16.0), children: content)
        )
      ),
    );
  }
}
