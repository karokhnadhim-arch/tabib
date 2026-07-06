/// Department within a clinic — owner managed.
class ClinicDepartment {
  const ClinicDepartment({
    required this.id,
    required this.clinicId,
    required this.name,
    this.archived = false,
  });

  final String id;
  final String clinicId;
  final String name;
  final bool archived;

  ClinicDepartment copyWith({
    String? name,
    bool? archived,
  }) {
    return ClinicDepartment(
      id: id,
      clinicId: clinicId,
      name: name ?? this.name,
      archived: archived ?? this.archived,
    );
  }

  Map<String, dynamic> toMap() => {
        'clinicId': clinicId,
        'name': name,
        'archived': archived,
      };

  factory ClinicDepartment.fromMap(String id, Map<String, dynamic> data) {
    return ClinicDepartment(
      id: id,
      clinicId: data['clinicId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      archived: data['archived'] as bool? ?? false,
    );
  }
}
