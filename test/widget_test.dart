
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:zhkh_meter_app/viewmodels/home_view_model.dart';
import 'package:zhkh_meter_app/screens/home_screen.dart';

void main() {
  testWidgets('Главный экран отображает счётчики', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<HomeViewModel>(
        create: (_) => HomeViewModel(),
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Учёт ресурсов'), findsOneWidget);
  });
}
