<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# flutter_update_checker

[![Pub](https://img.shields.io/pub/v/flutter_update_checker.svg)](https://pub.dev/packages/flutter_update_checker)

Simple package to check update for Android (Google Play, App Gallery, RuStore) and iOS (AppStore)

## Features

1. Getting the version/checking update from the store where the application was downloaded  
1. Getting a version from another store (except Google Play)
1. Opening link to store

## Platform support

| Feature                        | Android           | iOS |
| ------------------------------ | :---------------: | :-: |
| App Store                      | ✅                | ✅  |
| App Gallery                    | ✅                | ✅  |
| Google Play                    | (Only if from GP) |   |
| RuStore                        | ✅                | ✅  |

## Getting started

For iOS you have to add LSApplicationQueriesSchemes as Array param to Info.plist and add itms-apps as one of params in this array to link appstore.

Code:
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>itms-apps</string>
</array>
```

## Usage

Check example
in `/example` folder.

```dart
final updateChecker = UpdateStoreChecker(
      iosAppStoreId: 564177498,
      androidAppGalleryId: 'C101104117',
      androidAppGalleryPackageName: 'com.vkontakte.android',
      androidRuStorePackage: 'com.vkontakte.android',
      androidGooglePlayPackage: 'com.vkontakte.android',
    );

// Check update
bool isUpdateAvailable = await updateChecker.checkUpdate();

// Get version from Store
String storeVersion = await updateChecker.getStoreVersion();

// Open Store Link
await updateChecker.update();
```