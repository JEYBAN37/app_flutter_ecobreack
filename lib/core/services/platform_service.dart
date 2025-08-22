import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformService {
  static bool get isDesktop {
    if (kIsWeb) {
      return true; // Consider web as desktop
    }
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  static bool get isMobile {
    if (kIsWeb) {
      return false;
    }
    return Platform.isAndroid || Platform.isIOS;
  }

  static bool get isAdminPlatform {
    return isDesktop; // Only desktop can access admin features
  }
}
