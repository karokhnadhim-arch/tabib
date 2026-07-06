/// Result of secretary-led patient registration.
class SecretaryPatientRegistrationResult {
  const SecretaryPatientRegistrationResult({
    this.errorKey,
    this.patientId,
  });

  final String? errorKey;
  final String? patientId;

  bool get isSuccess => errorKey == null && patientId != null;
}
