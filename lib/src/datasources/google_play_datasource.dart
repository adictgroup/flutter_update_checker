import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_update/in_app_update.dart';
import 'i_store_datasource.dart';

class GooglePlayDataSource implements IStoreDataSource {
  @override
  Future<String> getStoreVersion() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      return '${info.availableVersionCode}';
    } on MissingPluginException catch (_) {
      debugPrint('[🔄 Update] Installed not from Google Play');
    } on Exception catch (e) {
      debugPrint('[🔄 Update: getStoreVersion] err: ${e.toString()}');
    }
    return '0.0.0';
  }

  @override
  Future<bool> needUpdate({String? storeVersion}) async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return false;
      }
      if (!info.flexibleUpdateAllowed) return false;
      return info.updateAvailability == UpdateAvailability.updateAvailable;
    } on MissingPluginException catch (_) {
      debugPrint('[🔄 Update] Installed not from Google Play');
      return false;
    } on Exception catch (e) {
      debugPrint('[🔄 Update: needUpdate] err: ${e.toString()}');
      return false;
    }
  }

  @override
  Future<void> update() async {
    try {
      final appUpdateResult = await InAppUpdate.startFlexibleUpdate();
      //Perform flexible update
      if (appUpdateResult == AppUpdateResult.success) {
        //App Update successful
        await InAppUpdate.completeFlexibleUpdate();
      }
    } on MissingPluginException catch (_) {
      debugPrint('[🔄 Update: update] Installed not from Google Play');
    } catch (e) {
      debugPrint('[🔄 Update: update] err: ${e.toString()}');
    }
  }
}
