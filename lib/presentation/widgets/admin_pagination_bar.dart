import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Simple client-side pagination controls for admin lists.
class AdminPaginationBar extends StatelessWidget {
  const AdminPaginationBar({
    super.key,
    required this.page,
    required this.pageCount,
    required this.pageSize,
    required this.pageSizes,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  final int page;
  final int pageCount;
  final int pageSize;
  final List<int> pageSizes;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    if (pageCount <= 1 && pageSizes.length <= 1) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final safePage = page.clamp(0, pageCount > 0 ? pageCount - 1 : 0);

    return Material(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Previous',
                  onPressed: safePage > 0
                      ? () => onPageChanged(safePage - 1)
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  l10n.pageOf(safePage + 1, pageCount == 0 ? 1 : pageCount),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                IconButton(
                  tooltip: 'Next',
                  onPressed: safePage < pageCount - 1
                      ? () => onPageChanged(safePage + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.itemsPerPage,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: pageSize,
                  underline: const SizedBox.shrink(),
                  items: pageSizes
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text('$s'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) onPageSizeChanged(v);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Paginate a list in memory.
List<T> paginateSlice<T>(List<T> items, int page, int pageSize) {
  if (items.isEmpty) return const [];
  final start = page * pageSize;
  if (start >= items.length) return const [];
  final end = (start + pageSize).clamp(0, items.length);
  return items.sublist(start, end);
}

int pageCountFor(int itemCount, int pageSize) {
  if (itemCount == 0) return 1;
  return (itemCount + pageSize - 1) ~/ pageSize;
}
