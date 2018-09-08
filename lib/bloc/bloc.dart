import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:rxdart/subjects.dart';
import 'generator.dart';
import 'model.dart';
import 'resource_manager.dart';

class Bloc {
  Bloc() {
    _initialize();
  }

  void _initialize() async {
    print('Initializing the BLoC.');
    _updateConfigurationUI();

    final List<String> players = await ResourceManager.loadPlayers();
    _players.addAll(players);
    _updateConfigurationUI(playersUpdated: true);

    print('Getting the decks.');
    final List<Deck> decks = await ResourceManager.getDecks(language: 'de');
    _decks.clear();
    _decks.addAll(decks);
    _decksSubject.add(_decks);

    final List<String> selectedDecks = await ResourceManager.loadSelectedDecks();
    print('Selected decks are $selectedDecks');
    for (final deck in _decks) {
      deck.isSelected = selectedDecks.contains(deck.id);
    }
    _updateConfigurationUI(decksUpdated: true);
  }

  static Bloc of(BuildContext context) {
    final BlocProvider inherited = context.ancestorWidgetOfExactType(BlocProvider);
    return inherited?._bloc;
  }

  static const _cardBufferSize = 3;

  final _players = <String>[];
  final _decks = <Deck>[];
  final _cards = <Card>[];
  Generator _generator;

  bool get _isGameActive => _generator != null;
  List<Deck> get _selectedDecks => _decks.where((deck) => deck.isSelected).toList();
  bool get _isConfigurationValid => _players.length > 0 && _selectedDecks.length > 0;
  
  // Output streams.
  final _playersSubject = BehaviorSubject<List<String>>(seedValue: []);
  final _decksSubject = BehaviorSubject<List<Deck>>(seedValue: []);
  final _isConfigurationValidSubject = BehaviorSubject<bool>(seedValue: false);
  final _canResumeSubject = BehaviorSubject<bool>(seedValue: false);
  final _frontCardSubject = BehaviorSubject<Card>(seedValue: EmptyCard());
  final _backCardSubject = BehaviorSubject<Card>(seedValue: EmptyCard());
  final _configurationMessageTextSubject = BehaviorSubject<String>(seedValue: '');
  Stream<List<String>> get players => _playersSubject.stream;
  Stream<List<Deck>> get decks => _decksSubject.stream;
  Stream<bool> get isConfigurationValid => _isConfigurationValidSubject.stream;
  Stream<bool> get canResume => _canResumeSubject.stream;
  Stream<Card> get frontCard => _frontCardSubject.stream;
  Stream<Card> get backCard => _backCardSubject.stream;
  Stream<String> get configurationMessageText => _configurationMessageTextSubject.stream;

  void addPlayer(String player) {
    print('Adding player $player');
    _players.add(player);
    _updateConfigurationUI(playersUpdated: true);
  }

  void removePlayer(String player) {
    _players.remove(player);
    _updateConfigurationUI(playersUpdated: true);
  }

  void selectDeck(Deck deck) {
    deck.isSelected = true;
    _updateConfigurationUI(decksUpdated: true);
  }

  void deselectDeck(Deck deck) {
    deck.isSelected = false;
    _updateConfigurationUI(decksUpdated: true);
  }

  void _updateConfigurationUI({ bool playersUpdated = false, bool decksUpdated = false }) {
    if (playersUpdated) {
      _playersSubject.add(_players);
      ResourceManager.savePlayers(_players);
    }
    if (decksUpdated) {
      _decksSubject.add(_decks);
      ResourceManager.saveSelectedDecks(_selectedDecks);
    }

    _updateConfigurationMessageText();
    _isConfigurationValidSubject.add(_isConfigurationValid);
    _canResumeSubject.add(_isConfigurationValid && _isGameActive);
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

  void _updateConfigurationMessageText() {
    _configurationMessageTextSubject.add(
      _players.length == 0 ? 'To get started, add a player.' :
      _selectedDecks.length == 0 ? 'Select at least one deck.' : ''
    );
  }

  void dispose() {
    _playersSubject.close();
    _decksSubject.close();
    _isConfigurationValidSubject.close();
    _frontCardSubject.close();
    _backCardSubject.close();
    _configurationMessageTextSubject.close();
  }
}

class BlocProvider extends StatelessWidget {
  BlocProvider({ @required this.child }) : assert(child != null);
  
  final Widget child;
  final Bloc _bloc = Bloc();

  @override
  Widget build(BuildContext context) => child;
}
