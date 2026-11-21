import 'package:flutter/services.dart';

import 'app_settings.dart';

/// Maps the selected color theme to an iOS alternate app icon.
///
/// iOS exposes alternate icons through `setAlternateIconName`; the icon
/// variants are bundled in Runner/Assets.xcassets and declared in Info.plist
/// by the asset-catalog compiler settings.
class AppIconService {
  AppIconService._();

  static const MethodChannel _channel = MethodChannel('heng/app_icon');

  static String? iconNameFor(AppColorTheme theme) => switch (theme) {
        AppColorTheme.fresh => null,
        AppColorTheme.forest => 'AppIconForest',
        AppColorTheme.freshForest => 'AppIconFreshForest',
        AppColorTheme.blush => 'AppIconBlush',
        AppColorTheme.peach => 'AppIconPeach',
        AppColorTheme.lavender => 'AppIconLavender',
      };

  static Future<void> apply(AppColorTheme theme) async {
    try {
      await _channel.invokeMethod<bool>('setAppIcon', {
        'name': iconNameFor(theme),
      });
    } on MissingPluginException {
      // Tests / non-iOS platforms: no alternate icon support.
    } on PlatformException {
      // The system may reject a change while the app is inactive; retry on
      // the next settings change rather than blocking the UI.
    }
  }
}
