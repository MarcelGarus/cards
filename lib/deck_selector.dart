import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'bloc/bloc.dart';
import 'bloc/model.dart';
import 'deck_details.dart';

/// A list of selectable decks.
class DeckSelector extends StatelessWidget {
  DeckSelector();

  void _displayDetails(BuildContext context, List<Deck> allDecks, Deck deck) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, _, __) => DeckDetailsScreen(allDecks, deck),
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(opacity: animation, child: child);
      }
    ));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Deck>>(
      stream: Bloc.of(context).decks,
      builder: _buildList
    );
  }

  Widget _buildList(BuildContext context, AsyncSnapshot<List<Deck>> snapshot) {
    if (!snapshot.hasData || snapshot.data.length == 0) {
      print('Building no decks');
      return Container(
        height: 128.0,
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(),
            Text('snapshot.data: ${snapshot.data}')
          ]
        )
      );
    }

    final decks = snapshot.data;
    print('Building ${decks.length} decks.');
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: decks.map((deck) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: SelectableDeck(
              deck: deck,
              onSelect: () => Bloc.of(context).selectDeck(deck),
              onDeselect: () => Bloc.of(context).deselectDeck(deck),
              onDetails: () => _displayDetails(context, decks, deck),
            )
          );
        }).toList()
      )
    );
  }
}



/// A deck that can be selected and deselected with a tap.
class SelectableDeck extends StatefulWidget {
  SelectableDeck({
    @required this.deck,
    @required this.onSelect,
    @required this.onDeselect,
    @required this.onDetails
  });

  final Deck deck;
  final VoidCallback onSelect;
  final VoidCallback onDeselect;
  final VoidCallback onDetails;

  @override
  _SelectableDeckState createState() => _SelectableDeckState();
}

class _SelectableDeckState extends State<SelectableDeck>
    with SingleTickerProviderStateMixin {
  AnimationController _selectController;
  Animation<double> _selectAnimation;
  double _selectionValue;

  double get _defaultValue => widget.deck.isSelected ? 1.0 : 0.0;

  @override
  void initState() {
    super.initState();
    _selectionValue = _defaultValue;
    _selectController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )
      ..addListener(() => setState(() {
        _selectionValue = _selectAnimation?.value ?? _defaultValue;
      }));
  }

  @override
  void dispose() {
    _selectController.dispose();
    super.dispose();
  }

  void _toggleSelection() {
    final targetSelect = widget.deck.isSelected ? 0.0 : 1.0;
    _selectAnimation = Tween<double>(begin: _selectionValue, end: targetSelect)
      .animate(_selectController);
    _selectController
      ..value = 0.0
      ..fling(velocity: 2.0);

    if (widget.deck.isSelected)
      widget.onDeselect();
    else
      widget.onSelect();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        DeckCover(widget.deck),
        Material(
          color: Colors.black.withOpacity(_selectionValue * 0.5),
          borderRadius: BorderRadius.circular(8.0),
          child: InkResponse(
            onTap: _toggleSelection,
            onLongPress: widget.onDetails,
            splashColor: Colors.white12,
            highlightShape: BoxShape.rectangle,
            radius: 1000.0,
            child: Container(
              width: 96.0,
              height: 144.0,
              alignment: Alignment.center,
              child: Transform.translate(
                offset: Offset(0.0, 20 * (1 - _selectionValue)),
                child: Opacity(
                  opacity: _selectionValue,
                  child: Icon(Icons.check, color: Colors.white),
                )
              )
            )
          )
        )
      ],
    );
  }
}



/// A cover of a deck. TODO: add image
class DeckCover extends StatelessWidget {
  DeckCover(this.deck);

  final Deck deck;

  @override
  Widget build(BuildContext context) {
    final rgb = HEX.decode(deck.color.substring(1));
    final color = Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);

    return Hero(
      tag: 'deck_${deck.id}',
      child: Material(
        color: color,
        elevation: 2.0,
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [ Colors.white10, Colors.black12 ],
            ),
          ),
          width: 96.0,
          height: 144.0,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(deck.name)
          )
        )
      )
    );
  }
}