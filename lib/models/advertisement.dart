/// City-targeted or national patient advertisement.
class Advertisement {
  const Advertisement({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.buttonLabel,
    this.linkUrl,
    this.city,
    this.isNational = false,
    this.expiresAt,
  });

  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? buttonLabel;
  final String? linkUrl;
  final String? city;
  final bool isNational;
  final DateTime? expiresAt;

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isActive => !isExpired;

  factory Advertisement.fromFirestore(String id, Map<String, dynamic> data) {
    final expiresMs = (data['expiresAt'] as num?)?.toInt();
    return Advertisement(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      buttonLabel: data['buttonLabel'] as String?,
      linkUrl: data['linkUrl'] as String?,
      city: data['city'] as String?,
      isNational: data['isNational'] == true,
      expiresAt: expiresMs != null
          ? DateTime.fromMillisecondsSinceEpoch(expiresMs)
          : null,
    );
  }
}
