import 'package:hive_flutter/hive_flutter.dart';

class OnboardingLocalStorage {
  static const String boxName = 'appSettings';

  static const String onboardingSeenKey =
      'onboardingSeen';

  static Future<void> saveOnboardingSeen() async {
    final box = await Hive.openBox(
      boxName,
    );

    await box.put(
      onboardingSeenKey,
      true,
    );
  }

  static Future<bool> isOnboardingSeen() async {
    final box = await Hive.openBox(
      boxName,
    );

    return box.get(
      onboardingSeenKey,
      defaultValue: false,
    );
  }
}