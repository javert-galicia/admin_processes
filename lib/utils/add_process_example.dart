import 'package:admin_processes/db/process_data_service.dart';
import 'package:admin_processes/model/process_study.dart';
import 'package:admin_processes/model/process_stage.dart';
import 'package:admin_processes/utils/logger.dart';

/// Ejemplo de cómo agregar un nuevo ProcessStudy programáticamente
class AddProcessExample {
  /// Agregar un nuevo proceso de ejemplo
  static Future<void> addExampleProcess() async {
    // Crear las etapas del proceso
    final stages = [
      ProcessStage(
        'Etapa 1: Planificación',
        'Definir objetivos y alcance del proyecto',
        processStudyId: null, // Se asignará automáticamente
      ),
      ProcessStage(
        'Etapa 2: Ejecución',
        'Implementar las tareas definidas en la planificación',
        processStudyId: null,
      ),
      ProcessStage(
        'Etapa 3: Evaluación',
        'Revisar resultados y documentar lecciones aprendidas',
        processStudyId: null,
      ),
    ];

    // Crear el nuevo ProcessStudy
    final newProcess = ProcessStudy(
      'Gestión de Proyecto Ejemplo',
      'Un proceso ejemplo para demostrar la gestión de proyectos',
      stages,
      // id se asignará automáticamente
      // language se especificará al guardar
    );

    try {
      // Agregar en español
      final processId =
          await ProcessDataService.addProcessStudy(newProcess, 'es');
      AppLogger.success('Proceso agregado con ID: $processId', 'ProcessExample');

      // También puedes agregarlo en inglés con diferente contenido
      final englishProcess = ProcessStudy(
        'Example Project Management',
        'An example process to demonstrate project management',
        [
          ProcessStage(
            'Stage 1: Planning',
            'Define project objectives and scope',
            processStudyId: null,
          ),
          ProcessStage(
            'Stage 2: Execution',
            'Implement tasks defined in planning phase',
            processStudyId: null,
          ),
          ProcessStage(
            'Stage 3: Evaluation',
            'Review results and document lessons learned',
            processStudyId: null,
          ),
        ],
      );

      final englishProcessId =
          await ProcessDataService.addProcessStudy(englishProcess, 'en');
      AppLogger.success('English process added with ID: $englishProcessId', 'ProcessExample');
    } catch (e) {
      AppLogger.error('Error al agregar proceso', e, 'ProcessExample');
    }
  }

  /// Método más genérico para agregar cualquier proceso
  static Future<int?> addCustomProcess({
    required String title,
    required String description,
    required List<Map<String, String>>
        stages, // [{'stage': '...', 'description': '...'}]
    required String language,
  }) async {
    try {
      // Convertir los stages del Map a ProcessStage
      final processStages = stages
          .map((stageMap) => ProcessStage(
                stageMap['stage'] ?? '',
                stageMap['description'] ?? '',
                processStudyId: null,
              ))
          .toList();

      // Crear el ProcessStudy
      final newProcess = ProcessStudy(
        title,
        description,
        processStages,
      );

      // Agregar a la base de datos
      final processId =
          await ProcessDataService.addProcessStudy(newProcess, language);
      AppLogger.success('Proceso "$title" agregado con ID: $processId', 'ProcessExample');

      return processId;
    } catch (e) {
      AppLogger.error('Error al agregar proceso personalizado', e, 'ProcessExample');
      return null;
    }
  }
}

/// Ejemplo de uso desde cualquier parte de tu app
Future<void> ejemploDeUso() async {
  // Ejemplo 1: Agregar proceso predefinido
  await AddProcessExample.addExampleProcess();

  // Ejemplo 2: Agregar proceso personalizado
  await AddProcessExample.addCustomProcess(
    title: 'Mi Proceso Personalizado',
    description: 'Descripción de mi proceso',
    stages: [
      {'stage': 'Inicio', 'description': 'Comenzar el proceso'},
      {'stage': 'Desarrollo', 'description': 'Desarrollar la solución'},
      {'stage': 'Finalización', 'description': 'Completar y entregar'},
    ],
    language: 'es',
  );
}
