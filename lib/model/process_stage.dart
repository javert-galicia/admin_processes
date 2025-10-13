class ProcessStage {
  ProcessStage(this.stage, this.description, {this.id, this.processStudyId});

  final int? id;
  final int? processStudyId;
  final String stage;
  final String description;

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'processStudyId': processStudyId,
      'stage': stage,
      'description': description,
    };
  }

  // Create from Map for SQLite
  static ProcessStage fromMap(Map<String, dynamic> map) {
    return ProcessStage(
      map['stage'] as String,
      map['description'] as String,
      id: map['id'] as int?,
      processStudyId: map['processStudyId'] as int?,
    );
  }

  // Create a copy with updated values
  ProcessStage copyWith({
    int? id,
    int? processStudyId,
    String? stage,
    String? description,
  }) {
    return ProcessStage(
      stage ?? this.stage,
      description ?? this.description,
      id: id ?? this.id,
      processStudyId: processStudyId ?? this.processStudyId,
    );
  }
}
