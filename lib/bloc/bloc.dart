import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:rxdart/subjects.dart';
import 'generator.dart';
import 'model.dart';
import 'resource_manager.dart';


/// Is the gateway between Flutter Widgets and actual business logic, hence the
/// name.
class Bloc {
  Bloc() {
    _initialize();
  }


  /// Using this method, any widget in the tree below a BlocProvider can get
  /// access to the bloc.
  static Bloc of(BuildContext context) {
    final BlocProvider inherited = context.ancestorWidgetOfExactType(BlocProvider);
    return inherited?.bloc;
  }

  static const version = '0.0.1';
  static const _cardBufferSize = 3;


  Locale _locale;
  final List<ContentCard> _myCards = [];
  
  // Configuration of the game.
  final _players = <String>[];
  final _decks = <Deck>[];
  List<Deck> get _unlockedDecks => _decks.where((deck) => deck.isUnlocked).toList();
  List<Deck> get _selectedDecks => _decks.where((deck) => deck.isSelected).toList();
  bool get _isConfigurationValid => _players.length > 0 && _selectedDecks.length > 0;

  // Actually playing the game.
  Generator _generator;
  bool get _isGameActive => _generator != null;
  final _cards = <Card>[];
  

  // Output stream subjects.
  final _myCardsSubject = BehaviorSubject<List<ContentCard>>(seedValue: []);
  final _playersSubject = BehaviorSubject<List<String>>(seedValue: []);
  final _decksSubject = BehaviorSubject<List<Deck>>(seedValue: []);
  final _canStartSubject = BehaviorSubject<bool>(seedValue: false);
  final _canResumeSubject = BehaviorSubject<bool>(seedValue: false);
  final _frontCardSubject = BehaviorSubject<Card>(seedValue: EmptyCard());
  final _backCardSubject = BehaviorSubject<Card>(seedValue: EmptyCard());
  final _configurationMessageSubject = BehaviorSubject<String>(seedValue: '');

  // Actual output streams. Some have subjects above, others are composed.
  Stream<List<ContentCard>> get myCards => _myCardsSubject.stream;
  Stream<List<String>> get players => _playersSubject.stream;
  Stream<List<Deck>> get decks => _decksSubject.stream;
  Stream<List<Deck>> get unlockedDecks => decks
      .map((decks) => decks.where((deck) => deck.isUnlocked).toList());
  Stream<List<Deck>> get selectedDecks => decks
      .map((decks) => decks.where((deck) => deck.isSelected).toList());
  Stream<bool> get canStart => _canStartSubject.stream.distinct();
  Stream<bool> get canResume => _canResumeSubject.stream.distinct();
  Stream<Card> get frontCard => _frontCardSubject.stream.distinct();
  Stream<Card> get backCard => _backCardSubject.stream.distinct();
  Stream<String> get configurationMessage => _configurationMessageSubject.stream.distinct();


  void _initialize() async {
    print('Initializing the BLoC.');

    // Update UI if configuration changes.
    players.listen((_) => _updateConfigurationValidity());
    decks.listen((_) => _updateConfigurationValidity());

    // Load players. Once loaded, further changes to players should be saved.
    _players.addAll(await ResourceManager.loadPlayers());
    _playersSubject.add(_players);
    players.listen((players) => ResourceManager.savePlayers(players));
    print('Players loaded: $_players');

    // TODO: load language.
    _locale = Locale('de');

    // Load decks of that language.
    final List<Deck> loadedDecks = await ResourceManager.getDecks(_locale);
    _decks.clear();
    _decks.addAll(loadedDecks);
    _decksSubject.add(_decks);

    // TODO: get unlocked decks.

    // Load selected decks.
    final List<String> selected = await ResourceManager.loadSelectedDecks();
    for (final deck in _decks) {
      deck.isSelected = selected.contains(deck.id);
    }
    _updateConfigurationValidity();
    selectedDecks.listen((decks) => ResourceManager.saveSelectedDecks(decks));

    // Load player's custom cards.
    _myCards.addAll(await ResourceManager.loadMyCards());
    _myCardsSubject.add(_myCards);
    myCards.listen((myCards) => ResourceManager.saveMyCards(myCards));
  }

  void addPlayer(String player) {
    _players.add(player);
    _playersSubject.add(_players);
  }

  void removePlayer(String player) {
    _players.remove(player);
    _playersSubject.add(_players);
  }

  void selectDeck(Deck deck) {
    deck.isSelected = true;
    _decksSubject.add(_decks);
  }

  void deselectDeck(Deck deck) {
    deck.isSelected = false;
    _decksSubject.add(_decks);
  }

  void _updateConfigurationValidity() {
    _canStartSubject.add(_isConfigurationValid);
    _canResumeSubject.add(_isConfigurationValid && _isGameActive);
    _configurationMessageSubject.add(
      _players.length == 0 ? 'To get started, add a player.' :
      _selectedDecks.length == 0 ? 'Select at least one deck.' : ''
    );
  }

  void start() {
    print('Starting the game.');
    if (_isConfigurationValid) {
      _cards.clear();
      _generator = Generator();
      _canResumeSubject.add(_isGameActive);
      _fillStack();
    }
  }

  void nextCard() {
    if (_cards.length > 0)
      _cards.removeAt(0);

    _notifyCards();
    _fillStack();
  }

  void _fillStack() {
    if (_cards.length >= _cardBufferSize)
      return;

    _generator.generateCard(
      decks: _selectedDecks,
      players: _players
    ).then((Card card) {
      print('Card generated: $card');
      _cards.add(card);
      _notifyCards();
      _fillStack();
    });
  }

  void _notifyCards() {
    final len = _cards.length;
    _frontCardSubject.add(len > 0 ? _cards[0] : null);
    _backCardSubject.add(len > 1 ? _cards[1] : null);
  }

  /// Creates a new card for the user to fill with content.
  ContentCard writeNewCard() {
    final myCardIds = _myCards.map((card) => card.id).toSet();
    var id;
    for (int i = 0;; i++) {
      id = 'my_$i';
      if (!myCardIds.contains(id))
        break;
    }

    final card = ContentCard(
      id: id,
      content: '',
      color: '#FFFFFF'
    );
    _myCards.add(card);
    _myCardsSubject.add(_myCards);
    return card;
  }

  void updateMyCard(ContentCard card) {
    final oldVersion = _myCards.singleWhere((myCard) => myCard.id == card.id);
    _myCards.remove(oldVersion);
    _myCards.add(card);
    _myCardsSubject.add(_myCards);
  }

  void dispose() {
    _playersSubject.close();
    _decksSubject.close();
    _canStartSubject.close();
    _frontCardSubject.close();
    _backCardSubject.close();
    _configurationMessageSubject.close();
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
