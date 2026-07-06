import '../data/medicine_catalog.dart';
import '../models/medicine.dart';
import 'doctor_medicine_favorites_service.dart';

/// Fast in-memory medicine search — favorites surface first.
class MedicineSearchService {
  MedicineSearchService({
    MedicineCatalog? catalog,
    DoctorMedicineFavoritesService? favorites,
  })  : _catalog = catalog ?? MedicineCatalog.instance,
        _favorites = favorites;

  final MedicineCatalog _catalog;
  final DoctorMedicineFavoritesService? _favorites;

  List<Medicine> search({
    required String query,
    required String doctorId,
    int limit = 12,
  }) {
    final q = query.trim().toLowerCase();
    final favIds = _favorites?.favoritesFor(doctorId) ?? const [];
    final favMedicines = <Medicine>[];
    for (final id in favIds) {
      final m = _catalog.byId(id);
      if (m != null && (q.isEmpty || m.containsQuery(q))) {
        favMedicines.add(m);
      }
    }

    if (q.isEmpty) {
      return favMedicines.take(limit).toList();
    }

    final others = <Medicine>[];
    for (final m in _catalog.all) {
      if (favIds.contains(m.id)) continue;
      if (m.containsQuery(q)) others.add(m);
      if (others.length >= limit) break;
    }

    final combined = [...favMedicines, ...others];
    return combined.take(limit).toList();
  }
}
