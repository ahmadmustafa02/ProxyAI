import 'package:flutter/material.dart';

import '../models/scheduled_class.dart';
import '../services/storage_service.dart';

class AddClassScreen extends StatefulWidget {
  final ScheduledClass? edit;

  const AddClassScreen({super.key, this.edit});

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final _nameController = TextEditingController();
  final _teamController = TextEditingController();
  final Set<int> _days = {};
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);

  static const List<String> _dayNames = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.edit != null) {
      _nameController.text = widget.edit!.className;
      _teamController.text = widget.edit!.teamName;
      _days.addAll(widget.edit!.daysOfWeek);
      _time = TimeOfDay(hour: widget.edit!.hour, minute: widget.edit!.minute);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teamController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (t != null) setState(() => _time = t);
  }

  void _toggleDay(int day) {
    setState(() {
      if (_days.contains(day)) {
        _days.remove(day);
      } else {
        _days.add(day);
      }
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final team = _teamController.text.trim();
    if (name.isEmpty || team.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class name and Team name are required')),
      );
      return;
    }
    if (_days.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one day')),
      );
      return;
    }

    final list = await loadSchedule();
    final id = widget.edit?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final updated = ScheduledClass(
      id: id,
      className: name,
      teamName: team,
      daysOfWeek: _days.toList()..sort(),
      hour: _time.hour,
      minute: _time.minute,
      enabled: widget.edit?.enabled ?? true,
    );

    final i = list.indexWhere((e) => e.id == id);
    if (i >= 0) {
      list[i] = updated;
    } else {
      list.add(updated);
    }
    await saveSchedule(list);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.edit != null ? 'Edit class' : 'Add class'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Class name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _teamController,
              decoration: const InputDecoration(
                labelText: 'Team name (exact as in Teams)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Day of week', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(7, (i) {
                final day = i + 1;
                return FilterChip(
                  label: Text(_dayNames[i]),
                  selected: _days.contains(day),
                  onSelected: (_) => _toggleDay(day),
                );
              }),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Class time'),
              subtitle: Text(
                '${_time.hourOfPeriod == 0 ? 12 : _time.hourOfPeriod}:${_time.minute.toString().padLeft(2, '0')} ${_time.period == DayPeriod.am ? 'AM' : 'PM'}',
              ),
              trailing: const Icon(Icons.access_time),
              onTap: _pickTime,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Text(widget.edit != null ? 'Save' : 'Add class'),
            ),
          ],
        ),
      ),
    );
  }
}
