import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/scheduled_class.dart';

const String _scheduleKey = 'proxyai_schedule';
const String _pendingTeamKey = 'proxyai_pending_team';
const String _onboardingDoneKey = 'proxyai_onboarding_done';

Future<bool> isOnboardingDone() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_onboardingDoneKey) ?? false;
}

Future<void> setOnboardingDone() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_onboardingDoneKey, true);
}

Future<List<ScheduledClass>> loadSchedule() async {
  final prefs = await SharedPreferences.getInstance();
  final json = prefs.getString(_scheduleKey);
  if (json == null) return [];
  final list = jsonDecode(json) as List<dynamic>;
  return list
      .map((e) => ScheduledClass.fromJson(e as Map<String, dynamic>))
      .toList();
}

Future<void> saveSchedule(List<ScheduledClass> classes) async {
  final prefs = await SharedPreferences.getInstance();
  final list = classes.map((e) => e.toJson()).toList();
  await prefs.setString(_scheduleKey, jsonEncode(list));
}

Future<void> setPendingTeamName(String? teamName) async {
  final prefs = await SharedPreferences.getInstance();
  if (teamName == null) {
    await prefs.remove(_pendingTeamKey);
  } else {
    await prefs.setString(_pendingTeamKey, teamName);
  }
}

Future<String?> getPendingTeamName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_pendingTeamKey);
}
