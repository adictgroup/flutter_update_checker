## 1.1.0

- upd(dart): dart sdk to 3.7.0+
- feat(update): always fetch the latest App Store data without relying on cached responses (Thanks to [@bousalem98](https://github.com/bousalem98))

- **BREAKING CHANGES**
  - `getStoreVersion()` now returns nullable `String?`.  
  Previously it always returned a non-null string, using `'0.0.0'` as a fallback on errors.  
  Now, if the version cannot be retrieved, the method returns `null`.
  - `update()` now returns a result containing a `bool` indicating success.  
  Instead of assuming the update was applied, the method explicitly reports whether the update completed successfully.

## 1.0.0

- upd(dart): dart sdk to 3.6.0
- upd(deps): upd dio to 5.9.0, in_app_update to 4.2.5, package_info_plus to 9.0.0, url_launcher to 6.3.2, flutter_lints to 6.0.0

## 0.1.5

- feat(app-store): set country for app store
- upd(deps): upd dio to 5.8.0+1 and package_info_plus to 8.2.1

## 0.1.4

- feat(update): open app store link in browser if you can't open app

## 0.1.3

- feat(update): open link in browser if you can't open store app

## 0.1.2

- chore(docs): update readme

## 0.1.1

- feat(deps): Relax `collection` deps

## 0.1.0

- Initial Open Source release.
