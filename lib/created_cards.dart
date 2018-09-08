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
      annihilation: 'annihilation',
      color: '#FFFFFF'
    ),
    ContentCard(
      id: 'card-id',
      content: 'other card',
      annihilation: 'annihilation',
      color: '#FFFFFF'
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
            return ListTile(
              title: Text(card.content),
              subtitle: Text(card.annihilation ?? '<no annihilation>'),
              onTap: () {},
            );
          }).toList()
        )
      )
    );
  }
}
