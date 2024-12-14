import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_update_checker/flutter_update_checker.dart';
import 'package:package_info_plus/package_info_plus.dart';

class CustomBindings extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

void main() {
  CustomBindings();

  const fakePackageName = 'com.vkontakte.android';
  const fakeCurrentVersion = '8.98';
  const fakeInstalledFromStore = 'ru.vk.store'; // 'com.apple.testflight'

  // For Tests
  const appStoreId = 564177498;
  const appGalleryId = 'C101104117';
  const appGalleryPackageName = fakePackageName;
  const ruStorePackageName = fakePackageName;

  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'APP',
      packageName: fakePackageName,
      version: fakeCurrentVersion,
      buildNumber: '1',
      buildSignature: 'test',
      installerStore: fakeInstalledFromStore,
    );
  });

  group('[Installed From] Store', () {
    final checker = UpdateStoreChecker(
      iosAppStoreId: appStoreId,
      iosAppStoreCountry: 'RU',
      androidAppGalleryId: appGalleryId,
      androidAppGalleryPackageName: appGalleryPackageName,
      androidRuStorePackage: ruStorePackageName,
    );

    String? storeVersion;

    test('[Installed From] Store Version', () async {
      storeVersion = await checker.getStoreVersion();
      debugPrint('[Installed From] Store Version: \t$storeVersion');
      expect(storeVersion, isNot('0.0.0'));
    });

    test('[Installed From] Store', () async {
      final isFound = await checker.checkUpdate(storeVersion: storeVersion);
      expect(isFound, true);
    });
  });

  group('App Store', () {
    final checker = UpdateStoreChecker(
      iosAppStoreId: appStoreId,
      iosAppStoreCountry: 'RU',
    );
    const storeType = StoreType.APP_STORE;
    String? storeVersion;

    test('App Store Version', () async {
      storeVersion = await checker.getStoreVersion(store: storeType);
      debugPrint('App Store Version: \t$storeVersion');
      expect(storeVersion, isNot('0.0.0'));
    });

    test('App Store', () async {
      final isFound = await checker.checkUpdate(
        store: storeType,
        storeVersion: storeVersion,
      );
      expect(isFound, true);
    });
  });

  group('Google Play', () {
    final checker = UpdateStoreChecker();
    const storeType = StoreType.GOOGLE_PLAY;
    String? storeVersion;

    test('Google Play Version', () async {
      storeVersion = await checker.getStoreVersion(store: storeType);
      debugPrint('Google Play Version: \t$storeVersion');
      expect(storeVersion, '0.0.0'); // because the api doesn't give the version
    });

    test('Google Play', () async {
      final isFound = await checker.checkUpdate(
        store: storeType,
        storeVersion: storeVersion,
      );
      expect(isFound, false); // because it must be installed from google play
    });
  });

  group('App Gallery', () {
    final checker = UpdateStoreChecker(
      androidAppGalleryId: appGalleryId,
      androidAppGalleryPackageName: appGalleryPackageName,
    );
    const storeType = StoreType.APP_GALLERY;

    String? storeVersion;

    test('App Gallery Version', () async {
      storeVersion = await checker.getStoreVersion(store: storeType);
      debugPrint('App Gallery Version: \t$storeVersion');
      expect(storeVersion, isNot('0.0.0'));
    });

    test('App Gallery', () async {
      final isFound = await checker.checkUpdate(
        store: storeType,
        storeVersion: storeVersion,
      );
      expect(isFound, true);
    });
  });

  group('RuStore', () {
    final checker = UpdateStoreChecker(
      androidRuStorePackage: ruStorePackageName,
    );
    const storeType = StoreType.RU_STORE;

    String? storeVersion;

    test('RuStore Version', () async {
      storeVersion = await checker.getStoreVersion(store: storeType);
      debugPrint('RuStore Version: \t$storeVersion');
      expect(storeVersion, isNot('0.0.0'));
    });

    test('RuStore', () async {
      final isFound = await checker.checkUpdate(
        store: storeType,
        storeVersion: storeVersion,
      );
      expect(isFound, true);
    });
  });
}
