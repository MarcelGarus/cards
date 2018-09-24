import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../bloc/model.dart';
import '../cards/inline_card.dart';
import '../utils.dart';
import 'guidelines.dart';

/// The screen for publishing the card.
class PublishCardScreen extends StatelessWidget {
  PublishCardScreen({ @required this.card }) : assert(card != null);
  
  final MyCard card;

  void _publish() {
    
    Firestore.instance.collection('suggestions').document().setData({
      'content': card.gameCard.content ?? '',
      'followup': card.gameCard.followup ?? '',
      'author': card.gameCard.author ?? '',
      'mail': 'marcel.garus@gmail.com'
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = <Widget>[];
    print('Building publish card $card.');

    content.add(Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Review your card.',
        style: TextStyle(fontSize: 24.0),
      ),
    ));

    content.add(Padding(
      padding: EdgeInsets.all(16.0),
      child: InlineCard(card.gameCard, showFollowup: false)
    ));

    if (card.gameCard.hasFollowup) {
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
        child: InlineCard(card.gameCard.createFollowup())
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
        onPressed: _publish,
      )
    ));

    return Theme(
      data: Utils.buildLightTheme(),
      child: Scaffold(
        appBar: AppBar(title: Text('Publish card')),
        body: SafeArea(child: ListView(children: content))
      ),
    );
  }
}
