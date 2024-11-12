import 'package:flutter/material.dart';

import 'app_upgrade_platform_interface.dart';
import 'src/app_market.dart';
import 'src/download_status.dart';
import 'src/simple_app_upgrade.dart';

class AppUpgrade {
  static appUpgrade(BuildContext context,
      Future<AppUpgradeInfo?> future, {
        Color? backgroundColor,
        TextStyle? titleStyle,
        TextStyle? contentStyle,
        String? cancelText,
        TextStyle? cancelTextStyle,
        String? okText,
        TextStyle? okTextStyle,
        List<Color>? okBackgroundColors,
        Color? progressColor,
        Color? progressBgColor,
        double progressHeight = 20.0,
        double actionLayoutHeight = 60.0,
        TextStyle? progressTextStyle,
        double borderRadius = 20.0,
        String? iosAppId,
        AppMarketInfo? appMarketInfo,
        VoidCallback? onCancel,
        VoidCallback? onOk,
        DownloadProgressCallback? downloadProgress,
        DownloadStatusChangeCallback? downloadStatusChange,
        bool isDark = false,
        Color? dividerColor,
        double dividerWidth = 1.0,
      }) {
    future.then((AppUpgradeInfo? appUpgradeInfo) {
      if (appUpgradeInfo != null) {
        _showUpgradeDialog(
            context, appUpgradeInfo.title, appUpgradeInfo.contents,
            apkDownloadUrl: appUpgradeInfo.apkDownloadUrl,
            backgroundColor: backgroundColor,
            force: appUpgradeInfo.force,
            titleStyle: titleStyle,
            contentStyle: contentStyle,
            cancelText: cancelText,
            cancelTextStyle: cancelTextStyle,
            okBackgroundColors: okBackgroundColors,
            okText: okText,
            okTextStyle: okTextStyle,
            borderRadius: borderRadius,
            progressColor: progressColor,
            progressBgColor: progressBgColor,
            progressTextStyle: progressTextStyle,
            progressHeight: progressHeight,
            actionLayoutHeight: actionLayoutHeight,
            iosAppId: iosAppId,
            appMarketInfo: appMarketInfo,
            onCancel: onCancel,
            onOk: onOk,
            downloadProgress: downloadProgress,
            downloadStatusChange: downloadStatusChange,
            isDark: isDark,
            dividerColor: dividerColor,
            dividerWidth: dividerWidth
        );
      }
    }).catchError((onError) {
      debugPrint("显示出错：$onError");
    });
  }

  ///
  /// 展示app升级提示框
  ///
  static _showUpgradeDialog(BuildContext context, String title,
      List<String> contents,
      {Color? backgroundColor,
        String? apkDownloadUrl,
        bool force = false,
        TextStyle? titleStyle,
        TextStyle? contentStyle,
        String? cancelText,
        TextStyle? cancelTextStyle,
        String? okText,
        TextStyle? okTextStyle,
        List<Color>? okBackgroundColors,
        Color? progressColor,
        Color? progressBgColor,
        TextStyle? progressTextStyle,
        double progressHeight = 20.0,
        double actionLayoutHeight = 60.0,
        double borderRadius = 20.0,
        String? iosAppId,
        AppMarketInfo? appMarketInfo,
        VoidCallback? onCancel,
        VoidCallback? onOk,
        DownloadProgressCallback? downloadProgress,
        DownloadStatusChangeCallback? downloadStatusChange,
        bool isDark = false,
        Color? dividerColor,
        double dividerWidth = 1.0}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return PopScope(
            canPop: false,
            child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.all(Radius.circular(borderRadius))),
                backgroundColor: backgroundColor,
                child: SimpleAppUpgradeWidget(
                  title: title,
                  titleStyle: titleStyle,
                  contents: contents,
                  contentStyle: contentStyle,
                  cancelText: cancelText,
                  cancelTextStyle: cancelTextStyle,
                  okText: okText,
                  okTextStyle: okTextStyle,
                  okBackgroundColors: okBackgroundColors ??
                      [
                        Theme
                            .of(context)
                            .primaryColor,
                        Theme
                            .of(context)
                            .primaryColor
                      ],
                  progressColor: progressColor,
                  progressBgColor: progressBgColor,
                  progressHeight: progressHeight,
                  actionLayoutHeight: actionLayoutHeight,
                  progressTextStyle: progressTextStyle,
                  borderRadius: borderRadius,
                  downloadUrl: apkDownloadUrl,
                  force: force,
                  iosAppId: iosAppId,
                  appMarketInfo: appMarketInfo,
                  onCancel: onCancel,
                  onOk: onOk,
                  downloadProgress: downloadProgress,
                  downloadStatusChange: downloadStatusChange,
                  isDark: isDark,
                  dividerColor: dividerColor,
                  dividerWidth: dividerWidth,
                )),
          );
        });
  }

  /// 跳转 App Store
  static Future<void> toAppStore(String appId) async {
    return AppUpgradePlatform.instance.toAppStore(appId);
  }

  /// 跳转应用市场
  static Future<void> toMarket({AppMarketInfo? appMarketInfo}) async {
    return AppUpgradePlatform.instance.toMarket(appMarketInfo: appMarketInfo);
  }

  /// 获取下载好的 apk 完整地址
  static Future<String> get apkDownloadPath async {
    return AppUpgradePlatform.instance.apkDownloadPath;
  }

  /// 安装 apk
  static Future<void> installAppForAndroid(String path) async {
    return AppUpgradePlatform.instance.installAppForAndroid(path);
  }

  /// 获取当前应用的信息
  static Future<AppInfo> get appInfo async {
    return AppUpgradePlatform.instance.appInfo;
  }

  /// 获取本机安装的应用市场
  static Future<List<String>> getInstallMarket(
      {List<String>? marketPackageNames}) async {
    return AppUpgradePlatform.instance
        .getInstallMarket(marketPackageNames: marketPackageNames);
  }
}

class AppInfo {
  AppInfo({
    required this.versionName,
    required this.versionCode,
    required this.packageName,
  });

  String versionName;
  String versionCode;
  String packageName;
}

class AppUpgradeInfo {
  final String title; // title,显示在提示框顶部
  final List<String> contents; // 升级内容
  final String? apkDownloadUrl; // apk下载url
  final bool force; // 是否强制升级
  AppUpgradeInfo({
    required this.title,
    required this.contents,
    this.apkDownloadUrl,
    this.force = false,
  });
}

/// 下载进度回调
typedef DownloadProgressCallback = Function(int count, int total);

/// 下载状态变化回调
typedef DownloadStatusChangeCallback = Function(DownloadStatus downloadStatus,
    {dynamic error});
