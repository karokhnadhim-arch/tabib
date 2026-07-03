/// City-targeted patient advertisement for the home carousel.
class Advertisement {
  const Advertisement({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.imageThumbnailUrl,
    this.buttonLabel,
    this.linkUrl,
    this.city,
    this.isNational = false,
    this.startsAt,
    this.endsAt,
    this.isEnabled = true,
  });

  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? imageThumbnailUrl;
  final String? buttonLabel;
  final String? linkUrl;
  final String? city;
  final bool isNational;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool isEnabled;

  /// Whether the ad is within its schedule and marked active.
  bool get isPublished {
    if (!isEnabled) return false;
    final now = DateTime.now();
    if (startsAt != null && now.isBefore(startsAt!)) return false;
    if (endsAt != null && now.isAfter(endsAt!)) return false;
    return true;
  }

  /// Legacy alias used by older call sites.
  bool get isActive => isPublished;

  String? get displayImageUrl => imageThumbnailUrl ?? imageUrl;

  static DateTime? _parseMs(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) {
      return DateTime.fromMillisecondsSinceEpoch(raw.toInt());
    }
    return null;
  }

  factory Advertisement.fromFirestore(String id, Map<String, dynamic> data) {
    return Advertisement(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      imageThumbnailUrl: data['imageThumbnailUrl'] as String?,
      buttonLabel: data['buttonLabel'] as String?,
      linkUrl: data['linkUrl'] as String?,
      city: data['city'] as String?,
      isNational: data['isNational'] == true,
      startsAt: _parseMs(data['startsAt']),
      endsAt: _parseMs(data['endsAt'] ?? data['expiresAt']),
      isEnabled: data['isActive'] != false && data['isEnabled'] != false,
    );
  }
}

/// Normalizes city names for advertisement targeting.
String? normalizeAdvertisementCity(String? city) {
  if (city == null) return null;
  final trimmed = city.trim();
  if (trimmed.isEmpty) return null;
  return trimmed.toLowerCase();
}

bool advertisementMatchesCity(Advertisement ad, String? patientCity) {
  final target = normalizeAdvertisementCity(patientCity);
  if (target == null || target.isEmpty) return false;
  if (ad.isNational) return false;
  final adCity = normalizeAdvertisementCity(ad.city);
  return adCity != null && adCity == target;
}
