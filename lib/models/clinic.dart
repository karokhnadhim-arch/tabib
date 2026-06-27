import 'localized_text.dart';

enum SubscriptionPlan { free, basic, premium }

extension SubscriptionPlanX on SubscriptionPlan {
  String get storageKey => name;

  static SubscriptionPlan fromKey(String? key) {
    return SubscriptionPlan.values.firstWhere(
      (p) => p.name == key,
      orElse: () => SubscriptionPlan.basic,
    );
  }
}

class Clinic {
  const Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    this.subscriptionPlan = SubscriptionPlan.basic,
    this.subscriptionActive = true,
    this.subscriptionExpiresAt,
  });

  final String id;
  final LocalizedText name;
  final LocalizedText address;
  final double latitude;
  final double longitude;
  final String phone;
  final SubscriptionPlan subscriptionPlan;
  final bool subscriptionActive;
  final DateTime? subscriptionExpiresAt;

  Clinic copyWith({
    String? id,
    LocalizedText? name,
    LocalizedText? address,
    double? latitude,
    double? longitude,
    String? phone,
    SubscriptionPlan? subscriptionPlan,
    bool? subscriptionActive,
    DateTime? subscriptionExpiresAt,
  }) {
    return Clinic(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionActive: subscriptionActive ?? this.subscriptionActive,
      subscriptionExpiresAt:
          subscriptionExpiresAt ?? this.subscriptionExpiresAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name.toMap(),
        'address': address.toMap(),
        'latitude': latitude,
        'longitude': longitude,
        'phone': phone,
        'subscriptionPlan': subscriptionPlan.storageKey,
        'subscriptionActive': subscriptionActive,
        if (subscriptionExpiresAt != null)
          'subscriptionExpiresAt':
              subscriptionExpiresAt!.millisecondsSinceEpoch,
      };

  factory Clinic.fromFirestore(String id, Map<String, dynamic> data) {
    final expiresRaw = data['subscriptionExpiresAt'];
    DateTime? expiresAt;
    if (expiresRaw is int) {
      expiresAt = DateTime.fromMillisecondsSinceEpoch(expiresRaw);
    } else if (expiresRaw != null) {
      try {
        expiresAt = (expiresRaw as dynamic).toDate() as DateTime;
      } catch (_) {}
    }

    return Clinic(
      id: id,
      name: LocalizedText.fromMap(data['name'] as Map<String, dynamic>?),
      address: LocalizedText.fromMap(data['address'] as Map<String, dynamic>?),
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      phone: data['phone'] as String? ?? '',
      subscriptionPlan:
          SubscriptionPlanX.fromKey(data['subscriptionPlan'] as String?),
      subscriptionActive: data['subscriptionActive'] != false,
      subscriptionExpiresAt: expiresAt,
    );
  }
}
