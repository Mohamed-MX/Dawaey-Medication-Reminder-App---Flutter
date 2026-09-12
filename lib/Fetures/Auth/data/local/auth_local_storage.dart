import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_model.dart';

class AuthLocalStorage {
  static const String boxName = 'authBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  static Future<void> saveUser(UserModel user) async {
    var box = Hive.box(boxName);

    await box.put(
      'cachedUser',
      user.toJson(),
    );
  }

  static UserModel? getUser() {
    var box = Hive.box(boxName);

    var data = box.get('cachedUser');

    if (data == null) {
      return null;
    }

    return UserModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  static Future<void> deleteUser() async {
    var box = Hive.box(boxName);

    await box.delete('cachedUser');
  }

  static bool isOnboardingSeen() {
    var box = Hive.box(boxName);

    return box.get(
      'onboardingSeen',
      defaultValue: false,
    );
  }

  static Future<void> setOnboardingSeen() async {
    var box = Hive.box(boxName);

    await box.put(
      'onboardingSeen',
      true,
    );
  }
}