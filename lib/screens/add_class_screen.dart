import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/scheduled_class.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

class AddClassScreen extends StatefulWidget {
  final ScheduledClass? edit;

  const AddClassScreen({super.key, this.edit});

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _teamController = TextEditingController();
  final Set<int> _days = {};
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  late AnimationController _animController;

  static const List<String> _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _animController.forward();
    if (widget.edit != null) {
      _nameController.text = widget.edit!.className;
      _teamController.text = widget.edit!.teamName;
      _days.addAll(widget.edit!.daysOfWeek);
      _time = TimeOfDay(hour: widget.edit!.hour, minute: widget.edit!.minute);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _teamController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              onPrimary: AppColors.background,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
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
        SnackBar(
          content: Text('Class name and Team name are required', style: GoogleFonts.inter(color: AppColors.textPrimary)),
          backgroundColor: AppColors.surfaceElevated,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_days.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Select at least one day', style: GoogleFonts.inter(color: AppColors.textPrimary)),
          backgroundColor: AppColors.surfaceElevated,
          behavior: SnackBarBehavior.floating,
        ),
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
    return Theme(
      data: Theme.of(context).copyWith(
        timePickerTheme: TimePickerThemeData(
          dayPeriodColor: MaterialStateColor.resolveWith((_) => AppColors.accent),
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            widget.edit != null ? 'Edit class' : 'Add class',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ),
        body: FadeTransition(
          opacity: CurvedAnimation(parent: _animController, curve: Curves.easeOut),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Class name',
                  style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: GoogleFonts.inter(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Calculus 101',
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Team name (exact as in Teams)',
                  style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _teamController,
                  style: GoogleFonts.inter(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Math Department',
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Days',
                  style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(7, (i) {
                    final day = i + 1;
                    final selected = _days.contains(day);
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 200 + (i * 40)),
                      curve: Curves.easeOut,
                      builder: (context, value, child) => Transform.scale(scale: value, child: child),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _toggleDay(day),
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.accent : AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected ? AppColors.accent : AppColors.surfaceElevated,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              _dayNames[i],
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: selected ? AppColors.background : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 28),
                Text(
                  'Class time',
                  style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Material(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: _pickTime,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.schedule_rounded, color: AppColors.accent, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_time.hourOfPeriod == 0 ? 12 : _time.hourOfPeriod}:${_time.minute.toString().padLeft(2, '0')} ${_time.period == DayPeriod.am ? 'AM' : 'PM'}',
                                style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                              Text('Tap to change', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                          const Spacer(),
                          Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    widget.edit != null ? 'Save changes' : 'Add class',
                    style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
