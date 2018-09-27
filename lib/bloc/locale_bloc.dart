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
  publish_time,
  publish_conditions,
  publish_action,

  guidelines,

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

class Localizer {
  static Localizer get empty => Localizer(Locale(''), Map());

  Localizer(this.locale, this._items);

  final Locale locale;
  final Map<TextId, dynamic> _items;

  dynamic getItem(TextId id) {
    if (_items.containsKey(id))
      return _items[id];

    if (locale.languageCode != '')
      print('Item $id missing for locale $locale.');
    return null;
  }

  operator ==(Object other) => other is Localizer && locale == other.locale;
}

class LocaleBloc {
  Locale locale;
  Map<TextId, dynamic> _items = Map();

  final localizerSubject = BehaviorSubject<Localizer>();


  Future<void> initialize() async {
    updateLocale(await _loadLocale());
    print('Loaded locale: $locale');
  }

  void dispose() => localizerSubject.close();


  Future<void> updateLocale(Locale locale) async {
    assert(locale != null);

    if (this.locale == locale)
      return;
    
    this.locale = locale;
    localizerSubject.add(Localizer(locale, await _loadItems(locale)));
    _saveLocale(locale);
  }


  static void _saveLocale(Locale locale) {
    ResourceManager.saveString('locale', locale.languageCode).catchError((e) {
      print('An error occured while saving $locale as the locale: $e');
    });
  }

  static Future<Locale> _loadLocale() async {
    return Locale(await ResourceManager.loadString('locale') ?? 'de');
  }

  static Future<Map<TextId, dynamic>> _loadItems(Locale locale) async {
    if (locale == null)
      return Map();

    final root = ResourceManager.getRootDirectory(locale);
    final filename = '$root/text.yaml';
    final yaml = loadYaml(await rootBundle.loadString(filename)) as YamlMap;

    final texts = Map<TextId, dynamic>();
    texts[TextId.none] = '<None>';

    for (final MapEntry entry in yaml.entries) {
      texts[_TextIdConverter.fromString(entry.key.toString())] = entry.value;
    }

    return texts;
  }
}
