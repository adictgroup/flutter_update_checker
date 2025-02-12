import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'datasources/app_store_datasource.dart';
import 'datasources/google_play_datasource.dart';
import 'datasources/huawei_datasource.dart';
import 'datasources/i_store_datasource.dart';
import 'datasources/ru_store_datasource.dart';
import 'store_types.dart';

/// UpdateStoreChecker class
///
/// This class allows checking for updates in the app store
/// where the app was installed from. It supports App Store, Google Play,
/// Huawei AppGallery, and RuStore.
///
/// Example usage:
///
/// ```dart
/// final updateChecker = UpdateStoreChecker(
///   iosAppStoreId: 564177498,
///   androidAppGalleryId: 'C101104117',
///   androidAppGalleryPackageName: 'com.vkontakte.android',
///   androidRuStorePackage: 'com.vkontakte.android',
///   androidGooglePlayPackage: 'com.vkontakte.android',
/// );
///
/// // Check update
/// bool isUpdateAvailable = await updateChecker.checkUpdate();
///
/// // Get version from Store
/// String storeVersion = await updateChecker.getStoreVersion();
///
/// // Open Store Link
/// await updateChecker.update();
/// ```

class UpdateStoreChecker {
  // Store-specific identifiers for checking updates
  int? _iosAppStoreId;
  String? _iosAppStoreCountry;
  String? _androidAppGalleryId;
  String? _androidAppGalleryPackageName;
  String? _androidRuStorePackage;

  /// Constructor for UpdateStoreChecker
  ///
  /// The constructor accepts optional parameters for different store identifiers.
  ///
  /// [iosAppStoreId] - ID of the app in the iOS App Store. // https://apps.apple.com/en/app/idXXXXXXXXX
  /// [iosAppStoreCountry] - Country of the app in the iOS App Store. // https://apps.apple.com/XX/app/id123455
  /// [androidGooglePlayPackage] - Package name of the app in Google Play. // https://play.google.com/store/apps/details?id=xxx.xxxxxx.xxxxx
  /// [androidAppGalleryId] - ID of the app in Huawei AppGallery. // https://appgallery.huawei.ru/app/CXXXXXXXXX
  /// [androidAppGalleryPackageName] - Package name in Huawei AppGallery.
  /// [androidRuStorePackage] - Package name in RuStore.
  ///
  UpdateStoreChecker({
    int? iosAppStoreId,
    String? iosAppStoreCountry,
    // ignore: avoid_unused_constructor_parameters
    String? androidGooglePlayPackage,
    String? androidAppGalleryId,
    String? androidAppGalleryPackageName,
    String? androidRuStorePackage,
  }) : assert(
          (androidAppGalleryId == null &&
                  androidAppGalleryPackageName == null) ||
              (androidAppGalleryId != null &&
                  androidAppGalleryPackageName != null),
          'If androidAppGalleryId is not null, androidAppGalleryPackageName must also be not null, and vice versa.',
        ) {
    _iosAppStoreId = iosAppStoreId;
    _iosAppStoreCountry = iosAppStoreCountry;
    _androidAppGalleryId = androidAppGalleryId;
    _androidAppGalleryPackageName = androidAppGalleryPackageName;
    _androidRuStorePackage = androidRuStorePackage;
  }

  /// Checks if an update is available for the app in the store.
  ///
  /// This method identifies the store from where the app was installed and
  /// checks for an available update. It also allows providing a specific
  /// store type or version for comparison.
  ///
  /// [store] - Optional, specify the store to check. If null, it will auto-detect.
  /// [storeVersion] - Optional, specify a version to compare with the store's version.
  ///
  /// Returns `true` if an update is available, otherwise `false`.
  Future<bool> checkUpdate({StoreType? store, String? storeVersion}) async {
    try {
      // Determine the store type (App Store, Google Play, etc.)
      final type = store ?? await getStoreType();
      if (type == null) return false;

      // Get the data source for the specific store type
      final source = await _getStoreDataSource(type);
      if (source == null) return false;

      // Check if an update is available in the store
      return _checkUpdateStore(source, storeVersion: storeVersion);
    } on Exception catch (e) {
      debugPrint('[🔄 Update: checkUpdate] err: $e');
      return false;
    }
  }

