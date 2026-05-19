import 'package:flutter_test/flutter_test.dart';

import 'package:aplikasi_pendataan_mbg/app.dart';

void main() {
  testWidgets('aplikasi menampilkan halaman publik MyMbg', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyMbgApp());

    expect(find.text('MyMbg'), findsOneWidget);
    expect(find.text('Menu MBG Hari Ini'), findsOneWidget);
  });
}
