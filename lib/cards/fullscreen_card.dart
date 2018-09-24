import 'package:flutter/material.dart' hide Card;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:hex/hex.dart';
import '../bloc/model.dart';
import 'raw_card.dart';

/// A fullscreen card in the game.
class FullscreenCard extends StatelessWidget {
  FullscreenCard({
    @required this.card,
    this.borderRadius = BorderRadius.zero,
    this.safeAreaTop = 0.0,
  }) :
      assert(card != null),
      assert(safeAreaTop != null);

  /// The card to display.
  final Card card;

  /// Properties of the material card.
  final BorderRadius borderRadius;
  final double safeAreaTop;


  @override
  Widget build(BuildContext context) {
    // Call the correct handler based on the card's type.
    List<Widget> children;

    if (card is EmptyCard)
      children = _buildEmptyCard(context, card);
    else if (card is IntroCard)
      children = _buildIntroductionCard(context, card);
    else if (card is GameCard)
      children = _buildContentCard(context, card);
    else if (card is CoinCard)
      children = _buildCoinCard(context, card);

    // Returns the actual card.
    return RawCard(
      borderRadius: borderRadius,
      safeAreaTop: safeAreaTop,
      child: Expanded(child: RepaintBoundary(child: Column(children: children))),
    );
  }

  /// Builds an empty card.
  List<Widget> _buildEmptyCard(BuildContext context, EmptyCard card) => [];

  /// Builds a welcome card.
  List<Widget> _buildIntroductionCard(BuildContext context, IntroCard card) {
    return [
      Expanded(child: Container()),
      Text(card.text, style: TextStyle(color: Colors.white, fontSize: 24.0)),
      Expanded(child: Container())
    ];
  }

  /// Builds a content card.
  List<Widget> _buildContentCard(BuildContext context, GameCard card) {
    final rgb = HEX.decode(card.color.substring(1));
    final color = Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);
    
    return [
      Expanded(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: AutoSizeText(
              card.content,
              style: TextStyle(color: color, fontSize: 48.0),
              stepGranularity: 4.0,
            )
          )
        )
      ),
      Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(card.hasAuthor ? 'von ${card.author}' : '',
              style: TextStyle(color: color, fontSize: 16.0)
            ),
            Text(card.id,
              style: TextStyle(color: Color.lerp(Colors.black, color, 0.05))
            ),
          ],
        )
      )
    ];
  }

  /// Builds a coin card.
  List<Widget> _buildCoinCard(BuildContext context, CoinCard card) {
    return [
      Expanded(child: Container()),
      Icon(Icons.code, color: Colors.white),
      Text(card.text, style: TextStyle(color: Colors.white)),
      Expanded(child: Container()),
    ];
  }
}
