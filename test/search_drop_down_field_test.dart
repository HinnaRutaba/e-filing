import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/search_drop_down_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _viewport = Size(400, 800);

/// A scrollable page holding a plain text field, then the search field near the
/// bottom of the viewport — so the suggestions box has to flip upwards, over
/// the text field above it.
Widget _harness({
  required ValueChanged<String> onSelected,
  required ScrollController scrollController,
  FocusNode? focusNode,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            const SizedBox(
              height: 700,
              child: Align(
                alignment: Alignment.topCenter,
                child: TextField(key: Key('other-field')),
              ),
            ),
            SearchDropDownField<String>(
              focusNode: focusNode,
              labelText: 'Forward To',
              hintText: 'Search user',
              suggestionsCallback: (pattern) => const ['Alice', 'Bob'],
              itemBuilder: (context, item) => Text(item),
              onSelected: onSelected,
            ),
            const SizedBox(height: 600),
          ],
        ),
      ),
    ),
  );
}

void main() {
  late ScrollController scrollController;

  setUp(() => scrollController = ScrollController());
  tearDown(() => scrollController.dispose());

  // The search field is the second of the two text fields on the page.
  final searchField = find.byType(TextField).last;

  Future<void> pumpHarness(
    WidgetTester tester, {
    ValueChanged<String>? onSelected,
    FocusNode? focusNode,
  }) async {
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _harness(
        onSelected: onSelected ?? (_) {},
        scrollController: scrollController,
        focusNode: focusNode,
      ),
    );
  }

  testWidgets('suggestion is selectable when the box flips upwards', (
    tester,
  ) async {
    String? selected;
    await pumpHarness(tester, onSelected: (v) => selected = v);

    await tester.tap(searchField);
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget, reason: 'box should be open');
    // Guards the premise: the box is painted above the field, over the text
    // field higher up the page. This is the case that used to fall through to
    // whatever was underneath.
    expect(
      tester.getBottomLeft(find.text('Alice')).dy,
      lessThan(tester.getTopLeft(searchField).dy),
      reason: 'box should have flipped upwards',
    );

    await tester.tap(find.text('Alice'));
    await tester.pumpAndSettle();

    expect(selected, 'Alice');
  });

  testWidgets('dragging the page dismisses the suggestions box', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await pumpHarness(tester, focusNode: focusNode);

    await tester.tap(searchField);
    await tester.pumpAndSettle();
    expect(find.text('Alice'), findsOneWidget);

    // Dragging from the other text field: it shares the search field's tap
    // region group, so onTapOutside stays silent and only the scroll listener
    // can dismiss the box here.
    await tester.drag(
      find.byKey(const Key('other-field')),
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();

    expect(scrollController.position.pixels, greaterThan(0), reason: 'sanity');
    expect(focusNode.hasFocus, isFalse);
    expect(find.text('Alice'), findsNothing, reason: 'box should be dismissed');
  });

  testWidgets('a programmatic scroll leaves the open box alone', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await pumpHarness(tester, focusNode: focusNode);

    await tester.tap(searchField);
    await tester.pumpAndSettle();
    expect(find.text('Alice'), findsOneWidget);

    // What ensureFieldVisible does when the field takes focus: it must not
    // dismiss the box it was called to make room for.
    scrollController.animateTo(
      120,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
    await tester.pumpAndSettle();

    expect(scrollController.position.pixels, 120, reason: 'sanity');
    expect(focusNode.hasFocus, isTrue);
    expect(find.text('Alice'), findsOneWidget);
  });
}
