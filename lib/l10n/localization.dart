import 'package:flutter/material.dart';

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
      'description':
          'Visualize and organize administrative processes with touch navigation and interactive lists.',
      'addNewProcess': 'Add New Process',
      'processTitle_field': 'Process Title',
      'processDescription': 'Process Description',
      'processStages': 'Process Stages',
      'addStage': 'Add stage',
      'stage': 'Stage',
      'stageTitle': 'Stage Title',
      'stageDescription': 'Stage Description',
      'saveProcess': 'Save Process',
      'titleRequired': 'Title is required',
      'descriptionRequired': 'Description is required',
      'allStagesRequired': 'All stages must have title and description',
      'processAddedSuccessfully': 'Process added successfully',
      'errorSavingProcess': 'Error saving process',
      'processTitleHint': 'Enter the process title',
      'processDescriptionHint': 'Describe the process in general',
      'initializing': 'Initializing...'
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
      'description':
          'Visualiza y organiza procesos administrativos con navegación táctil y listas interactivas.',
      'addNewProcess': 'Agregar Nuevo Proceso',
      'processTitle_field': 'Título del Proceso',
      'processDescription': 'Descripción del Proceso',
      'processStages': 'Etapas del Proceso',
      'addStage': 'Agregar etapa',
      'stage': 'Etapa',
      'stageTitle': 'Título de la Etapa',
      'stageDescription': 'Descripción de la Etapa',
      'saveProcess': 'Guardar Proceso',
      'titleRequired': 'El título es requerido',
      'descriptionRequired': 'La descripción es requerida',
      'allStagesRequired': 'Todas las etapas deben tener título y descripción',
      'processAddedSuccessfully': 'Proceso agregado exitosamente',
      'errorSavingProcess': 'Error al guardar el proceso',
      'processTitleHint': 'Ingresa el título del proceso',
      'processDescriptionHint': 'Describe el proceso en general',
      'initializing': 'Inicializando...'
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
