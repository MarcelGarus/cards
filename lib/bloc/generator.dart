import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'model.dart';
import 'resource_manager.dart';


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



/// The lifespan of the [Generator] equals the lifespan of a single game.
class Generator {
  /// The last turn's decks.
  final _lastTurnDecks = <Deck>[];

  /// The decks that still have introductory cards that need to be played.
  final _decksToIntroduce = Set<Deck>();

  /// Cooldowns of all the cards that have been played.
  final _cooldowns = <_Cooldown>[];


  /// Does organizational stuff that happens every time a new turn starts.
  void _tick() {
    // Count down cooldowns of all cards.
    for (final cooldown in _cooldowns)
      cooldown.countdown();

    _cooldowns.removeWhere((cd) => cd.isDone && !cd.card.hasFollowup);

    // TODO: gather analytics data
  }


  /// Generates a card.
  Future<Card> generateCard({
    @required List<Deck> decks,
    @required List<String> players
  }) async {
    assert(decks != null);
    assert(players != null);

    print('Generating a card.');

    // New turn.
    _tick();

    // If there are some decks that need introduction but have been deselected,
    // do not bother to introduce them anymore.
    // On the other hand, if new decks were added, schedule an introduction for
    // them.
    _decksToIntroduce.removeWhere((deck) => !decks.contains(deck));
    _decksToIntroduce.addAll(decks
        .where((deck) => !_lastTurnDecks.contains(deck))
        .where((deck) => deck.hasIntroduction)
    );
    
    // Actually introduce the first deck that needs an introduction.
    if (_decksToIntroduce.length > 0) {
      final deck = _decksToIntroduce.toList().first;
      _decksToIntroduce.remove(deck);
      return deck.introduction;
    }

    // Maybe return a coin. TODO: take in consideration the time played, cards etc.
    if (Random().nextInt(50) == 0) {
      return CoinCard(text: 'Du hast eine Münze gefunden!');
    }

    // In the cooldowns list, cards that do not have a followup and are cooled
    // down are automatically removed. The remaining fully cooled down cards
    // are guaranteed to have a followup.
    final ripeFollowup = _cooldowns.firstWhere((a) => a.isDone, orElse: () => null);
    if (ripeFollowup != null) {
      _cooldowns.remove(ripeFollowup);
      return ripeFollowup.card.createFollowup();
    }

    // Pick a random card.
    GameCard card;
    while (card == null) {
      card = await ResourceManager.pickCard(
        decks: decks,
        players: players
      ).catchError((e) {
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
}
