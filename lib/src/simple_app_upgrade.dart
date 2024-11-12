import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../app_upgrade.dart';
import 'app_market.dart';
import 'download_status.dart';

///
/// des:app升级提示控件
///
class SimpleAppUpgradeWidget extends StatefulWidget {
  final String title; // 升级标题
  final List<String> contents; // 升级提示内容

  final TextStyle? titleStyle; // 标题样式
  final TextStyle? contentStyle; // 提示内容样式
  final String? cancelText; // 取消控件
  final TextStyle? cancelTextStyle; // 取消控件样式
  final String? okText; // 确认控件
  final TextStyle? okTextStyle; // 确认控件样式
  final List<Color>? okBackgroundColors; // 确认控件背景颜色,2种颜色左到右线性渐变
  final Color? progressColor; // 进度条颜色
  final Color? progressBgColor; // 进度条背景颜色
  final TextStyle? progressTextStyle;
  final double progressHeight;

  final double actionLayoutHeight;

  final double borderRadius; // 圆角半径
  final String? downloadUrl; // app安装包下载url,没有下载跳转到应用宝等渠道更新
  final bool force; // 是否强制升级,设置true没有取消按钮
  final String? iosAppId; // ios app id,用于跳转app store
  final AppMarketInfo? appMarketInfo; //  指定跳转的应用市场，如果不指定将会弹出提示框，让用户选择哪一个应用市场。
  final VoidCallback? onCancel;
  final VoidCallback? onOk;
  final DownloadProgressCallback? downloadProgress;
  final DownloadStatusChangeCallback? downloadStatusChange;
  final bool isDark; // 是否暗色
  final Color? dividerColor; //分割线颜色
  final double dividerWidth;

  const SimpleAppUpgradeWidget({
    super.key,
    required this.title,
    required this.contents,
    this.titleStyle,
    this.contentStyle,
    this.cancelText,
    this.cancelTextStyle,
    this.okText,
    this.okTextStyle,
    this.okBackgroundColors,
    this.progressColor,
    this.progressBgColor,
    this.progressHeight = 20.0,
    this.actionLayoutHeight = 60.0,
    this.progressTextStyle,
    this.borderRadius = 10,
    this.downloadUrl,
    this.force = false,
    this.iosAppId,
    this.appMarketInfo,
    this.onCancel,
    this.onOk,
    this.downloadProgress,
    this.downloadStatusChange,
    this.isDark = false,
    this.dividerColor,
    this.dividerWidth = 1.0,
  });

  @override
  State<StatefulWidget> createState() => _SimpleAppUpgradeWidget();
}

class _SimpleAppUpgradeWidget extends State<SimpleAppUpgradeWidget> {
  static const String _downloadApkName = 'temp.apk';

  /// 下载进度
  double _downloadProgress = 0.0;

