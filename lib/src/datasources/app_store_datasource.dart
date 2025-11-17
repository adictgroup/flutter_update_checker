import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../store_urls.dart';
import '../utils/utils_update.dart';
import './i_store_datasource.dart';

class AppStoreDataSource extends IStoreDataSource {
  final int? appId;
  final String country;

  AppStoreDataSource({required this.appId, this.country = 'US'});

  @override
  Future<String?> getStoreVersion() async {
    try {
      if (appId == null) return null;

      final url = StoreUrls.iosAppStore(appId!, country: country);
      final response = await Dio()
          .get(
            url,
            options: Options(
              headers: {'Cache-Control': 'no-cache, no-store, must-revalidate', 'Pragma': 'no-cache', 'Expires': '0'},
            ),
          )
          .timeout(const Duration(seconds: 10));
      if (response.data.isEmpty) return null;

      final decodedResults = json.decode(response.data);
      if (decodedResults is! Map) return null;

      return decodedResults['results'][0]['version'];
    } catch (e) {
      debugPrint('[🔄 Update: getStoreVersion] err: $e');
      return null;
    }
  }

  @override
  Future<bool> update() async {
    try {
      if (appId == null) return false;
      final isSuccess = await launchUrlString(
        StoreUrls.iosAppStoreUpdateUrl(appId!),
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (isSuccess) return true;

      return await launchUrlString(StoreUrls.iosAppStoreUpdateUrlHttp(appId!));
    } catch (e) {
      debugPrint('[🔄 Update: update] err: $e');
    }
    return true;
  }

  @override
  Future<bool> needUpdate({String? storeVersion}) async {
    try {
      final version = storeVersion ?? await getStoreVersion();
      if (version == null) return false;

      final appInfo = await PackageInfo.fromPlatform();
      return UtilsUpdate.isNew(version, appInfo.version);
    } on Exception catch (e) {
      debugPrint('[🔄 Update: needUpdate] err: $e');
      return false;
    }
  }
}
