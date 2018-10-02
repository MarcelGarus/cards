import 'package:flutter/material.dart' hide Card;
import 'package:flutter/services.dart';
import 'bloc/bloc.dart';
import 'cards/fullscreen_card.dart';
import 'configure/configure.dart';
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarIconBrightness: Brightness.light
    ));

    return BlocProvider(
      bloc: bloc,
      child: MaterialApp(
        title: 'Cards',
        theme: Utils.mainTheme,
        home: MainPage()
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
            label: LocalizedText(TextId.start_game,
              style: TextStyle(fontSize: 20.0, letterSpacing: -0.5, fontFamily: 'Signature')
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
          color: Colors.black,
          elevation: 6.0,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: LocalizedText(hintTextId, style: TextStyle(color: Colors.white))
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
        return FullscreenCard(
          card: snapshot.data ?? EmptyCard(),
          safeAreaTop: MediaQuery.of(context).padding.top + 48.0,
        );
      }
    );
  }
}
