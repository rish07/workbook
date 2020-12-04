import 'dart:io';

class AdManager {
  static String get appId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3040440138829028~8445837828";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3040440138829028~8445837828";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3040440138829028/7680191696";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3040440138829028/7680191696";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "<YOUR_ANDROID_INTERSTITIAL_AD_UNIT_ID>";
    } else if (Platform.isIOS) {
      return "<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "<YOUR_ANDROID_REWARDED_AD_UNIT_ID>";
    } else if (Platform.isIOS) {
      return "<YOUR_IOS_REWARDED_AD_UNIT_ID>";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}
