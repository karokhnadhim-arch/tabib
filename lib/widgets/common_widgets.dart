import 'package:flutter/material.dart';

class SpecialtyIcon {
  static IconData forName(String iconName) {
    switch (iconName) {
      case 'dental':
        return Icons.medical_services_outlined;
      case 'ortho':
        return Icons.accessibility_new_outlined;
      case 'heart':
        return Icons.favorite_outline;
      case 'child':
        return Icons.child_care_outlined;
      case 'eye':
        return Icons.visibility_outlined;
      case 'skin':
        return Icons.face_outlined;
      default:
        return Icons.local_hospital_outlined;
    }
  }
}

class QueueStatusChip extends StatelessWidget {
  const QueueStatusChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: Colors.grey.shade600)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
