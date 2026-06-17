import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/strategy_badge.dart';
import '../../../core/services/market_data_service.dart';
import '../../auth/controllers/auth_controller.dart';

// ─── Signals Screen ────────────────────────────────────────
class SignalsScreen extends StatefulWidget {
  final int initialTab;
  const SignalsScreen({super.key, this.initialTab = 0});

  @override
  State<SignalsScreen> createState() => _SignalsScreenState();
}

class _SignalsScreenState extends State<SignalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    (
      label: 'Forex',
      cat: 'forex',
      icon: Icons.show_chart_rounded,
      color: Color(0xFF2196F3)
    ),
    (
      label: 'Crypto',
      cat: 'crypto',
      icon: Icons.currency_bitcoin_rounded,
      color: Color(0xFFFFA726)
    ),
    (
      label: 'Metals',
      cat: 'metals',
      icon: Icons.diamond_rounded,
      color: Color(0xFFD4AF37)
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, _tabs.length - 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final email = context.watch<AuthController>().currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          // ── AppBar ────────────────────────────────────────
          AnimatedBuilder(
            animation: _tabController,
            builder: (_, __) {
              final tab = _tabs[_tabController.index];
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  border: Border(
                    bottom: BorderSide(
                      color: tab.color.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 10.h),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                width: 36.r,
                                height: 36.r,
                                decoration: BoxDecoration(
                                  color: tab.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                      color: tab.color.withValues(alpha: 0.3),
                                      width: 1),
                                ),
                                child: Icon(Icons.arrow_back_ios_new_rounded,
                                    color: tab.color, size: 16.r),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              '📡 Live Signals',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tab bar
                      TabBar(
                        controller: _tabController,
                        onTap: (_) => setState(() {}),
                        indicatorColor: tab.color,
                        indicatorWeight: 2.5,
                        labelColor: tab.color,
                        unselectedLabelColor: AppColors.textHint,
                        labelStyle: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3),
                        unselectedLabelStyle: TextStyle(
                            fontSize: 12.sp, fontWeight: FontWeight.w500),
                        tabs: _tabs
                            .map((t) => Tab(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(t.icon, size: 14.r),
                                      SizedBox(width: 5.w),
                                      Text(t.label),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Column headers ────────────────────────────────
          AnimatedBuilder(
            animation: _tabController,
            builder: (_, __) {
              return Container(
                color: AppColors.bgCard.withValues(alpha: 0.5),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text('Pair', style: _hStyle)),
                    Expanded(
                        flex: 4,
                        child: Text('Type / Strategy',
                            textAlign: TextAlign.left, style: _hStyle)),
                    Expanded(
                        flex: 2,
                        child: Text('Entry',
                            textAlign: TextAlign.center, style: _hStyle)),
                    Expanded(
                        flex: 2,
                        child: Text('TP / SL',
                            textAlign: TextAlign.end, style: _hStyle)),
                    Expanded(
                        flex: 3,
                        child: Text('Status',
                            textAlign: TextAlign.end, style: _hStyle)),
                  ],
                ),
              );
            },
          ),

          // ── Tab views ─────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs
                  .map((t) => _SignalTabView(
                        cat: t.cat,
                        color: t.color,
                        adminEmail: email,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  static final _hStyle = TextStyle(
    color: AppColors.textHint,
    fontSize: 10.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
}

// ─── Single tab view ──────────────────────────────────────
class _SignalTabView extends StatefulWidget {
  final String cat;
  final Color color;
  final String adminEmail;
  const _SignalTabView(
      {required this.cat, required this.color, required this.adminEmail});

  @override
  State<_SignalTabView> createState() => _SignalTabViewState();
}

class _SignalTabViewState extends State<_SignalTabView>
    with AutomaticKeepAliveClientMixin {
  bool _isAdmin = false;
  List<SupabaseSignal> _signals = [];
  StreamSubscription<List<SupabaseSignal>>? _sub;
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
    _sub = WhalePriceService.getSignalsStream().listen((all) {
      if (!mounted) return;
      setState(() {
        _signals =
            all.where((s) => s.category.toLowerCase() == widget.cat).toList();
        _isLoading = false;
      });
    }, onError: (_) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  Future<void> _checkAdmin() async {
    if (widget.adminEmail.isEmpty) return;
    try {
      final res = await Supabase.instance.client
          .from('admins')
          .select('email')
          .eq('email', widget.adminEmail)
          .maybeSingle();
      if (mounted && res != null) setState(() => _isAdmin = true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _deleteSignal(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: Text('Delete Signal',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp)),
        content: Text('Are you sure?',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await Supabase.instance.client.from('signals').delete().eq('id', id);
    }
  }

  void _openForm({SupabaseSignal? signal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _SignalFormSheet(existing: signal, presetCategory: widget.cat),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 1.5));
    }

    if (_signals.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.signal_wifi_statusbar_null_rounded,
                color: AppColors.textHint, size: 48.r),
            SizedBox(height: 12.h),
            Text(
              'No active signals',
              style: TextStyle(color: AppColors.textHint, fontSize: 13.sp),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      itemCount: _signals.length,
      separatorBuilder: (_, __) => Divider(
        color: const Color(0xFF1E293B),
        height: 1,
        thickness: 0.5,
      ),
      itemBuilder: (_, i) => _buildRow(_signals[i]),
    );
  }

  Widget _buildRow(SupabaseSignal s) {
    final isBuy = s.type.toUpperCase() == 'BUY';
    final buyColor = const Color(0xFF34D399);
    final sellColor = const Color(0xFFF87171);
    final actionColor = isBuy ? buyColor : sellColor;
    final rowBg = Colors.transparent;

    // Status styling
    final statusData = _statusStyle(s.status);
    final stratInfo = getStrategyInfo(s.strategy);

    return GestureDetector(
      onLongPress: _isAdmin ? () => _openForm(signal: s) : null,
      child: Container(
        decoration: BoxDecoration(
          color: rowBg,
          border: Border(
            left: BorderSide(
                color: actionColor.withValues(alpha: 0.7), width: 2.5),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Row(
          children: [
            // Symbol
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(s.signalTime),
                    style: TextStyle(color: AppColors.textHint, fontSize: 8.sp),
                  ),
                  Text(
                    s.symbol.toUpperCase(),
                    style: TextStyle(
                      color: const Color(0xFFCBD5E1),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            // BUY / SELL / Strategy badges
            Expanded(
              flex: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: actionColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(
                          color: actionColor.withValues(alpha: 0.3),
                          width: 0.7),
                    ),
                    child: Text(
                      s.type.toUpperCase(),
                      style: TextStyle(
                        color: actionColor,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  if (stratInfo != null) ...[
                    SizedBox(width: 16.w),
                    Flexible(
                      child: StrategyBadge(info: stratInfo),
                    ),
                  ],
                ],
              ),
            ),
            // Entry + TP/SL
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    s.entryPrice,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: const Color(0xFFCBD5E1),
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            // TP / SL
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (s.targetPrice != null)
                    Text('TP: ${s.targetPrice}',
                        style: TextStyle(
                            color: buyColor.withValues(alpha: 0.85),
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w600)),
                  if (s.stopLoss != null)
                    Text('SL: ${s.stopLoss}',
                        style: TextStyle(
                            color: sellColor.withValues(alpha: 0.85),
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            // Status badge
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.5.h),
                  decoration: BoxDecoration(
                    color: statusData.bg,
                    borderRadius: BorderRadius.circular(5.r),
                    border: Border.all(color: statusData.border, width: 0.7),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusData.icon, color: statusData.fg, size: 8.r),
                      SizedBox(width: 3.w),
                      Text(
                        statusData.label,
                        style: TextStyle(
                          color: statusData.fg,
                          fontSize: 7.5.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Admin actions
            if (_isAdmin) ...[
              SizedBox(width: 6.w),
              GestureDetector(
                onTap: () => _openForm(signal: s),
                child: Padding(
                  padding: EdgeInsets.all(4.r),
                  child: Icon(Icons.edit_rounded,
                      color: const Color(0xFF64748B), size: 13.r),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => _deleteSignal(s.id),
                child: Padding(
                  padding: EdgeInsets.all(4.r),
                  child: Icon(Icons.delete_outline_rounded,
                      color: const Color(0xFFF87171).withValues(alpha: 0.6),
                      size: 13.r),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  ({Color fg, Color bg, Color border, IconData icon, String label})
      _statusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'win':
        return (
          fg: const Color(0xFF34D399),
          bg: const Color(0xFF022C22),
          border: const Color(0xFF34D399),
          icon: Icons.check_circle_rounded,
          label: 'WIN',
        );
      case 'loss':
        return (
          fg: const Color(0xFFF87171),
          bg: const Color(0xFF2D0A0A),
          border: const Color(0xFFF87171),
          icon: Icons.cancel_rounded,
          label: 'LOSS',
        );
      default:
        return (
          fg: const Color(0xFF94A3B8),
          bg: const Color(0xFF1E293B),
          border: const Color(0xFF334155),
          icon: Icons.schedule_rounded,
          label: 'PENDING',
        );
    }
  }
}

// ─── Signal Add / Edit Bottom Sheet ──────────────────────
class _SignalFormSheet extends StatefulWidget {
  final SupabaseSignal? existing;
  final String? presetCategory;
  const _SignalFormSheet({this.existing, this.presetCategory});

  @override
  State<_SignalFormSheet> createState() => _SignalFormSheetState();
}

class _SignalFormSheetState extends State<_SignalFormSheet> {
  late TextEditingController _symbolCtrl;
  late TextEditingController _entryCtrl;
  late TextEditingController _tpCtrl;
  late TextEditingController _slCtrl;
  late String _category;
  late String _type;
  late String _status;
  String? _strategy;
  late DateTime _signalTime;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _category = s?.category ?? widget.presetCategory ?? 'crypto';
    _type = s?.type.toUpperCase() ?? 'BUY';
    _status = s?.status ?? 'pending';
    _symbolCtrl = TextEditingController(text: s?.symbol ?? '');
    _entryCtrl = TextEditingController(text: s?.entryPrice ?? '');
    _tpCtrl = TextEditingController(text: s?.targetPrice ?? '');
    _slCtrl = TextEditingController(text: s?.stopLoss ?? '');
    _strategy = s?.strategy;
    _signalTime = s?.signalTime ?? DateTime.now();
  }

  @override
  void dispose() {
    _symbolCtrl.dispose();
    _entryCtrl.dispose();
    _tpCtrl.dispose();
    _slCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _signalTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.bgCard,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.bgDark,
          ),
          child: child!,
        );
      },
    );
    if (pickedDate == null) return;

    if (!mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_signalTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.bgCard,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.bgDark,
          ),
          child: child!,
        );
      },
    );
    if (pickedTime == null) return;

    setState(() {
      _signalTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _save() async {
    if (_symbolCtrl.text.isEmpty || _entryCtrl.text.isEmpty) return;
    setState(() => _saving = true);
    try {
      final data = {
        'category': _category,
        'symbol': _symbolCtrl.text.trim().toUpperCase(),
        'type': _type,
        'entry_price': _entryCtrl.text.trim(),
        'target_price':
            _tpCtrl.text.trim().isEmpty ? null : _tpCtrl.text.trim(),
        'stop_loss': _slCtrl.text.trim().isEmpty ? null : _slCtrl.text.trim(),
        'status': _status,
        'signal_time': _signalTime.toUtc().toIso8601String(),
        'strategy': _strategy,
      };
      final supabase = Supabase.instance.client;
      if (widget.existing != null) {
        await supabase
            .from('signals')
            .update(data)
            .eq('id', widget.existing!.id);
      } else {
        await supabase.from('signals').insert(data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error saving signal: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textHint, fontSize: 11.sp),
        filled: true,
        fillColor: AppColors.bgDark,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: AppColors.borderSubtle)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: AppColors.borderSubtle)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      );

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                isEdit ? 'Edit Signal' : 'Add Signal',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 14.h),

              // Category & Type
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category',
                            style: TextStyle(
                                color: AppColors.textHint, fontSize: 10.sp)),
                        SizedBox(height: 4.h),
                        DropdownButtonFormField<String>(
                          value: _category,
                          decoration: _inputDeco(''),
                          dropdownColor: AppColors.bgCard,
                          style: TextStyle(
                              color: AppColors.textPrimary, fontSize: 11.sp),
                          items: const [
                            DropdownMenuItem(
                                value: 'crypto', child: Text('Crypto')),
                            DropdownMenuItem(
                                value: 'forex', child: Text('Forex')),
                            DropdownMenuItem(
                                value: 'metals', child: Text('Metals')),
                          ],
                          onChanged: (v) => setState(() => _category = v!),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Type',
                            style: TextStyle(
                                color: AppColors.textHint, fontSize: 10.sp)),
                        SizedBox(height: 4.h),
                        DropdownButtonFormField<String>(
                          value: _type,
                          decoration: _inputDeco(''),
                          dropdownColor: AppColors.bgCard,
                          style: TextStyle(
                              color: AppColors.textPrimary, fontSize: 11.sp),
                          items: const [
                            DropdownMenuItem(value: 'BUY', child: Text('BUY')),
                            DropdownMenuItem(
                                value: 'SELL', child: Text('SELL')),
                          ],
                          onChanged: (v) => setState(() => _type = v!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              // Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status',
                      style: TextStyle(
                          color: AppColors.textHint, fontSize: 10.sp)),
                  SizedBox(height: 4.h),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: _inputDeco(''),
                    dropdownColor: AppColors.bgCard,
                    style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 11.sp),
                    items: const [
                      DropdownMenuItem(
                          value: 'pending', child: Text('⏳ Pending')),
                      DropdownMenuItem(value: 'win', child: Text('✅ Win')),
                      DropdownMenuItem(value: 'loss', child: Text('❌ Loss')),
                    ],
                    onChanged: (v) => setState(() => _status = v!),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              // Strategy / Tag
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Strategy / Tag (Optional)',
                      style: TextStyle(
                          color: AppColors.textHint, fontSize: 10.sp)),
                  SizedBox(height: 4.h),
                  DropdownButtonFormField<String?>(
                    value: _strategy,
                    decoration: _inputDeco(''),
                    dropdownColor: AppColors.bgCard,
                    style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 11.sp),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('None')),
                      DropdownMenuItem(
                          value: 'pump_coming', child: Text('🔥 Pump')),
                      DropdownMenuItem(value: 'news', child: Text('📰 News')),
                      DropdownMenuItem(
                          value: 'gann_pattern',
                          child: Text('📐 Gann Pattern')),
                      DropdownMenuItem(
                          value: 'price_action',
                          child: Text('📊 Price Action')),
                    ],
                    onChanged: (v) => setState(() => _strategy = v),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              // Symbol
              TextField(
                controller: _symbolCtrl,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 12.sp),
                decoration: _inputDeco('Symbol (e.g. BTC/USDT)'),
                textCapitalization: TextCapitalization.characters,
              ),
              SizedBox(height: 10.h),

              // Entry
              TextField(
                controller: _entryCtrl,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 12.sp),
                decoration: _inputDeco('Entry Price'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 10.h),

              // TP & SL
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tpCtrl,
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 12.sp),
                      decoration: _inputDeco('Take Profit (opt.)'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: TextField(
                      controller: _slCtrl,
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 12.sp),
                      decoration: _inputDeco('Stop Loss (opt.)'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              // Signal Time
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Signal Date & Time',
                      style: TextStyle(
                          color: AppColors.textHint, fontSize: 10.sp)),
                  SizedBox(height: 4.h),
                  InkWell(
                    onTap: _selectDateTime,
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: AppColors.bgDark,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_signalTime.day.toString().padLeft(2, '0')}/${_signalTime.month.toString().padLeft(2, '0')}/${_signalTime.year} '
                            '${_signalTime.hour.toString().padLeft(2, '0')}:${_signalTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                                color: AppColors.textPrimary, fontSize: 11.sp),
                          ),
                          Icon(Icons.calendar_today_rounded,
                              color: AppColors.primary, size: 14.r),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              // Save
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(isEdit ? 'Save Changes' : 'Add Signal',
                          style: TextStyle(
                              fontSize: 12.sp, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
