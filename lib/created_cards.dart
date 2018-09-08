import 'dart:math';
import 'package:flutter/material.dart';
import 'bloc/model.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your cards'),
      ),
      body: SafeArea(
        child: ListView(
          children: cards.map((card) {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: InlineCard(
                card: card,
                onTap: () {},
              )
            );
          }).toList()
        )
      )
    );
  }
}

class InlineCard extends StatelessWidget {
  InlineCard({
    @required this.card,
    this.onTap
  });

  final ContentCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(color: Colors.white, fontSize: 24.0);

    final bottomBar = Row(
      children: <Widget>[
        Text(card.author ?? ''),
        Expanded(child: Container()),
        Icon(Random().nextInt(2) == 0 ? Icons.cloud_off : Icons.cloud_done, color: Colors.white)
      ],
    );

    Widget cardContent = Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(card.content, style: style),
          bottomBar
        ]
      )
    );

    if (onTap != null) {
      cardContent = InkResponse(
        onTap: onTap,
        radius: 1000.0,
        child: cardContent,
      );
    }
    

    return Material(
      color: Colors.black,
      borderRadius: BorderRadius.all(Radius.circular(16.0)),
      elevation: 4.0,
      child: cardContent
    );
  }
}
