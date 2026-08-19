import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'l10n/app_localizations.dart';
import 'pages/login_page.dart';

/// Root application widget.
///
/// Owns the current [Locale] so the language selector can switch the whole
/// app's language immediately. The locale is held in memory only for this
/// milestone (persistence arrives in a later phase).
class FamilyMenuApp extends StatefulWidget {
  const FamilyMenuApp({super.key});

  @override
  State<FamilyMenuApp> createState() => _FamilyMenuAppState();
}

class _FamilyMenuAppState extends State<FamilyMenuApp> {
  Locale _locale = _resolveInitialLocale();

  /// Follows the system language: Simplified Chinese if the system is Chinese,
  /// otherwise English.
  static Locale _resolveInitialLocale() {
    final Locale? system =
        WidgetsBinding.instance.platformDispatcher.locales.firstOrNull;
    if (system != null && system.languageCode == 'zh') {
      return const Locale('zh', 'CN');
    }
    return const Locale('en');
  }

  void _setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Menu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: LoginPage(onLocaleChanged: _setLocale),
    );
  }
}
