import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:family_menu/app.dart';

void main() {
  testWidgets('login page renders in English by default',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FamilyMenuApp());
    await tester.pumpAndSettle();

    expect(find.text('Family Menu'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
  });

  testWidgets('language selector switches the UI to Simplified Chinese',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FamilyMenuApp());
    await tester.pumpAndSettle();

    expect(find.text('Email'), findsOneWidget);

    await tester.tap(find.text('中文'));
    await tester.pumpAndSettle();

    expect(find.text('邮箱'), findsOneWidget);
    expect(find.text('密码'), findsOneWidget);
    expect(find.text('登录'), findsOneWidget);
    expect(find.text('注册账号'), findsOneWidget);
    expect(find.text('忘记密码？'), findsOneWidget);
    expect(find.text('Email'), findsNothing);
  });

  testWidgets('password visibility toggle shows and hides the password',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FamilyMenuApp());
    await tester.pumpAndSettle();

    TextField passwordField() =>
        tester.widget<TextField>(find.byType(TextField).at(1));

    expect(passwordField().obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();
    expect(passwordField().obscureText, isFalse);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();
    expect(passwordField().obscureText, isTrue);
  });
}
