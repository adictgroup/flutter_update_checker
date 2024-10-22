/// Utility class for handling version comparison and update-related logic.
class UtilsUpdate {
  /// Compares the version from the store with the current installed version.
  ///
  /// [storeVersion] - The version of the app available in the store.
  /// [currentVersion] - The version of the app installed on the device.
  ///
  /// Returns `true` if the store version is newer than the current version, otherwise `false`.
  static bool isNew(String storeVersion, String currentVersion) {
    try {
      final regx = RegExp('[^0-9.]');
      // Split the version strings by dots, removing any non-numeric characters.
      final storeV = storeVersion.replaceAll(regx, '').split('.');
      final currentV = currentVersion.replaceAll(regx, '').split('.');

      // Determine the maximum length of the version segments to compare.
      final maxLength =
          [storeV.length, currentV.length].reduce((a, b) => a > b ? a : b);

      // Compare the versions, treating missing segments as '0'.
      for (var i = 0; i < maxLength; i++) {
        final storeNum = i < storeV.length ? int.parse(storeV[i]) : 0;
        final currentNum = i < currentV.length ? int.parse(currentV[i]) : 0;

        // If the versions differ, return true if the store version is newer.
        if (storeNum != currentNum) {
          return storeNum > currentNum;
        }
      }
      // If all parts are the same, return false (versions are equal).
      return false;
    } catch (e) {
      // Return false if any exception occurs during the comparison.
      return false;
    }
  }
}
