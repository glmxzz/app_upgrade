import 'dart:io';

import 'package:app_upgrade/app_upgrade.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: const Home(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const apkUrl =
      'https://d-02.winudf.com/custom/com.apkpure.aegon-3201137.apk?_fn=QVBLUHVyZV92My4yMC4xMTAzX2Fwa3B1cmUuY29tLmFwaw&_p=Y29tLmFwa3B1cmUuYWVnb24&am=-gcQ5KVp7I2UCe42mWkqvA&arg=apkpure%3A%2F%2Fcampaign%2F%3Freport_context%3D%7B%22channel_id%22%3A2010%7D&at=1731292492&download_id=1523808321705386&k=c109515f0c89c820263cd6c9cf7f34fb6732bed0&r=https%3A%2F%2Fwww.google.com.hk%2F&uu=http%3A%2F%2F172.16.53.1%2Fcustom%2Fcom.apkpure.aegon-3201137.apk%3Fk%3D436249cd58ced144dcffabfa0513284f6732bed01';
  AppInfo? _appInfo;
  String _installMarkets = '';

  @override
  void initState() {
    _getAppInfo();
    super.initState();
    _getInstallMarket();
  }

  Future<AppUpgradeInfo> _checkVersion() async {
    return Future.delayed(const Duration(seconds: 1), () {
      return AppUpgradeInfo(
        title: '新版本V1.1.1',
        apkDownloadUrl: apkUrl,
        contents: [
          '1、支持立体声蓝牙耳机，同时改善配对性能',
          '2、提供屏幕虚拟键盘',
        ],
        force: false,
      );
    });
  }

  _getAppInfo() async {
    var appInfo = await AppUpgrade.appInfo;
    setState(() {
      _appInfo = appInfo;
    });
  }

  _getInstallMarket() async {
    if (Platform.isAndroid) {
      List<String> marketList = await AppUpgrade.getInstallMarket();
      for (var f in marketList) {
        _installMarkets += '$f,';
      }
    }
  }

  _checkAppUpgrade() {
    AppUpgrade.appUpgrade(
      context,
      _checkVersion(),
      backgroundColor: const Color(0xff292929),
      cancelText: '以后再说',
      okText: '马上升级',
      iosAppId: 'id444934666',
      // appMarketInfo: AppMarket.tencent,
      okBackgroundColors: [const Color(0xFF0257F6), const Color(0xFF0257F6)],
      progressColor: const Color(0xff292929).withOpacity(.4),
      progressBgColor: const Color(0xFF5A46BE).withOpacity(.4),
      progressTextStyle: TextStyle(color: Colors.white70),
      progressHeight: 30.0,
      isDark: true,
      onCancel: () {
        debugPrint('onCancel');
      },
      onOk: () {
        debugPrint('onOk');
      },
      downloadProgress: (count, total) {
        // debugPrint('count:$count,total:$total');
      },
      downloadStatusChange: (status, {dynamic error}) {
        debugPrint('status:$status,error:$error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('packageName:${_appInfo?.packageName}'),
        Text('versionName:${_appInfo?.versionName}'),
        Text('versionCode:${_appInfo?.versionCode}'),
        if (Platform.isAndroid) Text('安装的应用商店:$_installMarkets'),
        ElevatedButton(
          onPressed: _checkAppUpgrade,
          child: const Text('显示更新弹窗'),
        ),
        if (Platform.isAndroid)
          MaterialButton(
            onPressed: () {
              AppUpgrade.apkDownloadPath.then((value) {
                debugPrint("apk is $value");
                return AppUpgrade.installAppForAndroid(value);
              });
            },
            child: const Text('直接安装'),
          )
      ],
    );
  }
}
