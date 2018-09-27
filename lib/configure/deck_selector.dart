import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import '../bloc/bloc.dart';
import '../bloc/model.dart';
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
      return Container(
        height: 128.0,
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(),
            Text('snapshot.data: ${snapshot.data}') // TODO: do more elegantly
          ]
        )
      );
    }

    final decks = snapshot.data;
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: decks.map((deck) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: SelectableDeck(
              deck: deck,
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
    @required this.onDetails
  });

  final Deck deck;
  final VoidCallback onDetails;

  @override
  _SelectableDeckState createState() => _SelectableDeckState();
}

class _SelectableDeckState extends State<SelectableDeck>
    with SingleTickerProviderStateMixin {
  AnimationController _selectController;
  Animation<double> _selectAnimation;
  double _selectionValue;
  double _targetSelectionValue;

  double get _defaultValue => !widget.deck.isUnlocked
      ? 1.0 : widget.deck.isSelected ? 1.0 : 0.0;

  @override
  void initState() {
    super.initState();
    _selectionValue = _defaultValue;
    _selectController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    )..addListener(() => setState(() {
      _selectionValue = _selectAnimation?.value ?? _defaultValue;
    }));
  }

  @override
  void dispose() {
    _selectController.dispose();
    super.dispose();
  }

  /// Updates the target value based on the given isSelect value. If it
  /// changed, start the animation.
  void _startAnimationIfNecessary(bool isSelected) {
    final targetSelectionValue = isSelected ? 1.0 : 0.0;
    if (_targetSelectionValue == targetSelectionValue) return; // Nothing changed

    _selectAnimation = Tween<double>(begin: _selectionValue, end: targetSelectionValue)
      .animate(_selectController);
    _selectController
      ..value = 0.0
      ..fling(velocity: 2.0);
  }

  /// If the deck is locked, try to unlock it. Otherwise, deselect the deck if
  /// it's already selected or select it if it's not.
  void _onTap() {
    final bloc = Bloc.of(context);

    if (widget.deck.isLocked)
      bloc.buy(widget.deck);
    else if (widget.deck.isSelected)
      bloc.deselectDeck(widget.deck);
    else
      bloc.selectDeck(widget.deck);
  }

  @override
  Widget build(BuildContext context) {
    _startAnimationIfNecessary(widget.deck.isSelected);

    final overlayItems = widget.deck.isUnlocked ? [
      Icon(Icons.check, color: Colors.white)
    ] : [
      Icon(Icons.lock_outline, size: 32.0, color: Colors.white),
      SizedBox(height: 8.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.play_circle_filled, size: 20.0, color: Colors.white),
          SizedBox(width: 4.0),
          Text(widget.deck.price.toString(),
            style: TextStyle(fontSize: 20.0, color: Colors.white)
          )
        ],
      )
    ];

    final iconOverlay = Container(
      width: 96.0,
      height: 144.0,
      alignment: Alignment.center,
      child: Transform.translate(
        offset: Offset(0.0, 20 * (1 - _selectionValue)),
        child: Opacity(
          opacity: _selectionValue,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: overlayItems
          )
        )
      )
    );

    return Stack(
      children: <Widget>[
        DeckCover(widget.deck),
        Material(
          color: Colors.black.withOpacity(_selectionValue * 0.5),
          borderRadius: BorderRadius.circular(8.0),
          child: InkResponse(
            onTap: _onTap,
            onLongPress: widget.onDetails,
            splashColor: Colors.white12,
            highlightShape: BoxShape.rectangle,
            radius: 1000.0,
            child: iconOverlay
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