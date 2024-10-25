import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../store_urls.dart';
import '../utils/utils_update.dart';
import 'i_store_datasource.dart';

class HuaweiDataSource extends IStoreDataSource {
  final String appId;
  final String packageName;

  HuaweiDataSource({required this.appId, required this.packageName});

  final Map<String, dynamic> _headers = {
    'Content-Type': 'text/plain',
    'User-Agent':
        'UpdateSDK##4.0.1.300##Android##Pixel 2##com.huawei.appmarket##12.0.1.301'
  };

  // Hardcode, yeah
  String _buildData() {
    final params = <String, dynamic>{
      'agVersion': '12.0.1',
      'brand': 'Android',
      'buildNumber': 'QQ2A.200405.005.2020.04.07.17',
      'density': '420',
      'deviceSpecParams': jsonEncode({
        'abis': 'arm64-v8a,armeabi-v7a,armeabi',
        'deviceFeatures':
            'U,P,B,0c,e,0J,p,a,b,04,m,android.hardware.wifi.rtt,com.google.hardware.camera.easel,com.google.android.feature.PIXEL_2017_EXPERIENCE,08,03,C,S,0G,q,L,2,6,Y,Z,0M,android.hardware.vr.high_performance,f,1,07,8,9,android.hardware.sensor.hifi_sensors,O,H,com.google.android.feature.TURBO_PRELOAD,android.hardware.vr.headtracking,W,x,G,o,06,0N,com.google.android.feature.PIXEL_EXPERIENCE,3,R,d,Q,n,android.hardware.telephony.carrierlock,y,T,i,r,u,com.google.android.feature.WELLBEING,l,4,0Q,N,M,01,09,V,7,5,0H,g,s,c,0l,t,0L,0W,0X,k,00,com.google.android.feature.GOOGLE_EXPERIENCE,android.hardware.sensor.assist,android.hardware.audio.pro,K,E,02,I,J,j,D,h,android.hardware.wifi.aware,05,X,v',
        'dpi': '420',
        'preferLan': 'en'
      }),
      'emuiApiLevel': '0',
      'firmwareVersion': '10',
      'getSafeGame': '1',
      'gmsSupport': '0',
      'hardwareType': '0',
      'harmonyApiLevel': '0',
      'harmonyDeviceType': '',
      'installCheck': '0',
      'isFullUpgrade': '0',
      'isUpdateSdk': '1',
      'locale': 'en_US',
      'magicApiLevel': '0',
      'magicVer': '',
      'manufacturer': 'Google',
      'mapleVer': '0',
      'method': 'client.updateCheck',
      'odm': '0',
      'packageName': 'com.huawei.appmarket',
      'phoneType': 'Pixel 2',
      'pkgInfo': jsonEncode({
        'params': [
          {
            'isPre': '0',
            'maple': '0',
            'oldVersion': '1.0',
            'package': packageName,
            'pkgMode': '0',
            'shellApkVer': '0',
            'targetSdkVersion': '19',
            'versionCode': '1'
          }
        ]
      }),
      'resolution': '1080_1794',
      'sdkVersion': '4.0.1.300',
      'serviceCountry': 'IE',
      'serviceType': '0',
      'supportMaple': '0',
      'ts': (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      'ver': '1.2',
      'version': '12.0.1.301',
      'versionCode': '120001301'
    };

    final dataq = Uri(queryParameters: params).query;

    return dataq;
  }

  @override
  Future<String> getStoreVersion() async {
    try {
      const url =
          'https://store-dre.hispace.dbankcloud.com/hwmarket/api/clientApi';
      final response = await Dio()
          .request(
            url,
            options: Options(
              method: 'POST',
              headers: _headers,
            ),
            data: _buildData(),
          )
          .timeout(
            const Duration(seconds: 10),
          );
      if (response.data.isEmpty) return '0.0.0';

      final decodedResults = response.data;
      if (decodedResults is Map) {
        if (!decodedResults.containsKey('list')) return '0.0.0';
        final list = decodedResults['list'] as List;
        if (list.isEmpty) return '0.0.0';
        final version = decodedResults['list'][0]['version'];
        // debugPrint('[🔄 Update: getLatestVersion] ver: $version');
        return version;
      }
      return '0.0.0';
    } catch (e) {
      debugPrint('[🔄 Update: getLatestVersion] err: ${e.toString()}');
      return '0.0.0';
    }
  }

  @override
  Future<void> update() async {
    try {
      final isSuccess = await launchUrlString(
        StoreUrls.androidAppGalleryUpdateUrl(appId),
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (isSuccess) return;
      await launchUrlString(StoreUrls.androidAppGalleryUpdateUrl(appId));
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
