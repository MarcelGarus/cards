import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yaml/yaml.dart';
import 'resource_manager.dart';

enum TextId {
  none,
  app_title,

  players_empty,
  add_player_label,
  add_player_hint,
  add_player_error,

  configuration_player_missing,
  configuration_deck_missing,
  start_game,

  coin_card,
  game_card_author,

  beta_box_title,
  beta_box_body,
  beta_box_action,

  sign_in,
  sign_in_body,
  sign_in_action,
  sign_out_action,
  menu_my_cards,
  menu_feedback,

  my_cards_title,
  my_cards_empty,
  my_cards_add,
  edit_card_title,
  edit_card_content,
  edit_card_followup,
  edit_card_author,
  edit_card_sign_in,
  edit_card_publish,
  publish_title,
  publish_body,
  publish_conditions,
  publish_action,

  mail_subject,
  mail_body,
}

abstract class _TextIdConverter {
  static TextId fromString(String id) {
    for (final textId in TextId.values) {
      final strId = textId.toString();
      if (strId.substring(strId.indexOf('.') + 1) == id)
        return textId;
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
    localeSubject.add(locale);
    print('Loaded locale: $locale');
  }

  void dispose() => localeSubject.close();


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


  static void _saveLocale(Locale locale) {
    ResourceManager.saveString('locale', locale.languageCode).catchError((e) {
      print('An error occured while saving $locale as the locale: $e');
    });
  }

  static Future<Locale> _loadLocale() async {
    return Locale(await ResourceManager.loadString('locale') ?? 'de');
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
      texts[_TextIdConverter.fromString(entry.key.toString())] = entry.value.toString();
    }

    return texts;
  }
}
