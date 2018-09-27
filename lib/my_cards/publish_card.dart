import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../bloc/account_bloc.dart';
import '../bloc/model.dart';
import '../cards/inline_card.dart';
import '../utils.dart';
import 'guidelines.dart';

/// The screen for publishing the card.
class PublishCardScreen extends StatelessWidget {
  PublishCardScreen({ @required this.card, this.account }) : assert(card != null);
  
  final MyCard card;
  final AccountState account;

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

    content.addAll([
      Text('Review your card.', style: TextStyle(fontSize: 24.0)),
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
              child: Text('Then, after some time:')
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
      Text(
        'Once you click the publish button, you agree to the following '
        'process: '
        'The card\'s "input" (content, followup and author) as well as your '
        'email address will be uploaded to and permanently stored on '
        'Google\'s servers. By publishing the card, you automatically '
        'transfer the input\'s copyright to this app\'s creator Marcel Garus, '
        'who will review it manually and - to his liking - add it to the '
        'database of cards. If he has any questions, he may mail you for '
        'clarification. '
        'You confirm that the input adheres to the guidelines stated above. '
        'After publishing the card, you will not be able to edit or delete '
        'the card any more.',
        style: TextStyle(fontSize: 10.0),
        textAlign: TextAlign.justify,
      ),
      SizedBox(height: 16.0),
      Center(
        child: FloatingActionButton.extended(
          icon: Icon(Icons.cloud_upload),
          label: Text('Publish'),
          onPressed: _publish,
        )
      )
    ]);

    return Theme(
      data: Utils.myCardsTheme,
      child: Scaffold(
        appBar: AppBar(title: Text('Publish card')),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: content
          )
        )
      ),
    );
  }
}
