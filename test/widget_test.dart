import 'package:flutter_test/flutter_test.dart';

import 'package:ezan_app/main.dart';

void main() {
  testWidgets('Ezan app renders without crashes', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MyApp), findsOneWidget);
    expect(find.text('Ezan Hatırlatıcı'), findsOneWidget);
  });
}

