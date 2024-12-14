import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../store_urls.dart';
import '../utils/utils_update.dart';
import './i_store_datasource.dart';

class AppStoreDataSource extends IStoreDataSource {
  final String appId;
  final String country;

  AppStoreDataSource({required this.appId, this.country = 'US'});

  @override
  Future<String> getStoreVersion() async {
    try {
      final url = StoreUrls.iosAppStore(appId, country: country);
      final response = await Dio().get(url).timeout(
            const Duration(seconds: 10),
          );
      if (response.data.isEmpty) return '0.0.0';

      final decodedResults = json.decode(response.data);
      if (decodedResults is! Map) return '0.0.0';

      return decodedResults['results'][0]['version'];
    } catch (e) {
      debugPrint('[🔄 Update: getStoreVersion] err: $e');
      return '0.0.0';
    }
  }

  @override
  Future<void> update() async {
    try {
      final isSuccess = await launchUrlString(
        StoreUrls.iosAppStoreUpdateUrl(appId),
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (isSuccess) return;
      await launchUrlString(StoreUrls.iosAppStoreUpdateUrlHttp(appId));
    } catch (e) {
      debugPrint('[🔄 Update: update] err: $e');
    }
  }

  @override
  Future<bool> needUpdate({String? storeVersion}) async {
    try {
      final version = storeVersion ?? await getStoreVersion();
      final nowVersion = (await PackageInfo.fromPlatform()).version;
      if (!UtilsUpdate.isNew(version, nowVersion) || version == '0.0.0') {
        return false;
      }
      return true;
    } on Exception catch (e) {
      debugPrint('[🔄 Update: needUpdate] err: $e');
      return false;
    }
  }
}
