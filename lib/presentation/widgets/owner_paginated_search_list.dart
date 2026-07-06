import 'package:flutter/material.dart';

/// Paginated, searchable list for large owner admin datasets.
class OwnerPaginatedSearchList<T> extends StatefulWidget {
  const OwnerPaginatedSearchList({
    super.key,
    required this.items,
    required this.searchFilter,
    required this.itemBuilder,
    this.searchHint,
    this.pageSize = 30,
    this.emptyMessage,
    this.header,
  });

  final List<T> items;
  final bool Function(T item, String query) searchFilter;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String? searchHint;
  final int pageSize;
  final String? emptyMessage;
  final Widget? header;

  @override
  State<OwnerPaginatedSearchList<T>> createState() =>
      _OwnerPaginatedSearchListState<T>();
}

class _OwnerPaginatedSearchListState<T> extends State<OwnerPaginatedSearchList<T>> {
  final _searchController = TextEditingController();
  int _visibleCount = 30;

  @override
  void initState() {
    super.initState();
    _visibleCount = widget.pageSize;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant OwnerPaginatedSearchList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _visibleCount = widget.pageSize;
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() => _visibleCount = widget.pageSize);
  }

  List<T> get _filtered {
    final q = _searchController.text.trim();
    if (q.isEmpty) return widget.items;
    return widget.items.where((i) => widget.searchFilter(i, q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final visible = filtered.take(_visibleCount).toList();
    final hasMore = filtered.length > _visibleCount;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: widget.searchHint,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              isDense: true,
            ),
          ),
        ),
        if (widget.header != null) widget.header!,
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    widget.emptyMessage ?? '',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: visible.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= visible.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => _visibleCount += widget.pageSize);
                          },
                          child: Text(
                            '${filtered.length - _visibleCount} more',
                          ),
                        ),
                      );
                    }
                    return widget.itemBuilder(context, visible[index]);
                  },
                ),
        ),
      ],
    );
  }
}
