import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/investigation_request.dart';
import '../../../services/auth_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/pending_investigations_panel.dart';

/// Patient-facing pending investigations — always available in the app.
class PatientInvestigationsScreen extends StatefulWidget {
  const PatientInvestigationsScreen({super.key});

  @override
  State<PatientInvestigationsScreen> createState() =>
      _PatientInvestigationsScreenState();
}

class _PatientInvestigationsScreenState extends State<PatientInvestigationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final patientId = context.read<AuthService>().patientId;
      if (patientId.isNotEmpty) {
        context.read<InvestigationRequestProvider>().watchPatient(patientId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<InvestigationRequestProvider>();
    final requests = provider.requests.where((r) => r.hasPending).toList();
    final dateFmt = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myInvestigations),
        backgroundColor: AppTheme.medicalBlue,
      ),
      body: ScrollableResponsiveBody(
        child: provider.isLoading && provider.requests.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : requests.isEmpty
                ? _EmptyState(message: l10n.noPendingInvestigations)
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: requests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return _InvestigationRequestCard(
                        request: request,
                        dateLabel: dateFmt.format(request.updatedAt.toLocal()),
                        l10n: l10n,
                      );
                    },
                  ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.biotech_outlined, size: 48, color: scheme.outline),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InvestigationRequestCard extends StatelessWidget {
  const _InvestigationRequestCard({
    required this.request,
    required this.dateLabel,
    required this.l10n,
  });

  final InvestigationRequest request;
  final String dateLabel;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.doctorName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Text(
                  dateLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PendingInvestigationsPanel(requests: [request]),
          ],
        ),
      ),
    );
  }
}
