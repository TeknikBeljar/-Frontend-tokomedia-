import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tokomedia/main.dart';
import 'package:tokomedia/providers/product_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tokomedia/providers/auth_provider.dart';
import 'package:tokomedia/screens/responsive_layout.dart';
import 'package:tokomedia/services/auth_api_service.dart';
import 'package:tokomedia/services/product_api_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthApiService.isTestMode = true;
    ProductApiService.isTestMode = true;
  });

  testWidgets('renders mobile register before home', (tester) async {
    _setMobileView(tester);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const TokomediaApp(),
      ),
    );
    expect(find.text('atau daftar dengan'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), '08123456789');
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('0812-3456-789'), findsOneWidget);
    expect(find.text('Ya, Benar'), findsOneWidget);

    await tester.tap(find.text('Ya, Benar'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Metode Verifikasi'), findsOneWidget);
    expect(find.text('WhatsApp ke'), findsOneWidget);
    expect(find.text('SMS ke'), findsOneWidget);
    expect(find.text('628123456789'), findsNWidgets(2));

    await tester.tap(find.text('WhatsApp ke'));
    await tester.pump();

    expect(find.text('Daftar Sekarang di Tokomedia'), findsOneWidget);
    expect(find.text('Masukkan Kode Verifikasi'), findsOneWidget);
    expect(
      find.text(
        'Kode verifikasi telah dikirim melalui WhatsApp ke\n628123456789.',
      ),
      findsOneWidget,
    );

    await tester.enterText(find.byType(EditableText), '123456');
    await tester.pumpAndSettle();

    expect(find.text('abaya'), findsOneWidget);
  });

  testWidgets('guards mobile home route before authentication', (tester) async {
    _setMobileView(tester);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(home: ResponsiveLayout()),
      ),
    );

    expect(find.text('atau daftar dengan'), findsOneWidget);
    expect(find.text('abaya'), findsNothing);
  });

  testWidgets('opens reference-style mobile login from register link', (
    tester,
  ) async {
    _setMobileView(tester);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const TokomediaApp(),
      ),
    );
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Masuk ke Tokomedia'), findsOneWidget);
    expect(find.text('Lanjut'), findsOneWidget);
    expect(find.text('atau masuk dengan'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('TikTok Shop'), findsOneWidget);
    expect(find.text('Daftar Sekarang'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), '08123456789');
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Lanjut'));
    await tester.pumpAndSettle();

    expect(find.text('0812-3456-789'), findsOneWidget);
    await tester.tap(find.text('Ya, Benar'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Metode Verifikasi'), findsOneWidget);
    await tester.tap(find.text('WhatsApp ke'));
    await tester.pump();

    expect(find.text('Masuk ke Tokomedia'), findsOneWidget);
    expect(find.text('Masukkan Kode Verifikasi'), findsOneWidget);
    expect(
      find.text(
        'Kode verifikasi telah dikirim melalui WhatsApp ke\n628123456789.',
      ),
      findsOneWidget,
    );
  });
}

void _setMobileView(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
