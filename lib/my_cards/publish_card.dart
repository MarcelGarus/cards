import 'package:flutter/material.dart';
import '../bloc/model.dart';
import '../cards/inline_card.dart';
import 'guidelines.dart';

/// The screen for publishing the card.
class PublishCardScreen extends StatelessWidget {
  PublishCardScreen({ @required this.card }) : assert(card != null);
  
  final GameCard card;

  @override
  Widget build(BuildContext context) {
    final content = <Widget>[];

    content.add(Padding(
      padding: EdgeInsets.all(16.0),
      child: Text('Make sure that your card fulfills all the guidelines below.',
        style: TextStyle(fontSize: 24.0),
      ),
    ));

    content.add(Padding(
      padding: EdgeInsets.all(16.0),
      child: Hero(
        tag: card.toString(),
        child: InlineCard(
          card: card,
          showFollowup: false,
        )
      )
    ));

    if (card.hasFollowup) {
      content.add(Center(
        child: Material(
          color: Colors.white,
          elevation: 2.0,
          shape: StadiumBorder(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Text('Then, after some time:')
          )
        )
      ));
      content.add(Padding(
        padding: EdgeInsets.all(16.0),
        child: InlineCard(
          card: card.createFollowup(),
        )
      ));
    }

    content.add(Padding(
      padding: EdgeInsets.all(16.0),
      child: Guidelines()
    ));

    content.add(Container(
      padding: EdgeInsets.only(bottom: 16.0),
      alignment: Alignment.center,
      child: FloatingActionButton.extended(
        icon: Icon(Icons.cloud_upload),
        label: Text('Publish'),
        elevation: 12.0,
        onPressed: () {},
      )
    ));

    return Scaffold(
      appBar: AppBar(title: Text('Publish card')),
      body: SafeArea(
        child: ListView(
          children: content
        )
      ),
    );
  }
}
