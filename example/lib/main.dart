import 'package:flutter/material.dart';
import 'package:flutter_update_checker/flutter_update_checker.dart';

void main() => runApp(const MainApp());

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final Map<StoreType, String> updateInfo = {};

  @override
  void initState() {
    super.initState();
    checkUpdate();
  }

  Future<void> checkUpdate() async {
    final checker = UpdateStoreChecker(
      iosAppStoreId: 564177498,
      // CORS Block App Gallery in Browser
      // Use VS Code Launch Config
      androidAppGalleryId: 'C101104117',
      androidAppGalleryPackageName: 'com.vkontakte.android',
      androidRuStorePackage: 'com.vkontakte.android',
      androidGooglePlayPackage: 'com.vkontakte.android',
    );
    final updateSource = await checker.getStoreType();

    updateInfo.addEntries(StoreType.values
        // Show GP only if downloaded from GP, Don't show TF
        .where((e) =>
            e != StoreType.TEST_FLIGHT &&
            e != StoreType.iOS_SIMULATOR &&
            (updateSource == StoreType.GOOGLE_PLAY ||
                e != StoreType.GOOGLE_PLAY))
        .map((s) => MapEntry(s, 'loading...')));

    setState(() {});

    for (final MapEntry(:key) in updateInfo.entries) {
      final version = await checker.getStoreVersion(store: key);
      updateInfo[key] = version;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: updateInfo.isEmpty
              ? const CircularProgressIndicator.adaptive()
              : ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (c, i) => const SizedBox(height: 8),
                    itemCount: updateInfo.entries.length,
                    itemBuilder: (c, i) {
                      final item = updateInfo.entries.toList()[i];
                      return Row(
                        children: [
                          Text(item.key.title),
                          const Spacer(),
                          Text(item.value.toString()),
                        ],
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
