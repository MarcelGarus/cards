import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:rxdart/rxdart.dart';
import 'model.dart';

/// This class keeps track of the scheduling the followup of the given card.
class _Cooldown {
  _Cooldown({ @required this.card }) :
      assert(card != null);

  /// The original card which has already been given out.
  final GameCard card;

  /// How long it takes before the followup is given out.
  int _countdown = 5 + Random().nextInt(7);
  bool get isDone => _countdown == 0;

  /// Counts down by 1.
  void countdown() => _countdown = max(0, _countdown - 1);
}



class GameBloc {
  static const _cardBufferSize = 3;

  List<Card> cards;
  bool get isActive => cards != null;

  Generator _generator = Generator();

  final frontCardSubject = BehaviorSubject<Card>(seedValue: EmptyCard());
  final backCardSubject = BehaviorSubject<Card>(seedValue: EmptyCard());


  void start(Configuration config) {
    print('Initializing the deck and filling the stack.');
    cards = [];
    _generator.initialize();
    _fillStack(config).catchError((e) {
      print('An error occurred while filling the stack: $e');
    });
  }

  void dispose() {
    frontCardSubject.close();
    backCardSubject.close();
  }

  void stop() => cards = null;

  void nextCard(Configuration config) async {
    assert(config != null);

    if (cards.length > 0)
      cards.removeAt(0);

    print('Current: ${cards[0]}.');
    _updateSubjects();
    _fillStack(config).catchError((e) {
      print('An error occurred while filling the stack: $e');
    });
  }

  Future<void> _fillStack(Configuration config) async {
    while (cards.length < _cardBufferSize) {
      await _generator.generateCard(config).then((card) {
        print('Generated: $card.');
        cards.add(card);
        _updateSubjects();
      }).catchError((e) {
        print('An error occurred while generating a card: $e');
      });
    }
  }

  void _updateSubjects() {
    frontCardSubject.add(cards.length > 0 ? cards[0] : null);
    backCardSubject.add(cards.length > 1 ? cards[1] : null);
  }
}

class Generator {
  List<Deck> _lastTurnDecks;
  Set<Deck> _decksToIntroduce;
  List<_Cooldown> _cooldowns;

  void initialize() {
    _lastTurnDecks = [];
    _decksToIntroduce = Set<Deck>();
    _cooldowns = [];
  }

  /// Does organizational stuff that happens every time a new turn starts.
  void _tick() {
    for (final cooldown in _cooldowns)
      cooldown.countdown();

    _cooldowns.removeWhere(
      (cooldown) => cooldown.isDone && !cooldown.card.hasFollowup
    );

    // TODO: gather analytics data
  }

  /// Generates a card. If onlyGameCard is set to true, no intro card or coin
  /// card will be returned. This is useful for example cards in deck details.
  Future<Card> generateCard(Configuration config, {
    bool onlyGameCard = false
  }) async {
    //print('Generating a card.');

    // New turn.
    _tick();

    // If there are some decks that need introduction but have been deselected,
    // do not bother to introduce them anymore. On the other hand, if new decks
    // were added, schedule an introduction for them.
    _decksToIntroduce.removeWhere((deck) => !config.decks.contains(deck));
    _decksToIntroduce.addAll(config.decks
        .where((deck) => !_lastTurnDecks.contains(deck))
        .where((deck) => deck.hasIntroduction)
    );
    
    // Actually introduce the first deck that needs an introduction.
    if (!onlyGameCard && _decksToIntroduce.length > 0) {
      final deck = _decksToIntroduce.toList().first;
      _decksToIntroduce.remove(deck);
      return deck.introduction;
    }

    // Maybe return a coin. TODO: take in consideration the time played, cards
    // etc.
    if (!onlyGameCard && Random().nextInt(50) == 0) {
      return CoinCard(text: 'Du hast eine Münze gefunden!');
    }

    // In the cooldowns list, cards that do not have a followup and are cooled
    // down are automatically removed. The remaining fully cooled down cards
    // are guaranteed to have a followup.
    final ripeFollowup = _cooldowns
        .firstWhere((a) => a.isDone, orElse: () => null);
    if (ripeFollowup != null) {
      _cooldowns.remove(ripeFollowup);
      return ripeFollowup.card.createFollowup();
    }

    // Pick a random card.
    GameCard card;
    int count = 0;
    while (card == null && count < 10) {
      count++;
      card = await _tryToPickCard(config).catchError((e) {
        print('An error occured while picking a card: $e');
      });

      if (card == null)
        continue;

      // Make sure the card is not on cooldown.
      if (_cooldowns.map((c) => c.card.id).contains(card.id))
        card = null;
    }

    // We chose a random card, so add it to cooldown.
    _cooldowns.add(_Cooldown(card: card));

    return card;
  }


