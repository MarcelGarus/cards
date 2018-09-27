import 'dart:async';
import 'package:flutter/material.dart' hide Card;
import 'package:hex/hex.dart';
import '../bloc/bloc.dart';
import '../bloc/game_bloc.dart';
import '../bloc/model.dart';
import '../cards/inline_card.dart';
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
    
    if (widget.deck.id != 'my')
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

    final bloc = Bloc.of(context);
    final button = widget.deck.isUnlocked ? OutlineButton(
      onPressed: () {
        if (widget.deck.isSelected)
          bloc.deselectDeck(widget.deck);
        else
          bloc.selectDeck(widget.deck);
      },
      child: Text(widget.deck.isSelected ? 'Deselect' : 'Select')
    ) : RaisedButton(
      color: color,
      onPressed: () => bloc.buy(widget.deck),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('BUY FOR '),
          Icon(Icons.play_circle_filled, size: 16.0, color: Colors.black),
          Text(widget.deck.price.toString())
        ]
      ),
    );

    final topPart = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        DeckCover(widget.deck),
        SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(widget.deck.name,
                style: TextStyle(fontSize: 24.0, fontFamily: 'Assistant', height: 0.8)
              ),
              SizedBox(height: 8.0),
              button,
              SizedBox(height: 8.0),
              Text('n Karten', style: TextStyle(fontSize: 12.0))
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

    return Theme(
      data: ThemeData.light(),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        elevation: 16.0,
        // Stack with the actual list view and two gradient contains creating a
        // white fade effect hiding the sharp edge when scrolling.
        child: Stack(
          children: <Widget>[
            ListView(
              padding: EdgeInsets.all(16.0),
              children: <Widget>[
                topPart,
                SizedBox(height: 16.0),
                Text(widget.deck.description, style: TextStyle(fontSize: 16.0)),
                SizedBox(height: 8.0),
                sampleCardColumn,
                SizedBox(height: 8.0),
                Align(
                  alignment: Alignment.center,
                  child: Text(widget.deck.file, style: TextStyle(fontSize: 12.0))
                )
              ]
            ),
            // Top fade.
            Container(
              height: 16.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [ Colors.white, Color(0x00FFFFFF) ]
                )
              )
            ),
            // Bottom fade.
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 16.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [ Color(0x00FFFFFF), Colors.white ]
                  )
                )
              )
            ),
          ],
        )
      )
    );
  }
}
