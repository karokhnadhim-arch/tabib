import 'localized_text.dart';

/// Doctor specialty or centralized business type (same Firestore `specialties` collection).
class Specialty {
  const Specialty({
    required this.id,
    required this.name,
    required this.iconName,
    this.isBusinessType = false,
    this.isActive = true,
  });

  final String id;
  final LocalizedText name;
  final String iconName;
  /// When true, this entry is a business type; otherwise a doctor specialty.
  final bool isBusinessType;
  /// Inactive types are hidden from patient browse and account pickers.
  final bool isActive;

  Specialty copyWith({
    String? id,
    LocalizedText? name,
    String? iconName,
    bool? isBusinessType,
    bool? isActive,
  }) =>
      Specialty(
        id: id ?? this.id,
        name: name ?? this.name,
        iconName: iconName ?? this.iconName,
        isBusinessType: isBusinessType ?? this.isBusinessType,
        isActive: isActive ?? this.isActive,
      );

  Map<String, dynamic> toMap() => {
        'name': name.toMap(),
        'iconName': iconName,
        if (isBusinessType) 'isBusinessType': true,
        if (!isActive) 'isActive': false,
      };

  factory Specialty.fromFirestore(String id, Map<String, dynamic> data) {
    return Specialty(
      id: id,
      name: LocalizedText.fromMap(data['name'] as Map<String, dynamic>?),
      iconName: data['iconName'] as String? ?? 'medical',
      isBusinessType: data['isBusinessType'] == true,
      isActive: data['isActive'] != false,
    );
  }
}
