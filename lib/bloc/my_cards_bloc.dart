import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model.dart';
import 'resource_manager.dart';

class MyCardsBloc {
  List<GameCard> myCards = <GameCard>[];

  final myCardsSubject = BehaviorSubject<List<GameCard>>(seedValue: []);

  Future<void> initialize() async {
    myCards = await _loadMyCards();
    myCardsSubject.add(myCards);
  }

  void dispose() {
    myCardsSubject.close();
  }

  /// Creates a new card for the user to fill with content.
  GameCard createNewCard() {
    final myCardIds = myCards.map((card) => card.id).toSet();
    var id;
    for (int i = 0;; i++) {
      id = 'my_$i';
      if (!myCardIds.contains(id))
        break;
    }

    final card = GameCard(id: id, content: '', color: '#FFFFFF');

    myCards.add(card);
    myCardsSubject.add(myCards);
    _saveMyCards(myCards);
    return card;
  }

  void updateCard(GameCard card) {
    final oldVersion = myCards.singleWhere((myCard) => myCard.id == card.id);
    myCards.remove(oldVersion);
    myCards.add(card);
    myCardsSubject.add(myCards);
    _saveMyCards(myCards);
  }

  void deleteCard(GameCard card) {
    myCards.remove(card);
    myCardsSubject.add(myCards);
    _saveMyCards(myCards);
  }


  /// Saves the user's cards.
  static Future<void> _saveMyCards(List<GameCard> cards) async {
    // Save the cards in the same format as cards in deck files.
    final List<String> stringifiedCards = cards.map((card) =>
        '${card.id}|${card.author}|${card.content}|${card.followup}'
    ).toList();

    ResourceManager
        .saveStringList('my_cards', stringifiedCards)
        .catchError((e) {
          print('An error occured while saving $cards as my cards: $e');
        });
  }


  /// Loads the user's cards.
  static Future<List<GameCard>> _loadMyCards() async {
    final prefs = await SharedPreferences.getInstance();

    return (prefs.getStringList('my_cards') ?? [])
        .map((stringifiedCard) {
          final parts = stringifiedCard.split('|');
          return parts.length == 4 ? GameCard(
            id: parts[0],
            color: '#FFFFFF',
            content: parts[2],
            followup: parts[3],
            author: parts[1],
          ) : null;
        })
        .where((card) => card != null)
        .toList();
  }
}
