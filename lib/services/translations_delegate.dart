import 'package:flutter/material.dart';
import 'package:lobbytalk/services/translations.dart';

class TranslationsDelegate extends LocalizationsDelegate<Translations> {
  const TranslationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ro', 'ru'].contains(locale.languageCode);
  }

  @override
  Future<Translations> load(Locale locale) async {
    return Translations(locale);
  }

  @override
  bool shouldReload(TranslationsDelegate old) => false;
}
