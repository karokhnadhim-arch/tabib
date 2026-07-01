import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/doctor.dart';
import '../../utils/queue_slot_utils.dart';

/// Bottom sheet for selecting a queue date/time slot before joining.
Future<QueueTimeSlot?> showQueueBookingSheet(
  BuildContext context,
  Doctor provider,
) {
  return showModalBottomSheet<QueueTimeSlot>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _QueueBookingSheet(provider: provider),
  );
}

class _QueueBookingSheet extends StatefulWidget {
  const _QueueBookingSheet({required this.provider});

  final Doctor provider;

  @override
  State<_QueueBookingSheet> createState() => _QueueBookingSheetState();
}

class _QueueBookingSheetState extends State<_QueueBookingSheet> {
  QueueTimeSlot? _selected;
  late final List<QueueTimeSlot> _slots;

  @override
  void initState() {
    super.initState();
    _slots = QueueSlotUtils.upcomingSlots(widget.provider);
    if (_slots.isNotEmpty) _selected = _slots.first;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.selectQueueSlot,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.selectTimeSlotHint,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          if (_slots.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                l10n.noQueueSlotsAvailable,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          else
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.45,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _slots.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final slot = _slots[index];
                    final selected = _selected == slot;
                    return Material(
                      color: selected
                          ? AppTheme.medicalGreen.withOpacity(0.1)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => setState(() => _selected = slot),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                color: selected
                                    ? AppTheme.medicalGreen
                                    : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  QueueSlotUtils.formatSlot(context, slot),
                                  style: TextStyle(
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (selected)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppTheme.medicalGreen,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _selected == null
                ? null
                : () => Navigator.pop(context, _selected),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.medicalGreen,
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(l10n.joinQueue),
          ),
        ],
      ),
    );
  }
}