  /// Opens the app's store page to update the app.
  ///
  /// This method redirects the user to the store page of the app for updating.
  ///
  /// [store] - Optional, specify the store type. If null, it will auto-detect.
  Future<void> update({StoreType? store}) async {
    try {
      // Determine the store type
      final type = store ?? await getStoreType();
      if (type == null) return;

      // Get the data source for the store type
      final source = await _getStoreDataSource(type);
      if (source == null) return;

      // Redirect to the update page in the store
      return source.update();
    } on Exception catch (e) {
      debugPrint('[🔄 Update: update] err: $e');
    }
  }

  /// Retrieves the current version of the app in the store.
  ///
  /// This method fetches the version of the app from the respective app store.
  ///
  /// [store] - Optional, specify the store type. If null, it will auto-detect.
  ///
  /// Returns the version of the app as a string, or "0.0.0" if it fails.
  Future<String> getStoreVersion({StoreType? store}) async {
    try {
      // Determine the store type
      final type = store ?? await getStoreType();
      if (type == null) return '0.0.0';

      // Get the data source for the store type
      final source = await _getStoreDataSource(type);
      if (source == null) return '0.0.0';

      // Fetch the version from the store
      return _getStoreVersion(source);
    } on Exception catch (e) {
      debugPrint('[🔄 Update: getStoreVersion] err: $e');
      return '0.0.0';
    }
  }

  /// Determines the store type from where the app was installed.
  ///
  /// This method checks the platform the app was installed from (e.g. App Store, Google Play)
  /// using the package information.
  ///
  /// Returns the [StoreType] of the store, or `null` if it can't be determined.
  Future<StoreType?> getStoreType() async {
    try {
      // Fetch the package info and determine the installer store
      final installedFrom = (await PackageInfo.fromPlatform()).installerStore;

      StoreType? type;
      for (final s in StoreType.values) {
        if (s.package == installedFrom) return s;
      }
      return type;
    } on Exception catch (e) {
      debugPrint('[🔄 Update: getStoreType] err: $e');
      return null;
    }
  }

  /// Returns the data source for a given store type.
  ///
  /// Depending on the [StoreType], this method returns an instance of the corresponding
  /// data source (e.g. App Store, Google Play).
  ///
  /// [type] - The type of the store (e.g., App Store, Google Play, etc.).
  ///
  /// Returns an instance of [IStoreDataSource], or `null` if no data source is available.
  Future<IStoreDataSource?> _getStoreDataSource(StoreType type) async {
    try {
      switch (type) {
        case StoreType.APP_STORE:
          if (_iosAppStoreId == null) return null;
          return AppStoreDataSource(
            appId: _iosAppStoreId.toString(),
            country: _iosAppStoreCountry ?? 'US',
          );
        case StoreType.RU_STORE:
          if (_androidRuStorePackage == null) return null;
          return RuStoreDataSource(packageName: _androidRuStorePackage!);
        case StoreType.APP_GALLERY:
          if (_androidAppGalleryId == null ||
              _androidAppGalleryPackageName == null) {
            return null;
          }
          return HuaweiDataSource(
            appId: _androidAppGalleryId!,
            packageName: _androidAppGalleryPackageName!,
          );
        case StoreType.GOOGLE_PLAY:
          return GooglePlayDataSource();
        default:
          return null;
      }
    } on Exception catch (e) {
      debugPrint('[🔄 Update: _getStoreDataSource] err: $e');
      return null;
    }
  }

  /// Internal method to check if an update is available in the store.
  ///
  /// This method interacts with the store's data source to check for an update.
  ///
  /// [store] - The store data source to check for an update.
  /// [storeVersion] - Optional, the version to compare against the store version.
  ///
  /// Returns `true` if an update is needed, otherwise `false`.
  Future<bool> _checkUpdateStore(
    IStoreDataSource store, {
    String? storeVersion,
  }) async {
    try {
      return await store.needUpdate(storeVersion: storeVersion);
    } on Exception catch (e) {
      debugPrint('[🔄 Update: _checkUpdateStore] err: $e');
      return false;
    }
  }

  /// Internal method to get the version of the app from the store.
  ///
  /// [store] - The store data source.
  ///
  /// Returns the store version as a string.
  Future<String> _getStoreVersion(IStoreDataSource store) async {
    try {
      return await store.getStoreVersion();
    } on Exception catch (e) {
      debugPrint('[🔄 Update: _getStoreVersion] err: $e');
      return '0.0.0';
    }
  }
}
