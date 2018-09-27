import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:rxdart/subjects.dart';
import 'account_bloc.dart';
import 'coins_bloc.dart';
import 'decks_bloc.dart';
import 'game_bloc.dart';
import 'locale_bloc.dart';
import 'model.dart';
import 'my_cards_bloc.dart';
import 'players_bloc.dart';

export 'locale_bloc.dart';
export 'account_bloc.dart';


/// The gateway between Flutter Widgets and actual business logic.
/// Handles composition of the configuration.
class Bloc {
  Bloc() {
    _initialize().catchError((e) {
      print('An error occurred when initializing the BloC: $e');
    });
  }

  /// Using this method, any widget in the tree below a BlocProvider can get
  /// access to the bloc.
  static Bloc of(BuildContext context) {
    final BlocProvider inherited = context
        .ancestorWidgetOfExactType(BlocProvider);
    return inherited?.bloc;
  }

  static const version = '0.0.1';

  // The blocs.
  final localeBloc = LocaleBloc();
  final accountBloc = AccountBloc();
  final coinsBloc = CoinsBloc();
  final playersBloc = PlayersBloc();
  final decksBloc = DecksBloc();
  final myCardsBloc = MyCardsBloc();
  final gameBloc = GameBloc();

  // The current configuration.
  Configuration _configuration;

  // Output stream subjects.
  final _configurationSubject = BehaviorSubject<Configuration>();
  final _canResumeSubject = BehaviorSubject<bool>(seedValue: false);

  // Actual output streams. Some have subjects above.
  Stream<Localizer> get localizer => localeBloc.localizerSubject.stream.distinct();
  Stream<AccountState> get account => accountBloc.accountSubject.stream;
  Stream<BigInt> get coins => coinsBloc.coinsSubject.stream;
  Stream<List<String>> get players => playersBloc.playersSubject.stream;
  Stream<List<Deck>> get decks => decksBloc.decksSubject.stream;
  Stream<List<MyCard>> get myCards => myCardsBloc.myCardsSubject.stream;
  Stream<Configuration> get configuration => _configurationSubject.stream;
  Stream<bool> get canResume => _canResumeSubject.stream;
  Stream<Card> get frontCard => gameBloc.frontCardSubject.stream.distinct();
  Stream<Card> get backCard => gameBloc.backCardSubject.stream;


  /// Initializes the bloc by initializing sub-blocs and listening to streams
  /// in order to update and notify necessary sub-blocs.
  Future<void> _initialize() async {
    print('Initializing the BLoC.');

    // Initialize all the sub-blocs.
    localeBloc.initialize().catchError(print);
    accountBloc.initialize().catchError(print);
    coinsBloc.initialize().catchError(print);
    playersBloc.initialize().catchError(print);
    decksBloc.initialize(localeBloc.locale).catchError(print);
    myCardsBloc.initialize().catchError(print);

    // Load new decks and stop the game if the locale changes.
    localizer.listen((localizer) {
      decksBloc.initialize(localizer.locale).catchError(print);
      gameBloc.stop();
    });

    // Update decks if user-generated cards change.
    myCards.listen((myCards) {
      decksBloc.updateShowMyDeck(myCardsBloc.providesCardsForGame);
    });

    // Update configuration if players or selected decks change.
    players.listen((players) => _updateConfiguration());
    decks.listen((decks) => _updateConfiguration());

    configuration.listen((config) => _updateCanResume());
    frontCard
        .where((card) => card is CoinCard)
        .listen((card) => coinsBloc.findCoin());
  }


  /// Closes all subjects.
  void dispose() {
    localeBloc.dispose();
    accountBloc.dispose();
    coinsBloc.dispose();
    playersBloc.dispose();
    decksBloc.dispose();
    myCardsBloc.dispose();
    gameBloc.dispose();

    _configurationSubject.close();
    _canResumeSubject.close();
  }

  void _updateConfiguration() {
    try {
      _configuration = Configuration(
        players: playersBloc.players ?? [],
        decks: decksBloc.selectedDecks ?? [],
        myCards: myCardsBloc.cardsForGame ?? []
      );
      _configurationSubject.add(_configuration);
    } catch (e) {
      print(e);
    }
  }

  void _updateCanResume() async {
    _canResumeSubject.add(_configuration.isValid && gameBloc.isActive);
  }


  // The following methods are entry-points for the UI.

  // Managing the locale.
  void updateLocale(Locale locale) => localeBloc.updateLocale(locale);

  // Managing the account.
  void signIn() => accountBloc.signIn().catchError((e) {
    print('Oops! An error occurred while signing in: $e');
  });
  void signOut() => accountBloc.signOut().catchError((e) {
    print('Oops! An error occurred while signing in: $e');
  });

  // Managing the players.
  void addPlayer(String player) => playersBloc.addPlayer(player);
  void removePlayer(String player) => playersBloc.removePlayer(player);
  bool isPlayerInputErroneous(String player) {
    return playersBloc.isPlayerInputErroneous(player);
  }
  bool isPlayerInputValid(String player) {
    return playersBloc.isPlayerInputValid(player);
  }

  // Managing the decks.
  void canBuy(Deck deck) => coinsBloc.canBuy(deck);
  void buy(Deck deck) {
    coinsBloc.buy(deck);
    decksBloc.buy(deck);
  }
  void selectDeck(Deck deck) => decksBloc.selectDeck(deck);
  void deselectDeck(Deck deck) => decksBloc.deselectDeck(deck);
  
  // Playing the game.
  void start() {
    assert(_configuration.isValid);

    print('Starting the game.');
    gameBloc.start(_configuration);
    _updateCanResume();
  }
  void nextCard() => gameBloc.nextCard(_configuration);

  // Management of user-generated cards.
  MyCard createCard() => myCardsBloc.create();
  void updateCard(MyCard card) => myCardsBloc.update(card);
  void deleteCard(MyCard card) => myCardsBloc.delete(card);
  void publishCard(MyCard card) {
    myCardsBloc.publish(card, accountBloc.account.email);
  }
}

class BlocProvider extends StatelessWidget {
  BlocProvider({ @required this.bloc, @required this.child }) :
      assert(bloc != null),
      assert(child != null);
  
  final Widget child;
  final Bloc bloc;

  @override
  Widget build(BuildContext context) => child;
}
