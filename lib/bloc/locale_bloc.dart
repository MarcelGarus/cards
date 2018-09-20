import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yaml/yaml.dart';
import 'bloc.dart';
import 'resource_manager.dart';

abstract class TextIds {
  static TextId fromString(String id) {
    switch (id) {
      case 'app_title': return TextId.app_title;

      case 'add_player_label': return TextId.add_player_label;
      case 'add_player_hint': return TextId.add_player_hint;
      case 'add_player_error': return TextId.add_player_error;

      case 'configuration_player_missing': return TextId.configuration_player_missing;
      case 'configuration_deck_missing': return TextId.configuration_deck_missing;
      case 'start_game': return TextId.start_game;

      case 'beta_box_title': return TextId.beta_box_title;
      case 'beta_box_body': return TextId.beta_box_body;
      case 'beta_box_action': return TextId.beta_box_action;

      case 'menu_log_in': return TextId.menu_log_in;
      case 'menu_log_in_text': return TextId.menu_log_in_text;
      case 'menu_my_cards': return TextId.menu_my_cards;
      case 'menu_settings': return TextId.menu_settings;
      case 'menu_feedback': return TextId.menu_feedback;

      case 'mail_subject': return TextId.mail_subject;
      case 'mail_body': return TextId.mail_body;

      case 'coin_card': return TextId.coin_card;
      case 'game_card_author': return TextId.game_card_author;
    }
    return TextId.none;
  }
}

class LocaleBloc {
  Locale locale;

  final localeSubject = BehaviorSubject<Locale>();
  Map<TextId, String> _textItems = Map();


  Future<void> initialize() async {
    locale = await _loadLocale();
    _textItems = await _loadText(locale);
    print('Updating all locale widgets with locale $locale.');
    localeSubject.add(locale);
  }

  void dispose() {
    localeSubject.close();
  }


  Future<void> updateLocale(Locale locale) async {
    assert(locale != null);

    if (this.locale == locale)
      return;
    
    this.locale = locale;
    _textItems = await _loadText(locale);
    localeSubject.add(locale);
    _saveLocale(locale);
  }

  String getText(TextId id) {
    return _textItems?.containsKey(id) ?? false ? _textItems[id] : '$id missing';
  }


  static Future<void> _saveLocale(Locale locale) {
    ResourceManager.saveString('locale', locale.languageCode).catchError((e) {
      print('An error occured while saving $locale as the locale: $e');
    });
  }

  static Future<Locale> _loadLocale() async {
    return Locale(
      await ResourceManager.loadString('locale') ?? 'de'
    );
  }

  static Future<Map<TextId, String>> _loadText(Locale locale) async {
    if (locale == null)
      return Map();

    final root = ResourceManager.getRootDirectory(locale);
    final filename = '$root/text.yaml';
    final yaml = loadYaml(await rootBundle.loadString(filename)) as YamlMap;

    final texts = Map<TextId, String>();
    texts[TextId.none] = '<None>';

    for (final MapEntry entry in yaml.entries) {
      texts[TextIds.fromString(entry.key.toString())] = entry.value.toString();
    }

    print('Texts are $texts.');
    return texts;
  }
}
