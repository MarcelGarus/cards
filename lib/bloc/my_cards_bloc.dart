import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model.dart';
import 'resource_manager.dart';

class MyCardsBloc {
  List<MyCard> myCards = <MyCard>[];
  List<GameCard> get cardsForGame => myCards
      .where((card) => card.includeInGame)
      .map((card) => card.gameCard)
      .toList();
  bool get providesCardsForGame => cardsForGame.length > 0;

  final myCardsSubject = BehaviorSubject<List<MyCard>>(seedValue: []);


  Future<void> initialize() async {
    myCards = await _loadMyCards();
    _saveMyCards(myCards);
    myCardsSubject.add(myCards);
  }

  void dispose() {
    myCardsSubject.close();
  }

  /// Creates a new card for the user to fill with content.
  MyCard createNewCard() {
    final myCardIds = myCards.map((card) => card.gameCard.id).toSet();
    var id;
    for (int i = 0;; i++) {
      id = 'my_$i';
      if (!myCardIds.contains(id))
        break;
    }

    final card = MyCard(
      gameCard: GameCard(id: id, content: '', color: '#FFFFFF')
    );

    myCards.add(card);
    myCardsSubject.add(myCards);
    _saveMyCards(myCards);
    return card;
  }

  void updateCard(MyCard card) {
    final oldVersion = myCards
        .singleWhere((myCard) => myCard.gameCard.id == card.gameCard.id);

    myCards.remove(oldVersion);
    myCards.add(card);
    myCardsSubject.add(myCards);
    _saveMyCards(myCards);
  }

  void deleteCard(MyCard card) {
    myCards.remove(card);
    myCardsSubject.add(myCards);
    _saveMyCards(myCards);
  }


  /// Saves the user's cards.
  static Future<void> _saveMyCards(List<MyCard> cards) async {
    // Save the cards in the same format as cards in deck files, but with a
    // leading enabled property.
    final List<String> stringifiedCards = cards.map((card) =>
        '${card.gameCard.id}|'
        '${card.gameCard.author}|'
        '${card.gameCard.content}|'
        '${card.gameCard.followup}|'
        '${card.isEnabled ? 'enabled' : 'disabled'}|'
        '${card.isPublished ? 'published' : 'local'}'
    ).toList();

    ResourceManager
        .saveStringList('my_cards', stringifiedCards)
        .catchError((e) {
          print('An error occured while saving $cards as my cards: $e');
        });
  }


  /// Loads the user's cards.
  static Future<List<MyCard>> _loadMyCards() async {
    final prefs = await SharedPreferences.getInstance();

    return (prefs.getStringList('my_cards') ?? [])
        .map((stringifiedCard) {
          final parts = stringifiedCard.split('|');
          if (parts.length == 6) {
            return MyCard(
              gameCard: GameCard(
                id: parts[0],
                color: '#FFFFFF',
                content: parts[2],
                followup: parts[3],
                author: parts[1],
              ),
              isEnabled: parts[4] == 'enabled',
              isPublished: parts[5] == 'published'
            );
          }
          print('Warning: My card $stringifiedCard is not parseable.');
          return null;
        })
        .where((card) => card != null)
        .toList();
  }
}
