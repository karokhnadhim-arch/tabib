import 'doctor.dart';

class DoctorPage {
  const DoctorPage({
    required this.doctors,
    required this.hasMore,
    this.nextCursor,
  });

  final List<Doctor> doctors;
  final bool hasMore;
  final Object? nextCursor;
}
