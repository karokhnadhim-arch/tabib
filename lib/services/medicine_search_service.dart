import '../data/medicine_catalog.dart';
import '../models/medicine.dart';
import 'doctor_medicine_favorites_service.dart';

/// Fast in-memory medicine search — favorites surface first.
class MedicineSearchService {
  MedicineSearchService({
    MedicineCatalog? catalog,
    DoctorMedicineFavoritesService? favorites,
    Iterable<Medicine>? additionalMedicines,
  })  : _catalog = catalog ?? MedicineCatalog.instance,
        _favorites = favorites,
        _additional = List<Medicine>.unmodifiable(additionalMedicines ?? const <Medicine>[]);

  final MedicineCatalog _catalog;
  final DoctorMedicineFavoritesService? _favorites;
  final List<Medicine> _additional;

  List<Medicine> get _allMedicines {
    final builtIn = _catalog.all;
    final ids = builtIn.map((m) => m.id).toSet();
    return [
      ...builtIn,
      ..._additional.where((m) => !m.archived && !ids.contains(m.id)),
    ];
  }

  Medicine? _byId(String id) {
    final builtIn = _catalog.byId(id);
    if (builtIn != null) return builtIn;
    for (final m in _additional) {
      if (m.id == id) return m;
    }
    return null;
  }

  List<Medicine> search({
    required String query,
    required String doctorId,
    int limit = 12,
  }) {
    final q = query.trim().toLowerCase();
    final favIds = _favorites?.favoritesFor(doctorId) ?? const [];
    final favMedicines = <Medicine>[];
    for (final id in favIds) {
      final m = _byId(id);
      if (m != null && (q.isEmpty || m.containsQuery(q))) {
        favMedicines.add(m);
      }
    }

    if (q.isEmpty) {
      return favMedicines.take(limit).toList();
    }

    final others = <Medicine>[];
    for (final m in _allMedicines) {
      if (favIds.contains(m.id)) continue;
      if (m.containsQuery(q)) others.add(m);
      if (others.length >= limit) break;
    }

    final combined = [...favMedicines, ...others];
    return combined.take(limit).toList();
  }
}
