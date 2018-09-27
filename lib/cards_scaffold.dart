import 'dart:math';
import 'package:flutter/material.dart';

class GestureStackTester extends StatefulWidget {
  @override
  _GestureStackTesterState createState() => _GestureStackTesterState();
}

class _GestureStackTesterState extends State<GestureStackTester> {
  bool isVisible = false;

  void toggle() => setState(() => isVisible = !isVisible);

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Gesture Stack Test',
    home: Scaffold(
      body: CardsScaffold(
        configure: buildPlaceholder('backdrop', Colors.red),
        fab: FloatingActionButton.extended(
          onPressed: () => print('Starting game'),
          icon: Icon(Icons.code),
          label: Text('Start game'),
        ),
        frontCard: buildPlaceholder('content', Colors.lightGreen),
        backCard: buildPlaceholder('back card', Colors.blue),
        canStartGame: true,
        canResumeGame: true,
        onMenuTapped: () => print('Menu opened'),
        onDismissed: () => print('Card dismissed'),
      )
    )
  );
  Widget buildPlaceholder(String name, Color color) => LayoutBuilder(
    builder: (context, constraints) {
      print('Building $name');
      return Stack(
        children: [ Container(color: color), Placeholder(color: Colors.white) ]
      );
    },
  );
}



class CardsScaffoldController {
  VoidCallback _onShow, _onHide;

  _bind(VoidCallback onShow, VoidCallback onHide) {
    _onShow = onShow;
    _onHide = onHide;
  }
  show() => _onShow();
  hide() => _onHide();
}

/// A custom version of a Scaffold, adding the basic structure of this app.
/// 
/// There are customary [configure], [fab], [frontCard] and [backCard]
/// properties, that display all the widgets in the right position.
/// 
/// A bottom app bar is automatically created with the given FAB, a menu button
/// (see [onMenuTapped]) and an arrow (if [canResumeGame] is set to true).
/// 
/// Furthermore, fancy support for two different kinds of gestures is added:
/// * The stack gesture allows users to swipe up from the bottom bar of the
///   configure screen in order to resume a running game. Alternatively, they
///   can press the arrow button on the right or start a new game.
/// * The cards gesture is also built-in into the Scaffold, allowing the easy
///   dismissal of the front card. Once the card is dismissed, [onDismissed] is
///   invoked.
class CardsScaffold extends StatefulWidget {
  CardsScaffold({
    this.controller,
    @required this.configure,
    @required this.fab,
    @required this.frontCard,
    @required this.backCard,
    @required this.canStartGame,
    @required this.canResumeGame,
    @required this.onMenuTapped,
    @required this.onDismissed
  }) :
      assert(configure != null),
      assert(fab != null),
      assert(frontCard != null),
      assert(backCard != null),
      assert(canStartGame != null),
      assert(canResumeGame != null),
      assert(onMenuTapped != null),
      assert(onDismissed != null);
  
  /// The controller that can extend / hide the stack.
  final CardsScaffoldController controller;

  /// The configure screen in the background.
  final Widget configure;

  /// The floating action button at the bottom center.
  final Widget fab;

  /// The front card.
  final Widget frontCard;

  /// The back card.
  final Widget backCard;

  /// Whether the game can be started. If set to true, a click on the FAB will
  /// not only call the FAB's callback but also cause the stack to open.
  final bool canStartGame;

  /// Whether the game can be resumed. If set to true, the stack gesture is
  /// enabled and an arrow button appears on the right.
  final bool canResumeGame;

  /// A callback that's invoked when the menu item is clicked.
  final VoidCallback onMenuTapped;

  /// A callback that's invoked whenever a card is dismissed.
  final VoidCallback onDismissed;

  @override
  _CardsScaffoldState createState() => _CardsScaffoldState();
}

