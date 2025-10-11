import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'appTitle': 'Administrative Processes',
      'aboutInfo': 'For more information visit: Javier Galicia: jgalicia.com',
      'addProcess': 'Add process',
      'close': 'Close',
      'language': 'Language:',
      'english': 'English',
      'spanish': 'Spanish',
      'processTitle': 'Administrative Processes',
      'description': 'Visualize and organize administrative processes with touch navigation and interactive lists.'
    },
    'es': {
      'appTitle': 'Procesos Administrativos',
      'aboutInfo': 'Para más información visita: Javier Galicia: jgalicia.com',
      'addProcess': 'Agregar proceso',
      'close': 'Cerrar',
      'language': 'Idioma:',
      'english': 'Inglés',
      'spanish': 'Español',
      'processTitle': 'Procesos Administrativos',
      'description': 'Visualiza y organiza procesos administrativos con navegación táctil y listas interactivas.'
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
