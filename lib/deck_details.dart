import 'dart:async';
import 'package:flutter/material.dart' hide Card;
import 'package:hex/hex.dart';
import 'bloc/game_bloc.dart';
import 'bloc/model.dart';
import 'cards/inline_card.dart';
import 'deck_selector.dart';

class DeckDetailsScreen extends StatelessWidget {
  DeckDetailsScreen(this.deck);
  
  final Deck deck;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: DeckDetails(deck)
          )
        ],
      ),
    );
  }
}

class DeckDetails extends StatefulWidget {
  DeckDetails(this.deck);
  
  final Deck deck;

  @override
  State<StatefulWidget> createState() => _DeckDetailsState();
}

class _DeckDetailsState extends State<DeckDetails> {
  final sampleCards = <Card>[];

  void initState() {
    super.initState();
    generateSampleCards();
  }

  /// Pick some sample cards from the deck. For every card, create an own
  /// generator, so no followups are selected.
  Future<void> generateSampleCards() async {
    final config = Configuration(
      decks: [ widget.deck ],
      myCards: const [],
      players: const [ 'Alice', 'Bob', 'Marcel' ]
    );

    while (sampleCards.length < 3) {
      print('Generating card');
      final card = await (Generator()..initialize())
          .generateCard(config, onlyGameCard: true);
      
      if (card != null) setState(() => sampleCards.add(card));
    }
  }

  @override
  Widget build(BuildContext context) {
    final rgb = HEX.decode(widget.deck.color.substring(1));
    final color = Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);

    final button = RaisedButton(
      color: color,
      onPressed: () {},
      child: Text('BUY FOR ${widget.deck.price} coins'),
    );

    final topPart = Row(
      children: <Widget>[
        DeckCover(widget.deck),
        SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(widget.deck.name,
                style: TextStyle(fontSize: 28.0, fontFamily: 'Assistant')
              ),
              SizedBox(height: 8.0),
              button
            ],
          ),
        )
      ],
    );

    final sampleCardColumn = Column(
      mainAxisSize: MainAxisSize.min,
      children: sampleCards.map((card) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: InlineCard(card,
            showFollowup: false,
            showAuthor: false,
          )
        );
      }).toList()
    );

    final technicalInformation = Center(
      child: Text('id: ${widget.deck.id}, ${widget.deck.file}',
        style: TextStyle(fontSize: 12.0)
      )
    );

    return Theme(
      data: ThemeData.light(),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              topPart,
              SizedBox(height: 16.0),
              Text(widget.deck.description, style: TextStyle(fontSize: 16.0)),
              SizedBox(height: 8.0),
              sampleCardColumn,
              SizedBox(height: 16.0),
              technicalInformation
            ]
          )
        )
      )
    );
  }
}