  /// Picks a random card from a random deck or user-generated cards.
  Future<GameCard> _tryToPickCard(Configuration config) async {
    // First, we need to choose a deck. Do that by calculating the sum of all
    // the decks' probabilites. Then, choose a random cumulative sum in that
    // range.
    final probabilitySum = config.decks
        .map((deck) => deck.probability)
        .reduce((a, b) => a + b);
    final chosenCumSum = Random().nextDouble() * probabilitySum;

    // Calculate the cumulative sum and as we go, return the first deck where
    // the cumulative sum gets above the chosen cumulative sum.
    double cumSum = 0.0;
    final chosenDeck = config.decks.firstWhere((deck) {
      cumSum += deck.probability;
      return cumSum >= chosenCumSum;
    }, orElse: () => null);

    if (chosenDeck.id == 'my') {
      // Pick a user-generated card.
      final cards = config.myCards;
      return cards[(Random().nextDouble() * cards.length).toInt()];
    } else {
      // Pick a card from the chosen deck.
      return await _pickCardFromDeck(chosenDeck, config.players);
    }
  }

  Future<GameCard> _pickCardFromDeck(Deck deck, List<String> players) async {
    int selectedCard = 0;
    int count = -1;

    // Reads the deck's file line by line.
    final line = await rootBundle.loadString(deck.file)
      .asStream()
      .transform(LineSplitter())
      .where((String line) => !line.startsWith('#'))
      .where((String line) {
        if (line.startsWith('/')) {
          // This is the line telling us the number of cards in this file.
          final numberOfCards = int.parse(line.substring(1));
          selectedCard = Random().nextInt(numberOfCards);
          return false;
        } else return true;
      })
      .singleWhere((String line) {
        // Increase count until we are at the chosen card.
        count++;
        return count == selectedCard;
      });

    // Make sure the chosen line is valid.
    final parts = line.split('|');
    if (parts.length != 4) {
      print('Warning: Corrupt card: There are ${parts.length} parts: $line.');
      return null;
    }

    // Insert the players. Return null if there are too few players to fill all
    // the slots in the card.
    players = List.from(players)..shuffle(Random());
    final content = _insertNames(parts[2], players);
    final annihilation = _insertNames(parts[3], players);

    if (content == null || annihilation == null) {
      return null;
    }
 
    // Finally, return the card.
    return GameCard(
      id: deck.id + '-' + parts[0],
      author: parts[1],
      content: _insertNames(parts[2], players),
      followup: _insertNames(parts[3], players),
      color: deck.color
    );
  }

  /// Replaces player tokens in the string with actual player names.
  /// $a is replaced with [players[0]], $b with [players[1]] and so on.
  /// In order to guarantee a fair game, shuffle the players before calling.
  static String _insertNames(String string, List<String> players) {
    const chars = [ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k' ];
    
    for (int i = 0; i < chars.length; i++) {
      final placeholder = '\$${chars[i]}';

      if (string.contains(placeholder)) {
        if (i >= players.length)
          return null;
        string = string.replaceAll(placeholder, players[i]);
      }
    }
    return string;
  }
}
