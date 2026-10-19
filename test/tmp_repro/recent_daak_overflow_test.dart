import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/models/daak/daak_model.dart';
import 'package:efiling_balochistan/views/screens/dashboard/components/dashboard_daak_overview_section.dart';
import 'package:efiling_balochistan/views/screens/dashboard/components/dashboard_recent_daak_section.dart';
import 'package:efiling_balochistan/views/screens/secretary/widgets/equal_height_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

List<DaakModel> items(String diary, int n) => [
  for (var i = 0; i < n; i++)
    DaakModel(
      id: i,
      diaryNo: diary,
      letterDate: DateTime(2026, 10, 1),
      subject: 'A fairly long subject line for the letter number $i',
      sourceDepartment: 'Services & General Administration Department',
    ),
];

Future<void> pump(WidgetTester t, double width, Widget child) async {
  t.view.physicalSize = Size(width, 2000);
  t.view.devicePixelRatio = 1;
  await t.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    ),
  );
  await t.pumpAndSettle();
}

void main() {
  for (final diary in ['D-12', 'CMS/DAAK/2026/10/000123-ADMIN-SECTION']) {
    for (final n in [0, 2, 5, 8]) {
      for (final loading in [false]) {
        testWidgets('mobile 320 diary=$diary n=$n loading=$loading', (t) async {
          await pump(t, 320, DashboardRecentDaakSection(items: items(diary, n), loading: loading));
          expect(t.takeException(), isNull);
        });
        for (final w in [700.0, 1000.0, 1400.0]) {
          testWidgets('row $w diary=$diary n=$n loading=$loading', (t) async {
            await pump(
              t,
              w,
              EqualHeightRow(
                children: [
                  DashboardDaakOverviewSection(items: items(diary, n), loading: loading, fill: true),
                  DashboardRecentDaakSection(items: items(diary, n), loading: loading),
                ],
              ),
            );
            expect(t.takeException(), isNull);
          });
        }
      }
    }
  }
}
