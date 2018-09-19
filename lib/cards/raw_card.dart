import 'package:flutter/material.dart';

/// A card in the game.
class RawCard extends StatelessWidget {
  const RawCard({
    this.heroTag,
    this.borderRadius,
    this.safeAreaTop = 0.0,
    this.contract = false,
    this.topBarLeading,
    this.topBarTailing,
    this.bottomBarLeading,
    this.bottomBarTailing,
    this.onTap,
    this.child
  });

  // Basic properties of the card.
  final String heroTag;
  final BorderRadius borderRadius;
  final double safeAreaTop;
  final bool contract;

  // Widgets that can customize the top bar.
  final Widget topBarLeading;
  final Widget topBarTailing;

  // Widgets that can customize the bottom bar.
  final Widget bottomBarLeading;
  final Widget bottomBarTailing;

  // Listeners.
  final VoidCallback onTap;

  final Widget child;


  @override
  Widget build(BuildContext context) {
    // The card's top bar.
    final topBar = Row(
      children: <Widget>[
        topBarLeading ?? Container(),
        Spacer(),
        topBarTailing ?? Container()
      ],
    );

    // The card's bottom bar.
    final bottomBar = Row(
      children: <Widget>[
        bottomBarLeading ?? Container(),
        Spacer(),
        bottomBarTailing ?? Container()
      ],
    );

    // Put the content parts into a column.
    Widget content = Column(
      mainAxisSize: contract ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: safeAreaTop),
        topBar,
        child,
        bottomBar
      ]
    );

    // During the hero animation, the card is lifted up into the overlay, where
    // it's provided with tight constraints. To avoid overflow errors and
    // visual inconsistencies when animating from a smaller to a larger
    // position (and thus trying to display the larger content in smaller,
    // tight constraints), the card's content isn't shown during the hero
    // animation.
    final layoutContent = !contract ? content : LayoutBuilder(
      builder: (context, BoxConstraints constraints) {
        return constraints.isTight ? Container() : Padding(
          padding: EdgeInsets.all(16.0),
          child: content
        );
      },
    );

    // Handle taps.
    final responsiveContent = (onTap == null) ? layoutContent : InkResponse(
      onTap: onTap,
      splashColor: Colors.white10,
      radius: 1000.0, // TODO: do not hardcode
      child: layoutContent
    );

    // The material card.
    Widget card = Material(
      color: Colors.black,
      borderRadius: borderRadius,
      elevation: 8.0,
      animationDuration: Duration.zero,
      child: responsiveContent
    );

    // The themed card.
    card = Theme(
      data: ThemeData(
        hintColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber)
          ),
        ),
        textTheme: TextTheme(
          body1: TextStyle(color: Colors.white, fontFamily: 'Assistant', fontSize: 24.0),
          body2: TextStyle(color: Colors.white, fontFamily: 'Assistant'),
          display1: TextStyle(color: Colors.white, fontFamily: 'Assistant'),
          display2: TextStyle(color: Colors.white, fontFamily: 'Assistant'),
          display3: TextStyle(color: Colors.white, fontFamily: 'Assistant'),
          display4: TextStyle(color: Colors.white, fontFamily: 'Assistant'),
        ),
      ),
      child: card
    );

    // Hero.
    if (heroTag != null) {
      card = Hero(tag: heroTag, child: card);
    }

    return card;
  }
}
