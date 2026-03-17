import 'package:flutter/material.dart';

import '../models/scheduled_class.dart';
import '../services/platform_service.dart';
import '../services/storage_service.dart';
import 'add_class_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<ScheduledClass> _classes = [];
  bool _loading = true;
  bool _hasShownBatteryDialogThisSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPermissions());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    if (!mounted) return;
    final a11yEnabled = await isAccessibilityServiceEnabled();
    if (!a11yEnabled) {
      if (!mounted) return;
      await _showAccessibilityDialog();
      return;
    }
    if (_hasShownBatteryDialogThisSession) return;
    final batteryOk = await isIgnoringBatteryOptimizations();
    if (!batteryOk && mounted) {
      _hasShownBatteryDialogThisSession = true;
      await _showBatteryOptimizationDialog();
    }
  }

  Future<void> _showAccessibilityDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Accessibility Service'),
        content: const Text(
          'ProxyAI needs Accessibility Service to automatically join your Teams classes. '
          'Please enable ProxyAI in Accessibility settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAccessibilitySettings();
            },
            child: const Text('Enable Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _showBatteryOptimizationDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Battery Optimization'),
        content: const Text(
          'Disable battery optimization for ProxyAI so the background service can run properly '
          'and open Teams before your classes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              openBatteryOptimizationSettings();
            },
            child: const Text('Disable optimization'),
          ),
        ],
      ),
    );
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await loadSchedule();
    if (mounted) setState(() {
      _classes = list;
      _loading = false;
    });
  }

  Future<void> _toggleEnabled(ScheduledClass c) async {
    final updated = c.copyWith(enabled: !c.enabled);
    final list = List<ScheduledClass>.from(_classes);
    final i = list.indexWhere((e) => e.id == c.id);
    if (i >= 0) {
      list[i] = updated;
      await saveSchedule(list);
      if (mounted) setState(() => _classes = list);
    }
  }

  Future<void> _delete(ScheduledClass c) async {
    final list = _classes.where((e) => e.id != c.id).toList();
    await saveSchedule(list);
    if (mounted) setState(() => _classes = list);
  }

  Future<void> _openAdd() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const AddClassScreen()),
    );
    _load();
  }

  Future<void> _openEdit(ScheduledClass c) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => AddClassScreen(edit: c),
      ),
    );
    _load();
  }

  static const List<String> _dayNames = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  String _formatDays(List<int> days) {
    if (days.isEmpty) return '—';
    return days.map((d) => _dayNames[d - 1]).join(', ');
  }

  String _formatTime(int h, int m) {
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    final period = h >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ProxyAI'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _classes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No classes yet. Add one to get started.'),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _openAdd,
                        icon: const Icon(Icons.add),
                        label: const Text('Add class'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _classes.length,
                    itemBuilder: (context, i) {
                      final c = _classes[i];
                      return ListTile(
                        title: Text(c.className),
                        subtitle: Text(
                          '${c.teamName}\n${_formatDays(c.daysOfWeek)} · ${_formatTime(c.hour, c.minute)}',
                          maxLines: 2,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: c.enabled,
                              onChanged: (_) => _toggleEnabled(c),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (v) {
                                if (v == 'edit') _openEdit(c);
                                if (v == 'delete') _delete(c);
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}
