import 'package:admin_processes/model/process_stage.dart';
import 'package:admin_processes/model/process_study.dart';

final List<ProcessStudy> processList = [
  ProcessStudy('Proceso Administrativo', [
    ProcessStage('Planeación', 'Establecer objetivos y determinar las acciones necesarias para lograrlos.'),
    ProcessStage('Organización', 'Asignar recursos, tareas y responsabilidades para alcanzar los objetivos.'),
    ProcessStage('Dirección', 'Liderar, motivar y guiar a los empleados para cumplir con las metas establecidas.'),
    ProcessStage('Control', 'Evaluar el desempeño y tomar medidas correctivas si es necesario para asegurar que se cumplen los objetivos.'),
  ]),
  ProcessStudy('5S', [
    ProcessStage('Seiri (Clasificar)', 'Eliminar lo innecesario del área de trabajo, quedándote solo con lo esencial.'),
    ProcessStage('Seiton (Ordenar)', 'Organizar y etiquetar los elementos de manera que sean fáciles de encontrar y usar.'),
    ProcessStage('Seiso (Limpiar)', 'Mantener el lugar de trabajo limpio y ordenado a diario.'),
    ProcessStage('Seiketsu (Estandarizar)','Establecer normas y procedimientos para mantener el orden y la limpieza.'),
    ProcessStage('Shitsuke (Disciplina)','Fomentar la autodisciplina y el compromiso con las prácticas de las 5S para asegurar su continuidad.'),
  ]),
  ProcessStudy('Six Sigma (DMAIC)', [
    ProcessStage('Definir', 'Identificar el problema o la oportunidad de mejora.'),
    ProcessStage('Medir', 'Recopilar datos relevantes para entender el problema.'),
    ProcessStage('Analizar', 'Examinar los datos para identificar las causas raíz del problema.'),
    ProcessStage('Mejorar (Improve)', 'Desarrollar y aplicar soluciones para abordar las causas raíz.'),
    ProcessStage('Controlar', 'Implementar controles para asegurar que las mejoras se mantengan.'),
  ]),
];
