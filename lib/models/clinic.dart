import 'localized_text.dart';
import '../core/utils/clinic_subscription.dart';

export '../core/utils/clinic_subscription.dart'
    show SubscriptionPlan, SubscriptionPlanX;

class Clinic {
  const Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    this.subscriptionPlan = SubscriptionPlan.oneMonth,
    this.subscriptionActive = true,
    this.subscriptionStartedAt,
    this.subscriptionExpiresAt,
    this.subscriptionWarned7Days = false,
    this.subscriptionExpiredNotified = false,
  });

  final String id;
  final LocalizedText name;
  final LocalizedText address;
  final double latitude;
  final double longitude;
  final String phone;
  final SubscriptionPlan subscriptionPlan;
  final bool subscriptionActive;
  final DateTime? subscriptionStartedAt;
  final DateTime? subscriptionExpiresAt;
  final bool subscriptionWarned7Days;
  final bool subscriptionExpiredNotified;

  Clinic copyWith({
    String? id,
    LocalizedText? name,
    LocalizedText? address,
    double? latitude,
    double? longitude,
    String? phone,
    SubscriptionPlan? subscriptionPlan,
    bool? subscriptionActive,
    DateTime? subscriptionStartedAt,
    DateTime? subscriptionExpiresAt,
    bool? subscriptionWarned7Days,
    bool? subscriptionExpiredNotified,
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
      subscriptionStartedAt:
          subscriptionStartedAt ?? this.subscriptionStartedAt,
      subscriptionExpiresAt:
          subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      subscriptionWarned7Days:
          subscriptionWarned7Days ?? this.subscriptionWarned7Days,
      subscriptionExpiredNotified:
          subscriptionExpiredNotified ?? this.subscriptionExpiredNotified,
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
        if (subscriptionStartedAt != null)
          'subscriptionStartedAt':
              subscriptionStartedAt!.millisecondsSinceEpoch,
        if (subscriptionExpiresAt != null)
          'subscriptionExpiresAt':
              subscriptionExpiresAt!.millisecondsSinceEpoch,
        if (subscriptionWarned7Days) 'subscriptionWarned7Days': true,
        if (subscriptionExpiredNotified) 'subscriptionExpiredNotified': true,
      };

  factory Clinic.fromFirestore(String id, Map<String, dynamic> data) {
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
      subscriptionStartedAt: _parseDate(data['subscriptionStartedAt']),
      subscriptionExpiresAt: _parseDate(data['subscriptionExpiresAt']),
      subscriptionWarned7Days: data['subscriptionWarned7Days'] == true,
      subscriptionExpiredNotified: data['subscriptionExpiredNotified'] == true,
    );
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    try {
      return (raw as dynamic).toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }
}
