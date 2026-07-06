/// Structured medicine line on a prescription — stored locally and in Firestore.
class PrescriptionLineItem {
  const PrescriptionLineItem({
    required this.medicineId,
    required this.genericName,
    required this.brandName,
    required this.strength,
    required this.form,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.notes,
  });

  final String medicineId;
  final String genericName;
  final String brandName;
  final String strength;
  final String form;
  final String dosage;
  final String frequency;
  final String duration;
  final String? notes;

  String get displayName => brandName.isNotEmpty ? brandName : genericName;

  String formatLine() {
    final base =
        '$displayName $strength ($form) — $dosage, $frequency × $duration';
    if (notes != null && notes!.trim().isNotEmpty) {
      return '$base. ${notes!.trim()}';
    }
    return base;
  }

  Map<String, dynamic> toMap() => {
        'medicineId': medicineId,
        'genericName': genericName,
        'brandName': brandName,
        'strength': strength,
        'form': form,
        'dosage': dosage,
        'frequency': frequency,
        'duration': duration,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };

  factory PrescriptionLineItem.fromMap(Map<String, dynamic> data) {
    return PrescriptionLineItem(
      medicineId: data['medicineId'] as String? ?? '',
      genericName: data['genericName'] as String? ?? '',
      brandName: data['brandName'] as String? ?? '',
      strength: data['strength'] as String? ?? '',
      form: data['form'] as String? ?? '',
      dosage: data['dosage'] as String? ?? '',
      frequency: data['frequency'] as String? ?? '',
      duration: data['duration'] as String? ?? '',
      notes: data['notes'] as String?,
    );
  }

  PrescriptionLineItem copyWith({
    String? dosage,
    String? frequency,
    String? duration,
    String? notes,
  }) {
    return PrescriptionLineItem(
      medicineId: medicineId,
      genericName: genericName,
      brandName: brandName,
      strength: strength,
      form: form,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
    );
  }
}
