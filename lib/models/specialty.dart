import 'localized_text.dart';

class Specialty {
  const Specialty({
    required this.id,
    required this.name,
    required this.iconName,
  });

  final String id;
  final LocalizedText name;
  final String iconName;

  Map<String, dynamic> toMap() => {
        'name': name.toMap(),
        'iconName': iconName,
      };

  factory Specialty.fromFirestore(String id, Map<String, dynamic> data) {
    return Specialty(
      id: id,
      name: LocalizedText.fromMap(data['name'] as Map<String, dynamic>?),
      iconName: data['iconName'] as String? ?? 'medical',
    );
  }
}
