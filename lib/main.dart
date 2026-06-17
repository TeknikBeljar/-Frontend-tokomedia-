import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/constants.dart';
import 'config/theme.dart';
import 'providers/product_provider.dart';
import 'screens/login_screen.dart';
import 'screens/responsive_layout.dart';
import 'screens/shared/upload_product_screen.dart';
import 'screens/web/login_web.dart';
import 'screens/web/register_web.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: const TokomediaApp(),
    ),
  );
}

class TokomediaApp extends StatelessWidget {
  const TokomediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tokomedia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const _AppEntry(),
      routes: {
        '/home': (_) => const ResponsiveLayout(),
        '/login': (_) => const _AdaptiveLoginRoute(),
        '/register': (_) => const _AdaptiveRegisterRoute(),
        '/upload-product': (_) => const UploadProductScreen(),
      },
    );
  }
}

class _AppEntry extends StatelessWidget {
  const _AppEntry();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_usesMobileExperience(context, constraints.maxWidth)) {
          return const RegisterScreen();
        }

        return const RegisterWeb();
      },
    );
  }
}

class _AdaptiveLoginRoute extends StatelessWidget {
  const _AdaptiveLoginRoute();

  @override
  Widget build(BuildContext context) {
    if (_usesMobileExperience(context, MediaQuery.sizeOf(context).width)) {
      return const LoginScreen();
    }

    return const LoginWeb();
  }
}

class _AdaptiveRegisterRoute extends StatelessWidget {
  const _AdaptiveRegisterRoute();

  @override
  Widget build(BuildContext context) {
    if (_usesMobileExperience(context, MediaQuery.sizeOf(context).width)) {
      return const RegisterScreen();
    }

    return const RegisterWeb();
  }
}

bool _usesMobileExperience(BuildContext context, double width) {
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    return true;
  }

  return width < AppBreakpoints.desktop;
}
