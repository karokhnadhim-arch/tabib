import 'localized_text.dart';

class Specialty {
  const Specialty({
    required this.id,
    required this.name,
    required this.iconName,
    this.isBusinessType = false,
  });

  final String id;
  final LocalizedText name;
  final String iconName;
  /// When true, shown for business account creation; otherwise for doctors.
  final bool isBusinessType;

  Map<String, dynamic> toMap() => {
        'name': name.toMap(),
        'iconName': iconName,
        if (isBusinessType) 'isBusinessType': true,
      };

  factory Specialty.fromFirestore(String id, Map<String, dynamic> data) {
    return Specialty(
      id: id,
      name: LocalizedText.fromMap(data['name'] as Map<String, dynamic>?),
      iconName: data['iconName'] as String? ?? 'medical',
      isBusinessType: data['isBusinessType'] == true,
    );
  }
}
