import 'package:flutter/material.dart';

/// A card in the game.
class RawCard extends StatelessWidget {
  const RawCard({
    this.borderRadius,
    this.safeAreaTop = 0.0,
    this.topBarLeading,
    this.topBarTailing,
    this.bottomBarLeading,
    this.bottomBarTailing,
    this.onTap,
    this.child
  });

  final Widget child;

  // Basic properties of the card.
  final BorderRadius borderRadius;
  final double safeAreaTop;

  // Widgets that can customize the top bar.
  final Widget topBarLeading;
  final Widget topBarTailing;

  // Widgets that can customize the bottom bar.
  final Widget bottomBarLeading;
  final Widget bottomBarTailing;

  // Listeners.
  final VoidCallback onTap;


  @override
  Widget build(BuildContext context) {
    final topBar = Row(
      children: <Widget>[
        topBarLeading ?? Container(),
        Spacer(),
        topBarTailing ?? Container()
      ],
    );

    final bottomBar = Row(
      children: <Widget>[
        bottomBarLeading ?? Container(),
        Spacer(),
        bottomBarTailing ?? Container()
      ],
    );

    return Material(
      color: Colors.black,
      borderRadius: borderRadius,
      elevation: 8.0,
      animationDuration: Duration.zero,
      child: InkResponse(
        onTap: onTap,
        splashColor: Colors.white10,
        child: Column(
          children: <Widget>[
            SizedBox(height: safeAreaTop),
            topBar,
            child,
            bottomBar
          ]
        ),
      )
    );
  }
}
