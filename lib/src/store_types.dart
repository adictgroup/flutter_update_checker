// ignore_for_file: constant_identifier_names

/// Enum representing different types of app stores where an app can be installed from.
enum StoreType {
  APP_STORE(packageName: 'com.apple', title: 'App Store'),
  TEST_FLIGHT(packageName: 'com.apple.testflight', title: 'Test Flight'),
  iOS_SIMULATOR(packageName: 'com.apple.simulator', title: 'iOS Simulator'),
  APP_GALLERY(packageName: 'com.huawei.appmarket', title: 'App Gallery'),
  GOOGLE_PLAY(packageName: 'com.android.vending', title: 'Google Play'),
  RU_STORE(packageName: 'ru.vk.store', title: 'RuStore');

  const StoreType({
    required String packageName,
    required String title,
  })  : _packageName = packageName,
        _title = title;

  final String _packageName;
  final String _title;

  String get package => _packageName;
  String get title => _title;
}
