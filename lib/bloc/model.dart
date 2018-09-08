import 'package:flutter/foundation.dart';

class Card {}

class EmptyCard extends Card {}

class IntroductionCard extends Card {
  IntroductionCard({ @required this.text }) : assert(text != null);

  final String text;
}

class ContentCard extends Card {
  ContentCard({
    @required this.id,
    this.author,
    @required this.content,
    this.annihilation,
    @required this.color
  }) :
      assert(id != null),
      assert(content != null),
      assert(color != null);

  final String id;
  final String author;
  final String content;
  final String annihilation;
  final String color;

  bool get hasAnnihilation => annihilation.length > 0;

  String toString() => 'Card #$id: "$content" by $author';
}

class CoinCard extends Card {
  CoinCard({ @required this.text }) : assert(text != null);
  
  final String text;

  String toString() => 'Coin card';
}

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

  final String id;
  final String file;
  final String name;
  final String coverImage;
  final String color;
  final String description;
  final double probability;
  final IntroductionCard introduction;
  bool isUnlocked;
  bool isSelected;

  bool get hasIntroduction => introduction != null;

  String toString() => '(\'$name\' with description \'$description\' has color $color. See file $file)';
}
