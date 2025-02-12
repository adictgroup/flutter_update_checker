/// Static class containing store-related URL utilities.
class StoreUrls {
  static String iosAppStore(String appId, {String country = 'US'}) =>
      'https://itunes.apple.com/lookup?id=$appId&country=$country'; // https://23.1.100.27/lookup?id=$appId&country=$country'; // Fix If Itunes Down
  static String iosAppStoreUpdateUrl(String appId) =>
      'itms-apps://itunes.apple.com/app/id$appId';
  static String iosAppStoreUpdateUrlHttp(String appId) =>
      'https://itunes.apple.com/app/id$appId';
  static String androidRuStore(String packageName) =>
      'https://backapi.rustore.ru/applicationData/overallInfo/$packageName';
  static String androidRuStoreUpdateUrl(String packageName) =>
      'https://apps.rustore.ru/app/$packageName';
  static String androidAppGalleryUpdateUrl(String appId) =>
      'https://appgallery.huawei.com/app/$appId';
}
