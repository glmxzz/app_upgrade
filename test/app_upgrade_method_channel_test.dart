import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:update_app/app_upgrade_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelAppUpgrade platform = MethodChannelAppUpgrade();
  const MethodChannel channel = MethodChannel('app_upgrade');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
}
