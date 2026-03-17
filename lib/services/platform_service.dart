import 'package:flutter/services.dart';

const MethodChannel _channel = MethodChannel('com.example.online_class_agent/platform');

Future<void> wakeScreenAndOpenTeams(String teamName) async {
  await _channel.invokeMethod<void>('wakeAndOpenTeams', teamName);
}

Future<void> scheduleAlarmAt(DateTime time) async {
  await _channel.invokeMethod<void>('scheduleAlarmAt', time.millisecondsSinceEpoch);
}

Future<bool> isAccessibilityServiceEnabled() async {
  return (await _channel.invokeMethod<bool>('isAccessibilityServiceEnabled')) ?? false;
}

Future<void> openAccessibilitySettings() async {
  await _channel.invokeMethod<void>('openAccessibilitySettings');
}

Future<bool> isIgnoringBatteryOptimizations() async {
  return (await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations')) ?? true;
}

Future<void> openBatteryOptimizationSettings() async {
  await _channel.invokeMethod<void>('openBatteryOptimizationSettings');
}
