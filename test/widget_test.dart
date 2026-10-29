import 'package:flutter_test/flutter_test.dart';
import 'package:zhkh_meter_app/main.dart';

void main() {
  testWidgets('Главный экран отображает счётчики', (WidgetTester tester) async {
    await tester.pumpWidget(const ZhkhMeterApp());

    expect(find.text('Учёт ресурсов'), findsOneWidget);
    expect(find.text('Холодная вода'), findsOneWidget);
    expect(find.text('Горячая вода'), findsOneWidget);
    expect(find.text('Электричество'), findsOneWidget);
  });
}
