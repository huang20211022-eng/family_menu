// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Family Menu';

  @override
  String get appNameZh => '家庭菜单';

  @override
  String get tagline => '把家里的菜谱，都放在一个地方。';

  @override
  String get whatToEatToday => '今天吃什么？';

  @override
  String get emailLabel => '邮箱';

  @override
  String get passwordLabel => '密码';

  @override
  String get signIn => '登录';

  @override
  String get createAccount => '注册账号';

  @override
  String get authComingSoon => '登录功能将在下一阶段接入。';

  @override
  String get registrationComingSoon => '注册功能将在下一阶段接入。';
}

/// The translations for Chinese, as used in China (`zh_CN`).
class AppLocalizationsZhCn extends AppLocalizationsZh {
  AppLocalizationsZhCn() : super('zh_CN');

  @override
  String get appName => 'Family Menu';

  @override
  String get appNameZh => '家庭菜单';

  @override
  String get tagline => '把家里的菜谱，都放在一个地方。';

  @override
  String get whatToEatToday => '今天吃什么？';

  @override
  String get emailLabel => '邮箱';

  @override
  String get passwordLabel => '密码';

  @override
  String get signIn => '登录';

  @override
  String get createAccount => '注册账号';

  @override
  String get authComingSoon => '登录功能将在下一阶段接入。';

  @override
  String get registrationComingSoon => '注册功能将在下一阶段接入。';
}
