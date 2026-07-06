import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/investigation_request.dart';
import '../../../services/auth_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/investigation_status_list.dart';

enum _InvestigationTab { all, pending, completed }

/// Patient-facing investigations — pending and completed.
class PatientInvestigationsScreen extends StatefulWidget {
  const PatientInvestigationsScreen({super.key, this.initialTab});

  final String? initialTab;

  @override
  State<PatientInvestigationsScreen> createState() =>
      _PatientInvestigationsScreenState();
}

class _PatientInvestigationsScreenState extends State<PatientInvestigationsScreen> {
  late _InvestigationTab _tab;

  @override
  void initState() {
    super.initState();
    _tab = _parseTab(widget.initialTab);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final patientId = context.read<AuthService>().patientId;
      if (patientId.isNotEmpty) {
        context.read<InvestigationRequestProvider>().watchPatient(patientId);
      }
    });
  }

  _InvestigationTab _parseTab(String? raw) {
    return switch (raw) {
      'pending' => _InvestigationTab.pending,
      'completed' => _InvestigationTab.completed,
      _ => _InvestigationTab.all,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<InvestigationRequestProvider>();
    final requests = provider.requests;
    final dateFmt = DateFormat.yMMMd();

    final filtered = switch (_tab) {
      _InvestigationTab.pending =>
        requests.where((r) => r.hasPending).toList(),
      _InvestigationTab.completed => requests
          .where((r) => r.items.any((i) => !i.isPending))
          .toList(),
      _InvestigationTab.all => requests,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myInvestigations),
        backgroundColor: AppTheme.medicalBlue,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SegmentedButton<_InvestigationTab>(
              segments: [
                ButtonSegment(
                  value: _InvestigationTab.all,
                  label: Text(l10n.all),
                ),
                ButtonSegment(
                  value: _InvestigationTab.pending,
                  label: Text(l10n.pending),
                ),
                ButtonSegment(
                  value: _InvestigationTab.completed,
                  label: Text(l10n.completed),
                ),
              ],
              selected: {_tab},
              onSelectionChanged: (s) => setState(() => _tab = s.first),
            ),
          ),
        ),
      ),
      body: ScrollableResponsiveBody(
        child: provider.isLoading && requests.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : filtered.isEmpty
                ? _EmptyState(
                    message: switch (_tab) {
                      _InvestigationTab.pending =>
                        l10n.noPendingInvestigations,
                      _InvestigationTab.completed =>
                        l10n.noCompletedInvestigations,
                      _ => l10n.noInvestigationsYet,
                    },
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final request = filtered[index];
                      return _InvestigationRequestCard(
                        request: request,
                        dateLabel: dateFmt.format(request.updatedAt.toLocal()),
                        showPending: _tab != _InvestigationTab.completed,
                        showCompleted: _tab != _InvestigationTab.pending,
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
    required this.showPending,
    required this.showCompleted,
  });

  final InvestigationRequest request;
  final String dateLabel;
  final bool showPending;
  final bool showCompleted;

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
            InvestigationStatusList(
              requests: [request],
              showPending: showPending,
              showCompleted: showCompleted,
            ),
          ],
        ),
      ),
    );
  }
}
