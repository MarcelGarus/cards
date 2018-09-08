import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'model.dart';
import 'resource_manager.dart';

class _Annihilation {
  _Annihilation({ @required this.originalCard }) :
      assert(originalCard != null);

  final ContentCard originalCard;
  int _countdown = 5 + Random().nextInt(5);

  void countdown() => _countdown = max(0, _countdown - 1);
  bool get isRipe => _countdown == 0;
  ContentCard getCard() => ContentCard(
    id: originalCard.id,
    author: originalCard.author,
    content: originalCard.annihilation,
    annihilation: '',
    color: originalCard.color
  );
}

/// The lifespan of the [Generator] equals the lifespan of a single game.
class Generator {
  final _lastTurnDecks = <Deck>[];
  final _decksToIntroduce = Set<Deck>();
  final _annihilations = <_Annihilation>[];

  /// Does organizational stuff that happens when a new turn starts.
  void _tick() {
    // Count down annihilations.
    for (final a in _annihilations)
      a.countdown();

    // TODO: gather analytics data

    // TODO: implement cooldown?
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
    //print('Ticking');
    _tick();

    // Handle new decks that need an introduction.
    //print('Handle new decks that need an introduction.');
    _decksToIntroduce.removeWhere((deck) => !decks.contains(deck));
    _decksToIntroduce.addAll(decks
        .where((deck) => !_lastTurnDecks.contains(deck))
        .where((deck) => deck.hasIntroduction)
    );
    
    if (_decksToIntroduce.length > 0) {
      final introducedDeck = _decksToIntroduce.toList().first;
      _decksToIntroduce.remove(introducedDeck);
      return introducedDeck.introduction;
    }

    // TODO: Maybe return a coin.
    if (Random().nextInt(50) == 0) {
      return CoinCard(text: 'Du hast eine Münze gefunden!');
    }

    // Maybe return an annihilation.
    //print('Maybe return an annihilation from those: $_annihilations');
    final ripeAnnihilation = _annihilations.firstWhere((a) => a.isRipe, orElse: () => null);
    if (ripeAnnihilation != null) {
      _annihilations.remove(ripeAnnihilation);
      return ripeAnnihilation.getCard();
    }

    // Pick a random card.
    //print('Pick a random card.');
    ContentCard card;
    while (card == null) {
      card = await ResourceManager.pickCard(
        decks: decks,
        players: players
      );

      final idsOfFollowups = _annihilations
          .map((a) => a.originalCard.id).toList();
      if (idsOfFollowups.contains(card.id))
        card = null;
    }
    if (card.hasAnnihilation) {
      _annihilations.add(_Annihilation(originalCard: card));
    }
    return card;
  }
}
