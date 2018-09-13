import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'resource_manager.dart';

class LocaleBloc {
  Locale locale;

  final localeSubject = BehaviorSubject<Locale>();


  void initialize() async {
    locale = await _loadLocale();
    localeSubject.add(locale);
  }

  void dispose() {
    localeSubject.close();
  }


  void updateLocale(Locale locale) {
    assert(locale != null);

    if (this.locale == locale)
      return;
    
    this.locale = locale;
    localeSubject.add(locale);
    _saveLocale(locale);

    // TODO: internationalization
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
}
