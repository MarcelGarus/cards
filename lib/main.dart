import 'dart:async';
import 'package:flutter/material.dart' hide Card;
import 'bloc/bloc.dart';
import 'bloc/model.dart';
import 'cards/fullscreen_card.dart';
import 'configure.dart';
import 'localize.dart';
import 'menu.dart';
import 'utils.dart';
import 'cards_scaffold.dart';

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
          primaryColor: Colors.amber,
          brightness: Brightness.dark,
        ),
        home: Theme(
          data: Utils.buildLightTheme(),
          child: MainPage()
        ),
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
  void _showMenu() {
    showModalBottomSheet(context: context, builder: (_) => Menu());
  }

  Widget buildPlaceholder(String name, Color color) => LayoutBuilder(
    builder: (context, constraints) {
      print('Building $name');
      return Stack(
        children: [ Container(color: color), Placeholder(color: Colors.white) ]
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return CardsScaffold(
      configure: ConfigureScreen(),
      extendedFab: FloatingActionButton.extended(
        onPressed: () => print('Starting game'),
        icon: Icon(Icons.code),
        label: Text('Start game'),
      ), //(snapshot),
      frontCard: _buildCardStreamBuilder(true),
      backCard: _buildCardStreamBuilder(false),
      canStartGame: true,
      canResumeGame: true,
      onMenuTapped: _showMenu,
      onDismissed: () {},
    );
  }

  /*/// Displays a FAB if the game can start, otherwise just an
  /// instructive message.
  Widget _buildFab(AsyncSnapshot<Configuration> snapshot) {
    final config = snapshot.data;

    if (config == null) return Container();

    if (config.isValid) {
      return FloatingActionButton.extended(
        icon: Image.asset('graphics/style192.png', width: 24.0, height: 24.0),
        label: LocalizedText(
          id: TextId.start_game,
          style: TextStyle(fontSize: 20.0, letterSpacing: -0.5)
        ),
        onPressed: () => _start(context),
      );
    }
    
    final hintText = LocalizedText(
      id: config == null ? TextId.none :
          config.isPlayerMissing ? TextId.configuration_player_missing :
          config.isDeckMissing ? TextId.configuration_deck_missing :
          TextId.none,
      style: TextStyle(color: Colors.white)
    );

    return Material(
      shape: StadiumBorder(),
      elevation: 6.0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: Colors.black,
        child: hintText
      )
    );
  }

  /// Builds a stack of cards.
  Widget _buildCardStack(BuildContext context) {
    
    return Stack(
      children: <Widget>[
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
  }*/

  /// Builds cards from a stream.
  Widget _buildCardStreamBuilder(bool frontCard) {
    final bloc = Bloc.of(context);
    return StreamBuilder<Card>(
      stream: frontCard ? bloc.frontCard : bloc.backCard,
      builder: (context, snapshot) {
        return FullscreenCard(
          card: snapshot.data ?? EmptyCard(),
        );
      }
    );
  }
}
