import 'localized_text.dart';

class Clinic {
  const Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
  });

  final String id;
  final LocalizedText name;
  final LocalizedText address;
  final double latitude;
  final double longitude;
  final String phone;

  Map<String, dynamic> toMap() => {
        'name': name.toMap(),
        'address': address.toMap(),
        'latitude': latitude,
        'longitude': longitude,
        'phone': phone,
      };

  factory Clinic.fromFirestore(String id, Map<String, dynamic> data) {
    return Clinic(
      id: id,
      name: LocalizedText.fromMap(data['name'] as Map<String, dynamic>?),
      address: LocalizedText.fromMap(data['address'] as Map<String, dynamic>?),
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      phone: data['phone'] as String? ?? '',
    );
  }
}
