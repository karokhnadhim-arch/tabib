import 'package:flutter/material.dart';

import 'monitoring_interactive_chart.dart';

typedef AnalyticsChartDef = ({
  String title,
  List<double> values,
  Color color,
  bool barMode,
});

/// Paginated Material 3 chart grid — core analytics on page 1, extended on page 2.
class PaginatedAnalyticsChartGrid extends StatefulWidget {
  const PaginatedAnalyticsChartGrid({
    super.key,
    required this.coreCharts,
    this.extendedCharts = const [],
    this.pageSize = 6,
  });

  final List<AnalyticsChartDef> coreCharts;
  final List<AnalyticsChartDef> extendedCharts;
  final int pageSize;

  @override
  State<PaginatedAnalyticsChartGrid> createState() =>
      _PaginatedAnalyticsChartGridState();
}

class _PaginatedAnalyticsChartGridState extends State<PaginatedAnalyticsChartGrid> {
  final _pageController = PageController();
  int _pageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<List<AnalyticsChartDef>> get _pages {
    final all = [...widget.coreCharts, ...widget.extendedCharts];
    if (all.isEmpty) return [[]];
    final pages = <List<AnalyticsChartDef>>[];
    for (var i = 0; i < all.length; i += widget.pageSize) {
      pages.add(all.sublist(i, (i + widget.pageSize).clamp(0, all.length)));
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 420,
          child: PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            onPageChanged: (index) => setState(() => _pageIndex = index),
            itemBuilder: (context, page) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final crossCount = constraints.maxWidth >= 900 ? 2 : 1;
                  final charts = pages[page];
                  return GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: crossCount == 2 ? 1.55 : 1.35,
                    ),
                    itemCount: charts.length,
                    itemBuilder: (context, index) {
                      final chart = charts[index];
                      return MonitoringInteractiveChart(
                        title: chart.title,
                        values: chart.values,
                        color: chart.color,
                        barMode: chart.barMode,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        if (pages.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pages.length, (index) {
              final active = index == _pageIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? scheme.primary : scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
