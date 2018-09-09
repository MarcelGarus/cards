import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart' hide Card;
import 'bloc/bloc.dart';
import 'bloc/model.dart';
import 'home.dart';
import 'menu.dart';
import 'raw_card.dart';

void main() => runApp(CardsGame());

class CardsGame extends StatefulWidget {
  @override
  _CardsGameState createState() => _CardsGameState();
}

class _CardsGameState extends State<CardsGame> {
  final Bloc bloc = Bloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: bloc,
      child: MaterialApp(
        title: 'Cards',
        theme: ThemeData(
          backgroundColor: Colors.white,
          primaryColor: Colors.black,
          accentColor: Colors.amber,
          fontFamily: 'Assistant',
          primarySwatch: Colors.blue,
        ),
        home: MainPage(),
      )
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  static const double appBarHeight = 48.0;
  static const double fabHeight = 48.0;

  Offset _dragStart = Offset.zero;
  bool _isVisibilityDrag = false;

  double _stackVisibility = 0.0;
  bool get _isStackVisible => _stackVisibility > 0;
  bool get _isStackFullyVisible => _stackVisibility == 1;
  double _stackVisibilityWhenDragStarted = 0.0;
  AnimationController _stackVisibilityController;
  Animation<double> _stackVisibilityAnimation;

  Offset _cardPosition = Offset.zero;
  Offset _cardPositionWhenDragStarted = Offset.zero;
  bool _cardWasDismissed = false;
  AnimationController _cardPositionController;
  Animation<Offset> _cardPositionAnimation;

