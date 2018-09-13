import 'package:flutter/foundation.dart';

/// A deck.
class Deck {
  Deck({
    @required this.id,
    @required this.file,
    @required this.name,
    @required this.coverImage,
    @required this.color,
    @required this.description,
    @required this.probability,
    this.introduction,
    this.isUnlocked = true,
    this.isSelected = false
  }) :
      assert(id != null),
      assert(file != null),
      assert(name != null),
      assert(coverImage != null),
      assert(color != null),
      assert(description != null),
      assert(probability != null),
      assert(isUnlocked != null);

  /// The deck's ID.
  final String id;

  /// The path to the file where the deck's cards are stored.
  final String file;

  /// The name of the deck.
  final String name;

  /// The path to the file where the deck's cover image is stored.
  final String coverImage;

  /// The deck's color.
  final String color;

  /// The deck's description.
  final String description;

  /// The deck's probability.
  /// Usually a value between 0 and 1, inclusive.
  final double probability;

  /// A card doing some introduction or initialisation for the deck.
  final IntroCard introduction;
  bool get hasIntroduction => introduction != null;

  /// Whether the card is unlocked.
  bool isUnlocked;

  /// Whether the card is currently selected.
  bool isSelected;


  bool operator ==(dynamic other) {
    if (other is! Deck)
      return false;

    final Deck typedOther = other;
    return id == typedOther.id &&
      file == typedOther.file &&
      name == typedOther.name &&
      coverImage == typedOther.coverImage &&
      color == typedOther.color &&
      description == typedOther.description &&
      probability == typedOther.probability &&
      introduction == typedOther.introduction &&
      isUnlocked == typedOther.isUnlocked &&
      isSelected == typedOther.isSelected;
  }

  String toString() => '(\'$name\' with description \'$description\' has color $color. See file $file)';
}



/// A game configuration with players, decks and enabled cards by the player.
class Configuration {
  Configuration({
    @required this.players,
    @required this.decks,
    @required this.myCards
  }) :
      assert(players != null),
      assert(decks != null),
      assert(myCards != null);

  final List<String> players;
  final List<Deck> decks;
  final List<GameCard> myCards;

  bool get isPlayerMissing => players.length == 0;
  bool get isDeckMissing => decks.length == 0;
  bool get isValid => players.length > 0 && decks.length > 0;

  String toString() => 'Configuration(players=$players, decks=decks, myCards=$myCards';
}



/// This is the base Card class, which all the other cards extend.
class Card {}



/// An empty card. You can see the top of at as the bottom bar when the app
/// just launched and no game was started started yet.
class EmptyCard extends Card {}



/// A card provided by some decks for introductory or initialisation
/// purposes.
class IntroCard extends Card {
  IntroCard({
    @required this.text
  }) :
      assert(text != null);

  /// The introductory text.
  final String text;

  // TODO: add an image
}



/// The content card, displaying some content from a deck.
class GameCard extends Card {
  GameCard({
    @required this.id,
    @required this.color,
    @required this.content,
    this.followup = '',
    this.author = ''
  }) :
      assert(id != null),
      assert(color != null),
      assert(content != null),
      assert(followup != null),
      assert(author != null);

  /// The card's global (not deck-local!) ID.
  final String id;

  /// The card content's color with a leading hash sign.
  final String color;

  /// The card's actual content.
  final String content;

  /// The card's followup to be picked after some more turns.
  final String followup;
  bool get hasFollowup => followup.length > 0;

  /// The card's author.
  final String author;
  bool get hasAuthor => author.length > 0;


  /// Creates this card's followup.
  GameCard createFollowup() => GameCard(
    id: '$id-f',
    author: author,
    content: followup,
    followup: '',
    color: color
  );

  String toString() => 'Card #$id: "$content" by $author';
}



/// Card with a coin for the player.
class CoinCard extends Card {
  CoinCard({
    @required this.text
  }) :
      assert(text != null);
  
  /// The card's text.
  final String text;


  String toString() => 'Coin card';
}
