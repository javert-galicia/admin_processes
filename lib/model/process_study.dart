import 'package:admin_processes/model/process_stage.dart';

class ProcessStudy {
  const ProcessStudy(this.title, this.description, this.processStage);

  final String title;
  final String description;
  final List<ProcessStage> processStage;
}