  @override
  void initState() {
    super.initState();
    print('Initializing state.');
    _stackVisibilityController = AnimationController(vsync: this, duration: Duration(seconds: 2))
      ..addListener(() => setState(() {
        _stackVisibility = _stackVisibilityAnimation?.value ?? 0.0;
      }));
    _cardPositionController = AnimationController(vsync: this, duration: Duration(seconds: 2))
      ..addListener(() => setState(() {
        _cardPosition = _cardPositionAnimation?.value ?? Offset.zero;
      }))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _cardPosition = Offset.zero;

          if (_cardWasDismissed)
            Bloc.of(context).nextCard();
        }
      });
  }

  @override
  void dispose() {
    _stackVisibilityController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final isStackVisible = _isStackVisible;

    if (isStackVisible)
      _hideStack(context);
    
    return !isStackVisible;
  }

  void _animateStack(double targetVisibility, { double velocity }) {
    _stackVisibilityAnimation = Tween<double>(begin: _stackVisibility, end: targetVisibility)
      .animate(_stackVisibilityController);
    _stackVisibilityController
      ..value = 0.0
      ..fling(velocity: velocity ?? 2.0);
  }

  void _animateCard(Offset targetPosition, { double velocity }) {
    _cardPositionAnimation = Tween<Offset>(begin: _cardPosition, end: targetPosition)
      .animate(_cardPositionController);
    _cardPositionController
      ..value = 0.0
      ..fling(velocity: velocity ?? 2.0);
  }

  void _showStack(BuildContext context) {
    _animateStack(1.0);
    _start(context);
  }

  void _hideStack(BuildContext context) => _animateStack(0.0);

  void _toggleStackVisibility() => _animateStack(_isStackVisible ? 0.0 : 1.0);

  void _start(BuildContext context) {
    Bloc.of(context).start();
    _toggleStackVisibility();
  }

  void _handleDragDown(BuildContext context, DragDownDetails details) {
    _dragStart = details.globalPosition;
    _isVisibilityDrag = !_isStackFullyVisible || _dragStart.dy < MediaQuery.of(context).padding.top + appBarHeight;

    if (_isVisibilityDrag) {
      _stackVisibilityWhenDragStarted = _stackVisibility;
    } else {
      _cardPositionWhenDragStarted = _cardPosition;
    }
  }

  void _handleDragUpdate(BuildContext context, DragUpdateDetails details) {
    if (_isVisibilityDrag) {
      final movingLength = MediaQuery.of(context).size.height;
      final yDelta = _dragStart.dy - details.globalPosition.dy;
      setState(() {
        _stackVisibility = (_stackVisibilityWhenDragStarted + yDelta / movingLength).clamp(0.0, 1.0);
      });
    } else {
      setState(() {
        _cardPosition = _cardPositionWhenDragStarted + details.globalPosition - _dragStart;
      });
    }
  }

  void _handleDragEnd(BuildContext context, DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dy / 1000;

    if (_isVisibilityDrag) {
      final movingLength = MediaQuery.of(context).size.height;
      final visibilityVelocity = -velocity / movingLength;
      final extrapolatedVisibility = _stackVisibility + visibilityVelocity * 1500;
      final targetVisibility = extrapolatedVisibility.clamp(0.0, 1.0).roundToDouble();

      _animateStack(targetVisibility, velocity: velocity.abs());
    } else {
      final thresholdDistance = MediaQuery.of(context).size.longestSide * sqrt(2);
      final velocityOffset = details.velocity.pixelsPerSecond.scale(0.5, 0.5);
      final extrapolatedPosition = _cardPosition + velocityOffset;
      _cardWasDismissed = extrapolatedPosition.distance > thresholdDistance;

      _animateCard(_cardWasDismissed ? extrapolatedPosition : Offset.zero, velocity: velocity.abs());
      // Once the animation is completed, the BLoC will be notified.
    }
  }

  Offset _bottomPartPosition(BuildContext context) {
    final animateHeight = MediaQuery.of(context).size.height - appBarHeight - fabHeight / 2;
    return Offset(0.0, (1 - _stackVisibility) * animateHeight);
  }

  Offset _stackOffset(BuildContext context) {
    return Offset(0.0, (1 - _stackVisibility) * fabHeight / 2);
  }

  BorderRadius _borderRadius(BuildContext context) {
    final radius = (_cardPosition.distance / 100).clamp(0.0, 1.0) * 32.0;
    return BorderRadius.all(Radius.circular(radius));
  }

  double _safeAreaTopSize(BuildContext context) {
    final safeAreaTop = MediaQuery.of(context).padding.top;
    return _stackVisibility * safeAreaTop;
  }

  double _rotation(Rect dragBounds) {
    if (_dragStart != null) {
      final rotationCornerMultiplier = _dragStart.dy >= dragBounds.top + (dragBounds.height / 2) ? -1 : 1;
      return (pi / 8) * (_cardPosition.dx / dragBounds.width) * rotationCornerMultiplier;
    } else {
      return 0.0;
    }
  }

  Offset _rotationOrigin(Rect dragBounds) {
    return _dragStart == null ? Offset.zero : _dragStart - dragBounds.topLeft;
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(context: context, builder: (context) {
      return Menu();
    });
  }

  @override
  Widget build(BuildContext context) {
    final translatedBottomPart = Transform.translate(
      offset: _bottomPartPosition(context),
      child: _buildBottomPart(context)
    );
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(children: <Widget>[ HomePage(), translatedBottomPart ])
      )
    );
  }

  /// Builds the bottom part.
  Widget _buildBottomPart(BuildContext context) {
    final fab = StreamBuilder(
      stream: Bloc.of(context).canStart,
      builder: (context, snapshot) => _buildFab(context, snapshot.data ?? false)
    );
    return Stack(
      children: <Widget> [
        Transform.translate(
          offset: _stackOffset(context),
          child: _buildCardStack(context)
        ),
        Container(
          alignment: Alignment.center,
          height: fabHeight,
          child: Transform.scale(
            scale: 1.0 - _stackVisibility,
            alignment: Alignment.topCenter,
            child: Opacity(opacity: 1.0 - _stackVisibility, child: fab)
          )
        )
      ]
    );
  }

  /// Displays a FAB if the game can start, otherwise just an
  /// instructive message.
  Widget _buildFab(BuildContext context, bool canStart) {
    print('Can start? $canStart');
    if (canStart) {
      return FloatingActionButton.extended(
        icon: Image.asset('graphics/style192.png', width: 24.0, height: 24.0),
        label: Text('Start playing',
          style: TextStyle(fontSize: 20.0, letterSpacing: -0.5)
        ),
        onPressed: () => _start(context),
      );
    } else {
      return Material(
        shape: StadiumBorder(),
        elevation: 6.0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          color: Colors.black,
          child: StreamBuilder(
            stream: Bloc.of(context).configurationMessage,
            builder: (context, snapshot) {
              return Text(snapshot.data ?? '',
                style: TextStyle(color: Colors.white)
              );
            },
          )
        )
      );
    }
  }

  /// Builds a stack of cards.
  Widget _buildCardStack(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final screenRect = Rect.fromLTWH(0.0, 0.0, screen.width, screen.height);
    final bloc = Bloc.of(context);

    final backCard = _buildCardStreamBuilder(context, bloc.backCard, false);
    final frontCard = _buildCardStreamBuilder(context, bloc.frontCard, true);

    return Stack(
      children: <Widget>[
        backCard,
        Transform(
          transform: Matrix4
              .translationValues(_cardPosition.dx, _cardPosition.dy, 0.0)
              ..rotateZ(_rotation(screenRect)),
          origin: _rotationOrigin(screenRect),
          child: StreamBuilder(
            stream: bloc.canResume,
            builder: (context, snapshot) {
              final isGameActive = snapshot.data ?? false;
              return isGameActive ? GestureDetector(
                onPanDown: (details) => _handleDragDown(context, details),
                onPanUpdate: (details) => _handleDragUpdate(context, details),
                onPanEnd: (details) => _handleDragEnd(context, details),
                child: frontCard
              ) : frontCard;
            },
          )
        ),
      ],
    );
  }

  /// Builds cards from a stream.
  Widget _buildCardStreamBuilder(BuildContext context, Stream<Card> stream, bool isFrontCard) {
    return StreamBuilder<Card>(
      stream: stream,
      builder: (context, snapshot) {
        return _buildCard(context, snapshot.data, isFrontCard);
      }
    );
  }

  /// Builds the given card.
  Widget _buildCard(BuildContext context, Card card, bool isFrontCard) {
    final leading = _isStackFullyVisible || !isFrontCard ? Container()
    : Opacity(
      opacity: 1 - _stackVisibility,
      child: IconButton(
        icon: Icon(Icons.menu),
        color: Colors.white,
        onPressed: () {
          _showMenu(context);
        }
      ),
    );

    final following = StreamBuilder(
      stream: Bloc.of(context).canResume,
      builder: (context, snapshot) {
        // If the game is active, show an arrow icon button, otherwise nothing.
        return !(snapshot.data ?? false)
          ? Container()
          : IconButton(
            icon: Icon(_isStackVisible ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up),
            color: Colors.white,
            onPressed: () => setState(_toggleStackVisibility)
          );
      },
    );

    return RawCard(
      card: card ?? EmptyCard(),
      borderRadius: isFrontCard ? _borderRadius(context) : BorderRadius.zero,
      safeAreaTop: _safeAreaTopSize(context),
      leading: leading,
      following: following,
    );
  }
}
