/// Consultation room within a clinic department.
class ConsultationRoom {
  const ConsultationRoom({
    required this.id,
    required this.clinicId,
    required this.departmentId,
    required this.name,
    this.archived = false,
  });

  final String id;
  final String clinicId;
  final String departmentId;
  final String name;
  final bool archived;

  ConsultationRoom copyWith({
    String? name,
    String? departmentId,
    bool? archived,
  }) {
    return ConsultationRoom(
      id: id,
      clinicId: clinicId,
      departmentId: departmentId ?? this.departmentId,
      name: name ?? this.name,
      archived: archived ?? this.archived,
    );
  }

  Map<String, dynamic> toMap() => {
        'clinicId': clinicId,
        'departmentId': departmentId,
        'name': name,
        'archived': archived,
      };

  factory ConsultationRoom.fromMap(String id, Map<String, dynamic> data) {
    return ConsultationRoom(
      id: id,
      clinicId: data['clinicId'] as String? ?? '',
      departmentId: data['departmentId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      archived: data['archived'] as bool? ?? false,
    );
  }
}
