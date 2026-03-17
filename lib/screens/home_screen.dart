import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/scheduled_class.dart';
import '../theme/app_theme.dart';
import '../services/platform_service.dart';
import '../services/storage_service.dart';
import '../widgets/proxyai_logo.dart';
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
    if (state == AppLifecycleState.resumed) _checkPermissions();
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
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Accessibility Service', style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary)),
        content: Text(
          'ProxyAI needs Accessibility Service to automatically join your Teams classes. Enable ProxyAI in Accessibility settings.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Later', style: GoogleFonts.inter(color: AppColors.textSecondary))),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAccessibilitySettings();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: AppColors.background),
            child: Text('Enable Now', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600)),
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
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Battery Optimization', style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary)),
        content: Text(
          'Disable battery optimization for ProxyAI so the background service can run and open Teams before your classes.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Later', style: GoogleFonts.inter(color: AppColors.textSecondary))),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              openBatteryOptimizationSettings();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: AppColors.background),
            child: Text('Disable optimization', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600)),
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
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AddClassScreen(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    );
    _load();
  }

  Future<void> _openEdit(ScheduledClass c) async {
    await Navigator.of(context).push<void>(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => AddClassScreen(edit: c),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    );
    _load();
  }

  static const List<String> _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String _formatDays(List<int> days) {
    if (days.isEmpty) return '—';
    return days.map((d) => _dayNames[d - 1]).join(', ');
  }

  String _formatTime(int h, int m) {
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    final period = h >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
  }

  bool get _isActive => _classes.any((c) => c.enabled);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                      child: Row(
                        children: [
                          const ProxyAILogo(size: 40, showGlow: true),
                          const SizedBox(width: 12),
                          Text('ProxyAI', style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: _isActive ? AppColors.accent.withOpacity(0.12) : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isActive ? AppColors.accent.withOpacity(0.4) : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isActive ? AppColors.accent : AppColors.textMuted,
                                boxShadow: _isActive
                                    ? [BoxShadow(color: AppColors.accent.withOpacity(0.6), blurRadius: 6, spreadRadius: 0)]
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _isActive ? 'ProxyAI is active' : 'ProxyAI is sleeping',
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: _isActive ? AppColors.accent : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  if (_classes.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.schedule_rounded, size: 64, color: AppColors.textMuted.withOpacity(0.5)),
                              const SizedBox(height: 24),
                              Text(
                                'No classes yet',
                                style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add a class to have ProxyAI join your Teams meeting automatically.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
                              ),
                              const SizedBox(height: 32),
                              FilledButton.icon(
                                onPressed: _openAdd,
                                icon: const Icon(Icons.add_rounded, size: 22),
                                label: const Text('Add class'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: AppColors.background,
                                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final c = _classes[i];
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: Duration(milliseconds: 300 + (i * 80)),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(opacity: value, child: child),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ClassCard(
                                  classItem: c,
                                  formatDays: _formatDays,
                                  formatTime: _formatTime,
                                  onToggle: () => _toggleEnabled(c),
                                  onEdit: () => _openEdit(c),
                                  onDelete: () => _delete(c),
                                ),
                              ),
                            );
                          },
                          childCount: _classes.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: _classes.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(bottom: 24, right: 8),
              child: FloatingActionButton.extended(
                onPressed: _openAdd,
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.background,
                icon: const Icon(Icons.add_rounded),
                label: Text('Add class', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600)),
              ),
            )
          : null,
    );
  }
}

class _ClassCard extends StatelessWidget {
  final ScheduledClass classItem;
  final String Function(List<int>) formatDays;
  final String Function(int, int) formatTime;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ClassCard({
    required this.classItem,
    required this.formatDays,
    required this.formatTime,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = classItem;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceElevated, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.className,
                      style: GoogleFonts.spaceGrotesk(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c.teamName,
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Text(formatDays(c.daysOfWeek), style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Text(formatTime(c.hour, c.minute), style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: c.enabled,
                onChanged: (_) => onToggle(),
                activeTrackColor: AppColors.accent.withOpacity(0.5),
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return AppColors.accent;
                  return AppColors.textMuted;
                }),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                color: AppColors.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Text('Edit', style: GoogleFonts.inter(color: AppColors.textPrimary))),
                  PopupMenuItem(value: 'delete', child: Text('Delete', style: GoogleFonts.inter(color: AppColors.error))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
