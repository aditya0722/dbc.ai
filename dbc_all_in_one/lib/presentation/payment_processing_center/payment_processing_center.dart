import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Payment Processing Center — Redesigned for compact, elegant UX
/// Design: Dark-accented financial dashboard with teal/emerald palette
/// Key improvements:
///   • Summary row is a single slim horizontal strip (max ~100px tall)
///   • Transaction list dominates the screen as intended
///   • Smoother status chips, better typography hierarchy
///   • Search bar integrated inline, no wasted space
///   • Swipe-to-action on transaction rows
class PaymentProcessingCenter extends StatefulWidget {
  const PaymentProcessingCenter({super.key});

  @override
  State<PaymentProcessingCenter> createState() =>
      _PaymentProcessingCenterState();
}

class _PaymentProcessingCenterState extends State<PaymentProcessingCenter>
    with SingleTickerProviderStateMixin {
  // ── Palette ────────────────────────────────────────────────────────────────
  static const Color _bg = Color(0xFFF6F7FB);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _primary = Color(0xFF5A3BA3); // teal-700
  static const Color _primaryLight = Color(0xFF6B46C1); // teal-500
  static const Color _accent = Color(0xFF6366F1); // indigo-500
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMid = Color(0xFF475569);
  static const Color _textLight = Color(0xFF94A3B8);
  static const Color _border = Color(0xFFE2E8F0);

  static const Color _pendingBg = Color(0xFFFFF7ED);
  static const Color _pendingFg = Color(0xFFB45309);
  static const Color _processingBg = Color(0xFFEFF6FF);
  static const Color _processingFg = Color(0xFF2563EB);
  static const Color _completedBg = Color(0xFFF0FDF4);
  static const Color _completedFg = Color(0xFF16A34A);
  static const Color _failedBg = Color(0xFFFFF1F2);
  static const Color _failedFg = Color(0xFFE11D48);

  // ── State ──────────────────────────────────────────────────────────────────
  String _selectedMethod = 'all';
  String _searchQuery = '';
  bool _isSearchOpen = false;
  List<String> _selectedIds = [];
  bool _isMultiSelect = false;
  late AnimationController _fabAnim;
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  // ── Mock data ──────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'TXN001',
      'amount': 1250.00,
      'recipient': 'Acme Corp',
      'initials': 'AC',
      'method': 'credit_card',
      'status': 'pending',
      'date': 'Dec 13, 10:30 AM',
      'description': 'Monthly subscription',
      'fee': 25.00,
      'eta': '2–3 hours',
      'cardLast4': '4242',
      'badges': ['PCI-DSS', 'SSL', '3D-Secure'],
    },
    {
      'id': 'TXN002',
      'amount': 3500.00,
      'recipient': 'Tech Solutions Inc',
      'initials': 'TS',
      'method': 'bank_transfer',
      'status': 'processing',
      'date': 'Dec 13, 09:15 AM',
      'description': 'Service invoice',
      'fee': 15.00,
      'eta': '1–2 business days',
      'accountNumber': '****5678',
      'badges': ['Bank-Grade', 'Encrypted'],
    },
    {
      'id': 'TXN003',
      'amount': 850.00,
      'recipient': 'Digital Marketing Co',
      'initials': 'DM',
      'method': 'digital_wallet',
      'status': 'completed',
      'date': 'Dec 12, 03:45 PM',
      'description': 'Ad campaign payment',
      'fee': 8.50,
      'eta': 'Instant',
      'walletId': 'wallet@example.com',
      'badges': ['2FA', 'Biometric'],
    },
    {
      'id': 'TXN004',
      'amount': 500.00,
      'recipient': 'Office Supplies Ltd',
      'initials': 'OS',
      'method': 'cash',
      'status': 'pending',
      'date': 'Dec 13, 11:20 AM',
      'description': 'Office equipment',
      'fee': 0.00,
      'eta': 'Immediate',
      'badges': ['Receipt-Verified'],
    },
    {
      'id': 'TXN005',
      'amount': 2200.00,
      'recipient': 'Cloud Services Provider',
      'initials': 'CS',
      'method': 'credit_card',
      'status': 'failed',
      'date': 'Dec 13, 08:00 AM',
      'description': 'Annual hosting fee',
      'fee': 44.00,
      'eta': 'Retry available',
      'cardLast4': '9876',
      'badges': ['PCI-DSS', 'SSL'],
      'failureReason': 'Insufficient funds',
    },
    {
      'id': 'TXN006',
      'amount': 720.00,
      'recipient': 'Creative Studio',
      'initials': 'CR',
      'method': 'bank_transfer',
      'status': 'completed',
      'date': 'Dec 11, 02:00 PM',
      'description': 'Design retainer',
      'fee': 5.00,
      'eta': 'Instant',
      'accountNumber': '****1234',
      'badges': ['Encrypted'],
    },
  ];

  // ── Computed ───────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> get _filtered {
    return _transactions.where((t) {
      final methodOk =
          _selectedMethod == 'all' || t['method'] == _selectedMethod;
      final searchOk = _searchQuery.isEmpty ||
          (t['recipient'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (t['id'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return methodOk && searchOk;
    }).toList();
  }

  double get _completedTotal => _transactions
      .where((t) => t['status'] == 'completed')
      .fold(0.0, (s, t) => s + (t['amount'] as num).toDouble());

  int get _pendingCount =>
      _transactions.where((t) => t['status'] == 'pending').length;
  int get _completedCount =>
      _transactions.where((t) => t['status'] == 'completed').length;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _fabAnim.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSummaryStrip(),
              _buildSearchAndFilters(),
              if (_isMultiSelect && _selectedIds.isNotEmpty) _buildBatchBar(),
              _buildListHeader(),
              Expanded(child: _buildTransactionList()),
            ],
          ),
        ),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: _surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: _textDark),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Processing',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Dec 13, 2025  •  Live',
                  style: TextStyle(
                    fontSize: 12,
                    color: _textLight,
                  ),
                ),
              ],
            ),
          ),
          // Live indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _completedFg.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: _completedFg,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _completedFg,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _showFilterSheet,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tune_rounded, size: 18, color: _textDark),
            ),
          ),
          if (_isMultiSelect) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() {
                _isMultiSelect = false;
                _selectedIds.clear();
              }),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _failedBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.close_rounded, size: 18, color: _failedFg),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Summary Strip (compact single row) ────────────────────────────────────
  Widget _buildSummaryStrip() {
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6B46C1), Color(0xFF5A3BA3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Balance
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL SETTLED',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${_completedTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: const [
                      Icon(Icons.trending_up_rounded,
                          size: 12, color: Color(0xFF99F6E4)),
                      SizedBox(width: 3),
                      Text(
                        '+12.5% from yesterday',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF99F6E4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              width: 1,
              height: 48,
              color: Colors.white24,
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),

            // Pending stat
            Expanded(
              flex: 3,
              child: _statCell(
                icon: Icons.schedule_rounded,
                iconColor: const Color(0xFFFBBF24),
                value: '$_pendingCount',
                label: 'Pending',
              ),
            ),

            // Divider
            Container(
              width: 1,
              height: 48,
              color: Colors.white24,
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),

            // Completed stat
            Expanded(
              flex: 3,
              child: _statCell(
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF34D399),
                value: '$_completedCount',
                label: 'Done',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCell({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white60),
        ),
      ],
    );
  }

  // ── Search + Filter Chips ──────────────────────────────────────────────────
  Widget _buildSearchAndFilters() {
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          // Search bar
          GestureDetector(
            onTap: () {
              setState(() => _isSearchOpen = true);
              _searchFocus.requestFocus();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 40,
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isSearchOpen ? _primaryLight : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Icon(Icons.search_rounded,
                      size: 18, color: _isSearchOpen ? _primary : _textLight),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      focusNode: _searchFocus,
                      style: const TextStyle(fontSize: 13, color: _textDark),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search by recipient or ID…',
                        hintStyle: TextStyle(fontSize: 13, color: _textLight),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                      onTap: () => setState(() => _isSearchOpen = true),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() {
                          _searchQuery = '';
                          _isSearchOpen = false;
                        });
                        _searchFocus.unfocus();
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.close_rounded,
                            size: 16, color: _textLight),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip('All', 'all'),
                const SizedBox(width: 6),
                _chip('Credit Card', 'credit_card'),
                const SizedBox(width: 6),
                _chip('Bank Transfer', 'bank_transfer'),
                const SizedBox(width: 6),
                _chip('Digital Wallet', 'digital_wallet'),
                const SizedBox(width: 6),
                _chip('Cash', 'cash'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    final selected = _selectedMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? _primary : _bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _primary : _border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : _textMid,
          ),
        ),
      ),
    );
  }

  // ── Batch action bar ───────────────────────────────────────────────────────
  Widget _buildBatchBar() {
    return Container(
      color: _accent.withOpacity(0.08),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_selectedIds.length}',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${_selectedIds.length == 1 ? "transaction" : "transactions"} selected',
            style: const TextStyle(
                fontSize: 13, color: _textDark, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _processBatchPayments,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('Process Batch',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── List header ────────────────────────────────────────────────────────────
  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          const Text(
            'Transactions',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _textDark,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${_filtered.length}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _primary,
              ),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: Size.zero,
            ),
            child: const Text(
              'View All',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Transaction List ───────────────────────────────────────────────────────
  Widget _buildTransactionList() {
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.search_off_rounded,
                  size: 36, color: _textLight),
            ),
            const SizedBox(height: 16),
            const Text(
              'No transactions found',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: _textDark),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try adjusting your search or filters',
              style: TextStyle(fontSize: 13, color: _textLight),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final t = _filtered[index];
        return _buildTransactionCard(t);
      },
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> t) {
    final isSelected = _selectedIds.contains(t['id']);
    final methodColor = _methodColor(t['method'] as String);
    final methodIcon = _methodIcon(t['method'] as String);

    return GestureDetector(
      onTap: () => _onTap(t),
      onLongPress: () => _onLongPress(t),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? _primary.withOpacity(0.06) : _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _primary : _border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Selection indicator / avatar
            if (_isMultiSelect)
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: isSelected ? _primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? _primary : _border,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14)
                    : null,
              ),

            // Avatar
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: methodColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  t['initials'] as String,
                  style: TextStyle(
                    color: methodColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t['recipient'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${(t['amount'] as num).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color:
                              t['status'] == 'failed' ? _failedFg : _textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Method icon + name
                      Icon(methodIcon, size: 12, color: methodColor),
                      const SizedBox(width: 4),
                      Text(
                        _prettyMethod(t['method'] as String),
                        style: TextStyle(
                            fontSize: 11,
                            color: methodColor,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: _textLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t['date'] as String,
                          style:
                              const TextStyle(fontSize: 11, color: _textLight),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _statusChip(t['status'] as String),
                    ],
                  ),
                ],
              ),
            ),

            // More button
            GestureDetector(
              onTap: () => _showQuickActions(t),
              child: Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(left: 6),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.more_vert_rounded,
                    size: 16, color: _textLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Status chip ────────────────────────────────────────────────────────────
  Widget _statusChip(String status) {
    Color bg, fg;
    String label;
    switch (status) {
      case 'pending':
        bg = _pendingBg;
        fg = _pendingFg;
        label = 'Pending';
        break;
      case 'processing':
        bg = _processingBg;
        fg = _processingFg;
        label = 'Processing';
        break;
      case 'completed':
        bg = _completedBg;
        fg = _completedFg;
        label = 'Done';
        break;
      case 'failed':
        bg = _failedBg;
        fg = _failedFg;
        label = 'Failed';
        break;
      default:
        bg = _border;
        fg = _textMid;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  // ── FAB ────────────────────────────────────────────────────────────────────
  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _generateDemoTransaction,
      backgroundColor: Color(0xFF5A3BA3),
      elevation: 4,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text(
        'New Payment',
        style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.w700,
            fontSize: 14),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Color _methodColor(String method) {
    switch (method) {
      case 'credit_card':
        return const Color(0xFF6366F1);
      case 'bank_transfer':
        return const Color(0xFF0EA5E9);
      case 'digital_wallet':
        return const Color(0xFFF59E0B);
      case 'cash':
        return const Color(0xFF10B981);
      default:
        return _textLight;
    }
  }

  IconData _methodIcon(String method) {
    switch (method) {
      case 'credit_card':
        return Icons.credit_card_rounded;
      case 'bank_transfer':
        return Icons.account_balance_rounded;
      case 'digital_wallet':
        return Icons.account_balance_wallet_rounded;
      case 'cash':
        return Icons.attach_money_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  String _prettyMethod(String method) {
    switch (method) {
      case 'credit_card':
        return 'Credit Card';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'digital_wallet':
        return 'Wallet';
      case 'cash':
        return 'Cash';
      default:
        return method;
    }
  }

  void _onTap(Map<String, dynamic> t) {
    if (_isMultiSelect) {
      setState(() {
        if (_selectedIds.contains(t['id'])) {
          _selectedIds.remove(t['id']);
          if (_selectedIds.isEmpty) _isMultiSelect = false;
        } else {
          _selectedIds.add(t['id'] as String);
        }
      });
    } else {
      _showDetails(t);
    }
  }

  void _onLongPress(Map<String, dynamic> t) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isMultiSelect = true;
      if (!_selectedIds.contains(t['id'])) {
        _selectedIds.add(t['id'] as String);
      }
    });
  }

  // ── Detail Sheet ───────────────────────────────────────────────────────────
  void _showDetails(Map<String, dynamic> t) {
    final methodColor = _methodColor(t['method'] as String);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: methodColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              t['initials'] as String,
                              style: TextStyle(
                                color: methodColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t['recipient'] as String,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: _textDark,
                                ),
                              ),
                              Text(
                                t['id'] as String,
                                style: const TextStyle(
                                    fontSize: 12, color: _textLight),
                              ),
                            ],
                          ),
                        ),
                        _statusChip(t['status'] as String),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Amount block
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Amount',
                                  style: TextStyle(
                                      fontSize: 12, color: _textLight)),
                              Text(
                                '\$${(t['amount'] as num).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: t['status'] == 'failed'
                                      ? _failedFg
                                      : _primary,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Fee',
                                  style: TextStyle(
                                      fontSize: 12, color: _textLight)),
                              Text(
                                '\$${(t['fee'] as num).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _textDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Detail rows
                    _detailRow('Description', t['description'] as String),
                    _detailRow('Date & Time', t['date'] as String),
                    _detailRow('Est. Completion', t['eta'] as String),
                    if (t['cardLast4'] != null)
                      _detailRow('Card', '**** **** **** ${t['cardLast4']}'),
                    if (t['accountNumber'] != null)
                      _detailRow('Account', t['accountNumber'] as String),
                    if (t['walletId'] != null)
                      _detailRow('Wallet', t['walletId'] as String),

                    // Failure notice
                    if (t['status'] == 'failed' &&
                        t['failureReason'] != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _failedBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _failedFg.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: _failedFg, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                t['failureReason'] as String,
                                style: const TextStyle(
                                    color: _failedFg,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Security badges
                    const SizedBox(height: 16),
                    const Text(
                      'Security & Compliance',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: (t['badges'] as List)
                          .map((b) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: _primary.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified_user_rounded,
                                        size: 11, color: _primary),
                                    const SizedBox(width: 4),
                                    Text(b as String,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: _primary,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),

                    // Actions
                    const SizedBox(height: 24),
                    _actionButtons(t, ctx),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: _textLight)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: _textDark),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons(Map<String, dynamic> t, BuildContext ctx) {
    if (t['status'] == 'pending') {
      return Column(
        children: [
          _primaryBtn(Icons.bolt_rounded, 'Process Now', () {
            Navigator.pop(ctx);
            _processPayment(t);
          }),
          const SizedBox(height: 10),
          _outlineBtn(Icons.schedule_rounded, 'Schedule Payment', () {
            Navigator.pop(ctx);
            _schedulePayment(t);
          }),
          const SizedBox(height: 10),
          _dangerBtn(Icons.cancel_rounded, 'Cancel Transaction', () {
            Navigator.pop(ctx);
            _cancelTransaction(t);
          }),
        ],
      );
    } else if (t['status'] == 'failed') {
      return _primaryBtn(Icons.refresh_rounded, 'Retry Payment', () {
        Navigator.pop(ctx);
        _retryPayment(t);
      });
    } else if (t['status'] == 'completed') {
      return _outlineBtn(Icons.receipt_long_rounded, 'Generate Receipt', () {
        Navigator.pop(ctx);
        _generateReceipt(t);
      });
    }
    return const SizedBox.shrink();
  }

  Widget _primaryBtn(IconData icon, String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: Colors.white),
        label: Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _outlineBtn(IconData icon, String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: _primary),
        label: Text(label,
            style:
                const TextStyle(color: _primary, fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: _primary),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _dangerBtn(IconData icon, String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: _failedFg),
        label: Text(label,
            style:
                const TextStyle(color: _failedFg, fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: _failedFg.withOpacity(0.4)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ── Quick actions sheet ────────────────────────────────────────────────────
  void _showQuickActions(Map<String, dynamic> t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: _border, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (t['status'] == 'pending') ...[
                    _actionTile(ctx, Icons.bolt_rounded, _primary,
                        'Process Now', () => _processPayment(t)),
                    _actionTile(ctx, Icons.schedule_rounded, _accent,
                        'Schedule Payment', () => _schedulePayment(t)),
                    _actionTile(ctx, Icons.cancel_rounded, _failedFg, 'Cancel',
                        () => _cancelTransaction(t)),
                  ],
                  if (t['status'] == 'failed')
                    _actionTile(ctx, Icons.refresh_rounded, _primary,
                        'Retry Payment', () => _retryPayment(t)),
                  _actionTile(ctx, Icons.receipt_long_rounded, _primary,
                      'Generate Receipt', () => _generateReceipt(t)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(BuildContext ctx, IconData icon, Color color, String label,
      VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
      onTap: () {
        Navigator.pop(ctx);
        onTap();
      },
    );
  }

  // ── Filter sheet ───────────────────────────────────────────────────────────
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: _border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Filter Options',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _textDark)),
              const SizedBox(height: 16),
              const Text('Payment Status',
                  style: TextStyle(fontSize: 12, color: _textLight)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children:
                    ['All', 'Pending', 'Processing', 'Completed', 'Failed']
                        .map((s) => FilterChip(
                              label: Text(s),
                              selected: false,
                              onSelected: (_) => Navigator.pop(ctx),
                              backgroundColor: _bg,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ))
                        .toList(),
              ),
              const SizedBox(height: 16),
              const Text('Date Range',
                  style: TextStyle(fontSize: 12, color: _textLight)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: ['Today', 'This Week', 'This Month', 'Custom']
                    .map((s) => FilterChip(
                          label: Text(s),
                          selected: false,
                          onSelected: (_) => Navigator.pop(ctx),
                          backgroundColor: _bg,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  void _processPayment(Map<String, dynamic> t) {
    _showProcessingDialog(t);
  }

  void _schedulePayment(Map<String, dynamic> t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Payment ${t['id']} scheduled'),
      backgroundColor: _primary,
      action: SnackBarAction(
          label: 'UNDO', textColor: Colors.white, onPressed: () {}),
    ));
  }

  void _cancelTransaction(Map<String, dynamic> t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Transaction'),
        content: Text('Cancel ${t['id']}? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Keep')),
          TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${t['id']} cancelled'),
                  backgroundColor: _failedFg,
                ));
              },
              style: TextButton.styleFrom(foregroundColor: _failedFg),
              child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _retryPayment(Map<String, dynamic> t) =>
      _showProcessingDialog(t, isRetry: true);

  void _generateReceipt(Map<String, dynamic> t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Receipt for ${t['id']} sent to email'),
      backgroundColor: _primary,
    ));
  }

  void _processBatchPayments() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Process Batch'),
        content: Text(
            'Process ${_selectedIds.length} payment${_selectedIds.length > 1 ? 's' : ''}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showBatchProcessing();
              },
              style: ElevatedButton.styleFrom(backgroundColor: _primary),
              child:
                  const Text('Process', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  void _showProcessingDialog(Map<String, dynamic> t, {bool isRetry = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: _primary),
            const SizedBox(height: 16),
            Text(isRetry ? 'Retrying…' : 'Processing…',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: _textDark)),
            const SizedBox(height: 4),
            Text(t['id'] as String,
                style: const TextStyle(fontSize: 12, color: _textLight)),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context);
        _showSuccess(t);
      }
    });
  }

  void _showSuccess(Map<String, dynamic> t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration:
                  BoxDecoration(color: _completedBg, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded,
                  color: _completedFg, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Payment Successful!',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _completedFg)),
            const SizedBox(height: 6),
            Text('\$${(t['amount'] as num).toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _textDark)),
            Text('to ${t['recipient']}',
                style: const TextStyle(fontSize: 13, color: _textLight)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _generateReceipt(t);
              },
              child: const Text('Get Receipt')),
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
        ],
      ),
    );
  }

  void _showBatchProcessing() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: _primary),
            const SizedBox(height: 16),
            const Text('Processing batch…',
                style:
                    TextStyle(fontWeight: FontWeight.w600, color: _textDark)),
            Text('${_selectedIds.length} transactions',
                style: const TextStyle(fontSize: 12, color: _textLight)),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pop(context);
        setState(() {
          _isMultiSelect = false;
          _selectedIds.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Batch processing complete'),
          backgroundColor: _primary,
        ));
      }
    });
  }

  void _generateDemoTransaction() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('New payment created'),
      backgroundColor: _primary,
      action: SnackBarAction(
          label: 'VIEW', textColor: Colors.white, onPressed: () {}),
    ));
  }
}
