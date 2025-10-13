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
      'aboutInfo': 'Open Source: https://github.com/javert-galicia/admin_processes\nJavier Galicia: https://jgalicia.com',
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
      'initializing': 'Initializing...',
      'delete': 'Delete',
      'confirm_delete': 'Confirm Delete',
      'delete_process_confirmation': 'Are you sure you want to delete this process? This action cannot be undone.',
      'cancel': 'Cancel',
      'process_deleted_successfully': 'Process deleted successfully',
      'error_deleting_process': 'Error deleting process',
      'settings': 'Settings',
      'theme': 'Theme',
      'lightMode': 'Light Mode',
      'darkMode': 'Dark Mode',
      'goToPage': 'Go to Page',
      'pageNumber': 'Page number',
      'goToPageInstruction': 'Enter page number (1-{count})',
      'dataManagement': 'Data Management',
      'exportData': 'Export Data',
      'importData': 'Import Data',
      'exportDescription': 'Export user-created processes to a file',
      'importDescription': 'Import user-created processes from a file',
      'exportSuccess': 'Data exported successfully',
      'importSuccess': 'Data imported successfully',
      'exportError': 'Error exporting data',
      'importError': 'Error importing data',
      'noDataToExport': 'No data to export',
      'selectExportLocation': 'Select export location',
      'selectImportFile': 'Select file to import'
    },
    'es': {
      'appTitle': 'Procesos Administrativos',
      'aboutInfo': 'Código Abierto: https://github.com/javert-galicia/admin_processes\nJavier Galicia: https://jgalicia.com',
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
      'initializing': 'Inicializando...',
      'delete': 'Eliminar',
      'confirm_delete': 'Confirmar Eliminación',
      'delete_process_confirmation': '¿Estás seguro de que deseas eliminar este proceso? Esta acción no se puede deshacer.',
      'cancel': 'Cancelar',
      'process_deleted_successfully': 'Proceso eliminado exitosamente',
      'error_deleting_process': 'Error al eliminar el proceso',
      'settings': 'Configuración',
      'theme': 'Tema',
      'lightMode': 'Modo Claro',
      'darkMode': 'Modo Oscuro',
      'goToPage': 'Ir a página',
      'pageNumber': 'Número de página',
      'goToPageInstruction': 'Ingresa el número de página (1-{count})',
      'dataManagement': 'Gestión de Datos',
      'exportData': 'Exportar Datos',
      'importData': 'Importar Datos',
      'exportDescription': 'Exportar procesos creados por el usuario a un archivo',
      'importDescription': 'Importar procesos creados por el usuario desde un archivo',
      'exportSuccess': 'Datos exportados exitosamente',
      'importSuccess': 'Datos importados exitosamente',
      'exportError': 'Error al exportar datos',
      'importError': 'Error al importar datos',
      'noDataToExport': 'No hay datos para exportar',
      'selectExportLocation': 'Seleccionar ubicación de exportación',
      'selectImportFile': 'Seleccionar archivo para importar'
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
