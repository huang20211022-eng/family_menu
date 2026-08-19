// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Family Menu';

  @override
  String get appNameZh => '家庭菜单';

  @override
  String get tagline => 'Your family\'s recipes, all in one place.';

  @override
  String get whatToEatToday => 'What should we eat today?';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get createAccount => 'Create Account';

  @override
  String get authComingSoon =>
      'Authentication will be connected in the next phase.';

  @override
  String get registrationComingSoon =>
      'Registration will be connected in the next phase.';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get passwordResetComingSoon =>
      'Password reset will be available in the next authentication phase.';
}