class _CardsScaffoldState extends State<CardsScaffold>
    with TickerProviderStateMixin {
  static const double footerHeight = 48.0;
  static const double fabHeight = 48.0;


  // Variables for the stack gesture. The stack value can reach from 0.0 (stack
  // resting and only visible as the bottom bar) to 1.0 (stack fully visible).
  double stack = 0.0;
  double stackWhenDragStarted = 0.0;
  Offset stackDragStart;
  AnimationController stackController;
  Animation<double> stackAnimation;

  // Variables for the card gesture. The card value's neutral state is
  // Offset.zero, representing a centered card.
  Offset card = Offset.zero;
  Offset cardWhenDragStarted = Offset.zero;
  Offset cardDragStart;
  bool cardWasDismissed;
  AnimationController cardController;
  Animation<Offset> cardAnimation;

  /// Initializes the animation controllers.
  void initState() {
    super.initState();
    _bindController();
    
    final duration = Duration(seconds: 2);

    stackController = AnimationController(duration: duration, vsync: this)
      ..addListener(() => setState(() {
        stack = stackAnimation?.value ?? 0.0;
      }));

    cardController = AnimationController(duration: duration, vsync: this)
      ..addListener(() => setState(() {
        card = cardAnimation?.value ?? Offset.zero;
      }))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          card = Offset.zero;
          if (cardWasDismissed) widget.onDismissed();
        }
      });
  }

  /// Disposes the animation controllers.
  void dispose() {
    stackController.dispose();
    cardController.dispose();
    super.dispose();
  }

  /// Binds the controller.
  void _bindController() {
    widget.controller?._bind(
      () => _animateStack(1.0),
      () => _animateStack(0.0)
    );
  }


  /// Starts the stack animation to the given target visibility. Uses the given
  /// velocity, if provided.
  void _animateStack(double target, { double velocity }) {
    stackAnimation = Tween(begin: stack, end: target).animate(stackController);
    stackController
      ..value = 0.0
      ..fling(velocity: velocity ?? 2.0);
  }

  /// Starts the card animation to the given target position. Uses the given
  /// velocity, if provided.
  void _animateCard(Offset target, { double velocity }) {
    cardAnimation = Tween(begin: card, end: target).animate(cardController);
    cardController
      ..value = 0.0
      ..fling(velocity: velocity ?? 2.0);
  }


  // Helping variables for rendering.
  Size get screen => MediaQuery.of(context).size;
  Rect get screenRect => Rect.fromLTWH(0.0, 0.0, screen.width, screen.height);
  double get bottomPartHeight => footerHeight + fabHeight / 2;
  double get animationHeight => screen.height - bottomPartHeight;


  // Touch handlers for a stack drag.

  void _onStackDragDown(DragDownDetails details) {
    stackDragStart = details.globalPosition;
    stackWhenDragStarted = stack;
  }

  void _onStackDragUpdate(DragUpdateDetails details) => setState(() {
    final visibilityDelta = (stackDragStart - details.globalPosition).dy
        / animationHeight;
    stack = (stackWhenDragStarted + visibilityDelta).clamp(0.0, 1.0);
  });

  void _onStackDragEnd(DragEndDetails details) {
    final dragVelocity = details.velocity.pixelsPerSecond.dy / 1000;
    final visibilityVelocity = -dragVelocity / screen.height;
    final extrapolatedVisibility = stack + visibilityVelocity * 1500;
    final targetVisibility = extrapolatedVisibility.clamp(0.0, 1.0)
        .roundToDouble();

    _animateStack(targetVisibility, velocity: dragVelocity.abs());
  }


  // Touch handlers for a card drag.

  void _onCardDragDown(DragDownDetails details) {
    cardDragStart = details.globalPosition;
    cardWhenDragStarted = card;
  }

  void _onCardDragUpdate(DragUpdateDetails details) => setState(() {
    card = cardWhenDragStarted + details.globalPosition - cardDragStart;
  });

  void _onCardDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    final thresholdDistance = screen.longestSide * sqrt(2);
    final extrapolatedPosition = card + velocity.scale(0.5, 0.5);
    cardWasDismissed = extrapolatedPosition.distance > thresholdDistance;

    _animateCard(cardWasDismissed ? extrapolatedPosition : Offset.zero,
      velocity: velocity.distance.abs() / 1000.0
    );
    // Once the animation is completed, the BLoC will be notified.
  }

  void _dismissByTapping() {
    final target = Offset(
      (Random().nextBool() ? 1 : -1) * screen.longestSide,
      0.0
    );
    cardWasDismissed = true;
    _animateCard(target, velocity: 2.0);
  }


  // The position of the bottom part (stack + FAB). Effectively top of FAB.
  Offset get bottomPartResting {
    return Offset(0.0, screen.height - bottomPartHeight);
  }
  Offset get bottomPartVisible => Offset.zero;
  Offset get bottomPartOffset {
    return Offset.lerp(bottomPartResting, bottomPartVisible, stack);
  }
  
  // The relative position from the bottom part (effectively top of FAB) to the
  // start of the stack.
  Offset get cardStackResting => Offset(0.0, fabHeight / 2);
  Offset get cardStackVisible => Offset.zero;
  Offset get cardStackOffset {
    return Offset.lerp(cardStackResting, cardStackVisible, stack);
  }

  // The size of the safe area.
  double get safeAreaSize => MediaQuery.of(context).padding.top * stack;

  // Properties of the FAB.
  double get fabScale => 1 - stack;
  double get fabOpacity => 1 - stack;

  // Properties of the menu button.
  double get menuOpacity => 1 - stack;
  bool get showMenu => menuOpacity > 0;

  // Border radius of the front card.
  BorderRadius get borderRadius => BorderRadius.circular(
    (card.distance / 100).clamp(0.0, 1.0) * 32.0
  );

  // Rotation  and rotation origin of the card.
  double get rotation => (cardDragStart == null) ? 0.0 :
      (pi / 8) * (card.dx / screenRect.width)
      * (cardDragStart.dy >= screenRect.height / 2 ? -1 : 1);
  Offset get rotationOrigin => cardDragStart == null ? Offset.zero :
      cardDragStart - screenRect.topLeft;



  @override
  Widget build(BuildContext context) {
    _bindController();

    // Back card. On top of it is a row of icons.
    final backCard = Stack(
      children: <Widget>[ widget.backCard, buildIconOverlay() ]
    );

    // Draggable front card. On top of it is a draggable row of icons.
    final frontCard = Transform(
      transform: Matrix4.translationValues(card.dx, card.dy, 0.0)
          ..rotateZ(rotation),
      origin: rotationOrigin,
      child: Stack(
        children: [
          GestureDetector(
            onPanDown: _onCardDragDown,
            onPanUpdate: _onCardDragUpdate,
            onPanEnd: _onCardDragEnd,
            onTap: _dismissByTapping,
            child: widget.frontCard
          ),
          GestureDetector(
            onPanDown: _onStackDragDown,
            onPanUpdate: _onStackDragUpdate,
            onPanEnd: _onStackDragEnd,
            child: Container(color: Colors.black38, child: buildIconOverlay())
          )
        ]
      )
    );

    // The stack of cards, translated relative to the top of the bottom part
    // (top of FAB).
    final cardStack = Transform.translate(
      offset: cardStackOffset,
      child: Stack(children: [ backCard, frontCard ])
    );

    // The FAB.
    final fab = Transform.scale(
      scale: fabScale,
      alignment: Alignment.topCenter,
      child: Container(
        height: fabHeight,
        alignment: Alignment.center,
        child: Opacity(opacity: fabOpacity, child: widget.fab)
      )
    );

    // The whole bottom part, translated relative to the display.
    final bottomPart = Transform.translate(
      offset: bottomPartOffset,
      child: Stack(children: [ cardStack, fab ])
    );

    // Everything.
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          if (stack == 0) return true;
          _animateStack(0.0);
          return false;
        },
        child: Stack(children: [ widget.configure, bottomPart ])
      )
    );
  }

  /// Builds the icon overlay, including the safe area.
  Widget buildIconOverlay() {
    final items = <Widget>[];

    // Show a menu button if the stack is not fully expanded.
    if (showMenu) {
      items.add(Opacity(
        opacity: menuOpacity,
        child: IconButton(
          icon: Icon(Icons.menu),
          color: Colors.white,
          onPressed: widget.onMenuTapped
        )
      ));
    }

    items.add(Spacer());

    // Show an arrow button if the game can be resumed.
    if (widget.canResumeGame) {
      final shouldExpand = stack == 0;
      items.add(IconButton(
        icon: Icon(
          shouldExpand ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
        ),
        color: Colors.white,
        onPressed: () => _animateStack(shouldExpand ? 1.0 : 0.0)
      ));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [ SizedBox(height: safeAreaSize), Row(children: items) ]
    );
  }
}
