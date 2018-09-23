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
  CardsScaffoldController controller = CardsScaffoldController();

  void _showMenu() {
    showModalBottomSheet(context: context, builder: (_) => Menu());
  }

  void _startGame() {
    Bloc.of(context).start();
    controller.show();
  }

  @override
  Widget build(BuildContext context) {
    return CardsScaffold(
      controller: controller,
      configure: ConfigureScreen(),
      fab: _buildStreamedFab(),
      frontCard: _buildStreamedCard(true),
      backCard: _buildStreamedCard(false),
      canStartGame: true,
      canResumeGame: true,
      onMenuTapped: _showMenu,
      onDismissed: Bloc.of(context).nextCard,
    );
  }

  /// Displays a functioning FAB if the game can start, otherwise just an
  /// instructive message.
  Widget _buildStreamedFab() {
    return StreamBuilder(
      stream: Bloc.of(context).configuration,
      builder: (context, AsyncSnapshot<Configuration> snapshot) {
        if (!snapshot.hasData)
          return Container();

        if (snapshot.data.isValid) {
          return FloatingActionButton.extended(
            icon: Image.asset('graphics/style192.png', width: 24.0, height: 24.0),
            label: LocalizedText(
              id: TextId.start_game,
              style: TextStyle(fontSize: 20.0, letterSpacing: -0.5)
            ),
            onPressed: () => _startGame(),
          );
        }

        final hintTextId =
          snapshot.data.isPlayerMissing ? TextId.configuration_player_missing :
          snapshot.data.isDeckMissing ? TextId.configuration_deck_missing :
          TextId.none;

        return Material(
          shape: StadiumBorder(),
          elevation: 6.0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: Colors.black,
            child: LocalizedText(id: hintTextId, style: TextStyle(color: Colors.white))
          )
        );
      },
    );
  }

  /// Builds cards from a stream.
  Widget _buildStreamedCard(bool frontCard) {
    final bloc = Bloc.of(context);
    return StreamBuilder<Card>(
      stream: frontCard ? bloc.frontCard : bloc.backCard,
      builder: (context, snapshot) {
        print('Building card ${snapshot.data}.');
        return FullscreenCard(
          card: snapshot.data ?? EmptyCard(),
        );
      }
    );
  }
}