  DownloadStatus _downloadStatus = DownloadStatus.none;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _buildInfoWidget(context),
        _downloadProgress > 0
            ? Positioned(
                left: 0, right: 0, bottom: 75, child: _buildDownloadProgress())
            : Container(
                height: 10 + widget.progressHeight,
              )
      ],
    );
  }

  /// 信息展示widget
  Widget _buildInfoWidget(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        //标题
        _buildTitle(),
        //更新信息
        _buildAppInfo(),

        Divider(
          height: 1,
          thickness: widget.dividerWidth,
          color: widget.dividerColor,
        ),

        //操作按钮
        _buildAction()
      ],
    );
  }

  /// 构建标题
  _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      child: Text(
        widget.title,
        style: widget.titleStyle ??
            TextStyle(
              fontSize: 22,
              color: widget.isDark ? Colors.white : null,
            ),
      ),
    );
  }

  /// 构建版本更新信息
  _buildAppInfo() {
    return Container(
        padding: EdgeInsets.only(
            left: 15, right: 15, bottom: (30 + widget.progressHeight)),
        child: ListView(
          shrinkWrap: true, // 使 ListView 自适应高度
          children: widget.contents.map((f) {
            return Text(
              f,
              style: widget.contentStyle ??
                  TextStyle(
                    fontSize: 16,
                    color: widget.isDark ? Colors.white : null,
                  ),
            );
          }).toList(),
        ));
  }

  /// 构建取消或者升级按钮
  _buildAction() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Row(
          children: <Widget>[
            widget.force
                ? Container()
                : Expanded(
                    child: _buildCancelActionButton(),
                  ),
            Container(
              width: widget.dividerWidth,
              height: widget.actionLayoutHeight,
              color: widget.dividerColor,
            ),
            Expanded(
              child: _buildOkActionButton(),
            ),
          ],
        ),
      ],
    );
  }

  /// 取消按钮
  _buildCancelActionButton() {
    return Ink(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(widget.borderRadius))),
      child: InkWell(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(widget.borderRadius)),
          splashColor: widget.isDark ? Colors.black38 : null,
          highlightColor: widget.isDark ? Colors.black.withOpacity(.1) : null,
          child: Container(
            height: widget.actionLayoutHeight,
            alignment: Alignment.center,
            child: Text(widget.cancelText ?? '以后再说',
                style: widget.cancelTextStyle ??
                    TextStyle(
                      fontSize: 18,
                      color: widget.isDark ? Colors.white : null,
                    )),
          ),
          onTap: () {
            widget.onCancel?.call();
            Navigator.of(context).pop();
          }),
    );
  }

  /// 确定按钮
  _buildOkActionButton() {
    var borderRadius =
        BorderRadius.only(bottomRight: Radius.circular(widget.borderRadius));
    if (widget.force) {
      borderRadius = BorderRadius.only(
          bottomRight: Radius.circular(widget.borderRadius),
          bottomLeft: Radius.circular(widget.borderRadius));
    }
    var okBackgroundColors = widget.okBackgroundColors;
    if (widget.okBackgroundColors?.length != 2) {
      okBackgroundColors = [
        Theme.of(context).primaryColor,
        Theme.of(context).primaryColor
      ];
    }
    return Ink(
      decoration: BoxDecoration(
          gradient: widget.isDark
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [okBackgroundColors![0], okBackgroundColors[1]]),
          borderRadius: borderRadius),
      child: InkWell(
        borderRadius: borderRadius,
        splashColor: widget.isDark ? Colors.black38 : null,
        highlightColor: widget.isDark ? Colors.black.withOpacity(.1) : null,
        child: Container(
          height: widget.actionLayoutHeight,
          alignment: Alignment.center,
          child: Text(widget.okText ?? '立即体验',
              style: widget.okTextStyle ??
                  TextStyle(
                    color:
                        widget.isDark ? okBackgroundColors![0] : Colors.white,
                    fontSize: 18,
                  )),
        ),
        onTap: () {
          _clickOk();
        },
      ),
    );
  }

  /// 下载进度widget
  Widget _buildDownloadProgress() {
    return LinearPercentIndicator(
      lineHeight: widget.progressHeight,
      linearStrokeCap: LinearStrokeCap.roundAll,
      barRadius: Radius.circular(widget.borderRadius),
      percent: _downloadProgress,
      center: Text(
        NumberFormat.percentPattern().format(_downloadProgress),
        style: widget.progressTextStyle,
      ),
      backgroundColor: widget.progressBgColor,
      progressColor: widget.progressColor,
    );
  }

  /// 点击确定按钮
  _clickOk() async {
    widget.onOk?.call();
    if (Platform.isIOS) {
      //ios 需要跳转到app store更新，原生实现
      if (widget.iosAppId != null) AppUpgrade.toAppStore(widget.iosAppId!);
      return;
    }
    if (widget.downloadUrl == null || widget.downloadUrl!.isEmpty) {
      //没有下载地址，跳转到第三方渠道更新，原生实现
      AppUpgrade.toMarket(appMarketInfo: widget.appMarketInfo);
      return;
    }
    String path = await AppUpgrade.apkDownloadPath;
    _downloadApk(widget.downloadUrl ?? '', '$path/$_downloadApkName');
  }

  /// 下载apk包
  _downloadApk(String url, String path) async {
    if (_downloadStatus == DownloadStatus.start ||
        _downloadStatus == DownloadStatus.downloading ||
        _downloadStatus == DownloadStatus.done) {
      debugPrint('当前下载状态：$_downloadStatus,不能重复下载。');
      return;
    }

    _updateDownloadStatus(DownloadStatus.start);
    try {
      var dio = Dio();
      await dio.download(url, path, onReceiveProgress: (int count, int total) {
        if (total == -1) {
          _downloadProgress = 0.01;
        } else {
          widget.downloadProgress?.call(count, total);
          _downloadProgress = count / total.toDouble();
        }
        setState(() {});
        if (_downloadProgress == 1) {
          //下载完成，跳转到程序安装界面
          _updateDownloadStatus(DownloadStatus.done);
          Navigator.pop(context);
          debugPrint("下载完成：安装包路径：$path");
          AppUpgrade.installAppForAndroid(path);
        }
      });
    } catch (e) {
      debugPrint('$e');
      _downloadProgress = 0;
      _updateDownloadStatus(DownloadStatus.error, error: e);
    }
  }

  _updateDownloadStatus(DownloadStatus downloadStatus, {dynamic error}) {
    _downloadStatus = downloadStatus;
    widget.downloadStatusChange?.call(_downloadStatus, error: error);
  }
}
