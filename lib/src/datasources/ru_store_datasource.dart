import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../store_urls.dart';
import '../utils/utils_update.dart';
import './i_store_datasource.dart';

class RuStoreDataSource extends IStoreDataSource {
  final String? packageName;

  RuStoreDataSource({required this.packageName});

  @override
  Future<String?> getStoreVersion() async {
    try {
      if (packageName == null) return null;

      final url = StoreUrls.androidRuStore(packageName!);
      final response = await Dio().get(url).timeout(const Duration(seconds: 10));

      if (response.data.isEmpty) return null;

      final decodedResults = response.data;
      if (decodedResults is! Map) return null;

      return decodedResults['body']['versionName'];
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> update() async {
    try {
      if (packageName == null) return false;

      final isSuccess = await launchUrlString(
        StoreUrls.androidRuStoreUpdateUrl(packageName!),
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (isSuccess) return true;

      return await launchUrlString(StoreUrls.androidRuStoreUpdateUrl(packageName!));
    } catch (e) {
      debugPrint('[🔄 Update: update] err: $e');
    }
    return false;
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
