import 'package:admin_processes/model/process_stage.dart';

class ProcessStudy {
  const ProcessStudy(this.title, this.description, this.processStage,
      {this.id, this.language, this.isDeletable = true});

  final int? id;
  final String? language;
  final String title;
  final String description;
  final List<ProcessStage> processStage;
  final bool
      isDeletable; // Indica si el proceso puede ser eliminado por el usuario

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'language': language,
      'title': title,
      'description': description,
      'isDeletable': isDeletable ? 1 : 0, // SQLite usa 1/0 para boolean
    };
  }

  // Create from Map for SQLite
  static ProcessStudy fromMap(
      Map<String, dynamic> map, List<ProcessStage> stages) {
    return ProcessStudy(
      map['title'] as String,
      map['description'] as String,
      stages,
      id: map['id'] as int?,
      language: map['language'] as String?,
      isDeletable: (map['isDeletable'] as int? ?? 1) ==
          1, // Convertir de 1/0 a bool, default true si es null
    );
  }

  // Create a copy with updated values
  ProcessStudy copyWith({
    int? id,
    String? language,
    String? title,
    String? description,
    List<ProcessStage>? processStage,
    bool? isDeletable,
  }) {
    return ProcessStudy(
      title ?? this.title,
      description ?? this.description,
      processStage ?? this.processStage,
      id: id ?? this.id,
      language: language ?? this.language,
      isDeletable: isDeletable ?? this.isDeletable,
    );
  }
}
