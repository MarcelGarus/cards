import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:rxdart/subjects.dart';
import 'model.dart';
import 'coins_bloc.dart';
import 'locale_bloc.dart';
import 'players_bloc.dart';
import 'decks_bloc.dart';
import 'my_cards_bloc.dart';
import 'game_bloc.dart';

enum TextId {
  none,
  app_title,

  add_player_label,
  add_player_hint,
  add_player_error,

  configuration_player_missing,
  configuration_deck_missing,
  start_game,

  beta_box_title,
  beta_box_body,
  beta_box_action,

  menu_log_in,
  menu_log_in_text,
  menu_my_cards,
  menu_settings,
  menu_feedback,

  mail_subject,
  mail_body,

  coin_card,
  game_card_author
}


/// The gateway between Flutter Widgets and actual business logic.
/// Handles composition of the configuration.
class Bloc {
  Bloc() {
    _initialize();
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
  Stream<Locale> get locale => localeBloc.localeSubject.stream;
  Stream<BigInt> get coins => coinsBloc.coinsSubject.stream;
  Stream<List<String>> get players => playersBloc.playersSubject.stream;
  Stream<List<Deck>> get decks => decksBloc.decksSubject.stream;
  Stream<List<Deck>> get unlockedDecks => decksBloc
      .unlockedDecksSubject
      .stream;
  Stream<List<Deck>> get selectedDecks => decksBloc
      .selectedDecksSubject
      .stream;
  Stream<List<GameCard>> get myCards => myCardsBloc.myCardsSubject.stream;
  Stream<Configuration> get configuration => _configurationSubject.stream;
  Stream<bool> get canResume => _canResumeSubject.stream;
  Stream<Card> get frontCard => gameBloc.frontCardSubject.stream.distinct();
  Stream<Card> get backCard => gameBloc.backCardSubject.stream;


  void _initialize() async {
    print('Initializing the BLoC.');

    localeBloc.initialize().catchError(print);
    playersBloc.initialize().catchError(print);
    decksBloc.initialize(localeBloc.locale).catchError(print);
    myCardsBloc.initialize().catchError(print);

    locale.listen((locale) {
      decksBloc.initialize(locale);
      gameBloc.stop();
    });
    players.listen((players) => _updateConfiguration());
    selectedDecks.listen((decks) => _updateConfiguration());
    myCards.listen((cards) => _updateConfiguration());
    configuration.listen((config) => _updateCanResume());
    frontCard
        .where((card) => card is CoinCard)
        .listen((card) => coinsBloc.findCoin());
  }

  void dispose() {
    _configurationSubject.close();
    _canResumeSubject.close();
  }

  void _updateConfiguration() {
    _configuration = Configuration(
      players: playersBloc.players ?? [],
      decks: decksBloc.selectedDecks ?? [],
      myCards: myCardsBloc.myCards ?? []
    );
    _configurationSubject.add(_configuration);
  }

  void _updateCanResume() async {
    _canResumeSubject.add(_configuration.isValid && gameBloc.isActive);
  }


  void updateLocale(Locale locale) => localeBloc.updateLocale(locale);

  String getText(TextId id) => localeBloc.getText(id);

  void canBuy(Deck deck) => coinsBloc.canBuy(deck);

  void buy(Deck deck) {
    coinsBloc.buy(deck);
    decksBloc.buy(deck);
  }

  bool isPlayerInputErroneous(String player) => playersBloc.isPlayerInputErroneous(player);

  bool isPlayerInputValid(String player) => playersBloc.isPlayerInputValid(player);

  void addPlayer(String player) => playersBloc.addPlayer(player);
  
  void removePlayer(String player) => playersBloc.removePlayer(player);
  
  void selectDeck(Deck deck) => decksBloc.selectDeck(deck);
  
  void deselectDeck(Deck deck) => decksBloc.deselectDeck(deck);
  
  GameCard createNewCard() => myCardsBloc.createNewCard();
  
  void updateCard(GameCard card) => myCardsBloc.updateCard(card);
  
  void deleteCard(GameCard card) => myCardsBloc.deleteCard(card);
  
  void start() async {
    print('Starting the game.');

    if (_configuration.isValid) {
      print('Configuration is valid. Starting gameBloc.');
      gameBloc.start(_configuration);
      _updateCanResume();
    }
  }
  
  void nextCard() async => gameBloc.nextCard(_configuration);
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
