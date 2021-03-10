// FILE TO REMOVE
import 'dart:core' hide print;

import 'package:tekartik_platform/context.dart';

Function print;

void run(PlatformContext context) {
  if (context.io != null) {
    final io = context.io;
    if (io.isAndroid) {
      print('We are on Android');
    }
  }
  if (context.platform != null) {
    final platform = context.platform;
    if (platform.isWindows) {
      print('We are on Windows');
    } else if (platform.isMacOS) {
      print('We are on Mac');
    } else if (platform.isLinux) {
      print('We are on Linux');
    }
    print('environment: ${platform.environment}');
  }
  if (context.browser != null) {
    if (context.browser.isChrome) {
      print('We are on Chrome');
    } else if (context.browser.isSafari) {
      print('We are on Safari');
    } else if (context.browser.isFirefox) {
      print('We are on Firefox');
    } else if (context.browser.isIe) {
      print('We are on IE/Edga');
    }

    print('version ${context.browser.version}');

    final os = context.browser.os;
    if (os.isWindows) {
      print('We are on Windows');
    }
    if (os.isMac) {
      print('We are on Mac');
    }
    if (os.isLinux) {
      print('We are on Linux');
    }

    if (os.isIOS) {
      print('We are on IOS');
    }
    if (os.isAndroid) {
      print('We are on Android');
    }
    if (context.browser.isMobile) {
      print('We are on Mobile');
    }
    if (context.browser.device.isIPod) {
      print('We are on Ipod device');
    }
    if (context.browser.device.isIPad) {
      print('We are on Ipad device');
    }
    if (context.browser.device.isIPhone) {
      print('We are on Iphone device');
    }
    if (context.browser.device.supportsTouch) {
      print('Touch supported');
    }

    if (context.browser.isDartVm) {
      print('We are running on a browser Dart VM');
    } else {
      print('We are running on a browser with a Javascript VM');
    }
  }
}
