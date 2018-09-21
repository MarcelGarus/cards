import 'dart:async';
import 'package:flutter/material.dart' hide Card;
import 'package:hex/hex.dart';
import 'bloc/game_bloc.dart';
import 'bloc/model.dart';
import 'cards/inline_card.dart';
import 'deck_selector.dart';

class DeckDetailsScreen extends StatefulWidget {
  DeckDetailsScreen(this.decks, this.initialDeck);

  final List<Deck> decks;
  final Deck initialDeck;

  @override
  State<StatefulWidget> createState() => _DeckDetailsScreenState();
}

class _DeckDetailsScreenState extends State<DeckDetailsScreen> {
  int activeDeck;

  void initState() {
    super.initState();
    activeDeck = widget.decks.indexOf(widget.initialDeck);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.decks.length,
      initialIndex: activeDeck,
      child: Scaffold(
        backgroundColor: Colors.black54,
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.decks.length, (i) {
            return _buildPageDot(i == activeDeck);
          })
        ),
        body: TabBarView(
          children: widget.decks.map((deck) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: DeckDetails(deck),
              )
            );
          }).toList()
        ),
      ),
    );
  }

  Widget _buildPageDot(bool selected) {
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      width: 8.0,
      height: 8.0,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.0),
        color: selected ? Colors.white : Colors.transparent,
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

    while (sampleCards.length < 1) {
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
        elevation: 16.0,
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
