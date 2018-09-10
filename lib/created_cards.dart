import 'package:flutter/material.dart';
import 'bloc/model.dart';
import 'edit_and_publish_card.dart';
import 'inline_card.dart';

class CardListScreen extends StatefulWidget {
  @override
  _CardListScreenState createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  List<ContentCard> cards = [
    ContentCard(
      id: 'card-id',
      content: 'content content content content content content content content content content content content content content content content content content content content content content content content content content content content content content content content content content content content content content content content content',
      followup: 'annihilation',
      color: '#FFFFFF'
    ),
    ContentCard(
      id: 'card-id',
      content: 'other card',
      followup: 'annihilation',
      color: '#FFFFFF',
      author: 'me'
    ),
    ContentCard(
      id: 'card-id',
      content: 'and yet another card',
      color: '#FFFFFF'
    ),
  ];

  void _goToEditScreen(BuildContext context, ContentCard card) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext context, _, __) {
        return EditCardScreen(card: card);
      },
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child
        );
      }
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your cards'),
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            SizedBox(height: 16.0)
          ].followedBy(cards.map((card) {
            return Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Hero(
                tag: card.toString(),
                child: InlineCard(
                  card: card,
                  showFollowup: false,
                  showAuthor: false,
                  onTap: () => _goToEditScreen(context, card)
                )
              )
            );
          })).toList()
        )
      )
    );
  }
}
