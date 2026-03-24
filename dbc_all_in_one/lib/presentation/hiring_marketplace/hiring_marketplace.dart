import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';

class HiringMarketplace extends StatefulWidget {
  const HiringMarketplace({super.key});

  @override
  State<HiringMarketplace> createState() => _HiringMarketplaceState();
}

class _HiringMarketplaceState extends State<HiringMarketplace>
    with SingleTickerProviderStateMixin {
  int _currentBottomNavIndex = 3;
  late TabController _subTabController;

  // ── Colours ───────────────────────────────────────────────────────────────
  static const _purple  = Color(0xFF6B46C1);
  static const _dark    = Color(0xFF1A1A1A);
  static const _grey    = Color(0xFF9E9E9E);
  static const _bg      = Color(0xFFF5F5F7);
  static const _surface = Colors.white;

  // ── Mock data ─────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _jobPositions = [
    {
      'id': 1,
      'title': 'Senior Chef',
      'department': 'Kitchen Operations',
      'status': 'ACTIVE',
      'applications': 24,
      'postedDate': 'Oct 12, 2023',
      'icon': Icons.restaurant_menu_rounded,
      'iconBg': Color(0xFFFFF3E0),
      'iconColor': Color(0xFFFF8F00),
      'candidates': ['https://i.pravatar.cc/150?img=1', 'https://i.pravatar.cc/150?img=2', 'https://i.pravatar.cc/150?img=3'],
      'extraCount': 21,
    },
    {
      'id': 2,
      'title': 'Waitstaff',
      'department': 'Front of House',
      'status': 'ACTIVE',
      'applications': 142,
      'postedDate': 'Oct 05, 2023',
      'icon': Icons.local_bar_rounded,
      'iconBg': Color(0xFFE8F5E9),
      'iconColor': Color(0xFF2E7D32),
      'candidates': ['https://i.pravatar.cc/150?img=5', 'https://i.pravatar.cc/150?img=6'],
      'extraCount': 140,
    },
    {
      'id': 3,
      'title': 'Housekeeping',
      'department': 'Maintenance',
      'status': 'CLOSED',
      'applications': 8,
      'postedDate': 'Sep 28, 2023',
      'icon': Icons.cleaning_services_rounded,
      'iconBg': Color(0xFFF3E5F5),
      'iconColor': Color(0xFF6A1B9A),
      'candidates': ['https://i.pravatar.cc/150?img=9'],
      'extraCount': 0,
    },
    {
      'id': 4,
      'title': 'Receptionist',
      'department': 'Administration',
      'status': 'ACTIVE',
      'applications': 56,
      'postedDate': 'Oct 14, 2023',
      'icon': Icons.support_agent_rounded,
      'iconBg': Color(0xFFE3F2FD),
      'iconColor': Color(0xFF1565C0),
      'candidates': ['https://i.pravatar.cc/150?img=11', 'https://i.pravatar.cc/150?img=12'],
      'extraCount': 54,
    },
  ];

  final List<Map<String, dynamic>> _candidates = [
    {
      "id": 1, "name": "Sarah Johnson", "role": "Cashier",
      "experience": "3 years", "rating": 4.8, "availability": "Immediate", "distance": "2.3 km",
      "photo": "https://i.pravatar.cc/150?img=1",
      "skills": ["POS Systems", "Customer Service", "Cash Handling"],
      "salary": "\$15-18/hr", "isFavorite": false,
    },
    {
      "id": 2, "name": "Michael Chen", "role": "Cook",
      "experience": "5 years", "rating": 4.9, "availability": "Part-time", "distance": "1.8 km",
      "photo": "https://i.pravatar.cc/150?img=2",
      "skills": ["Italian Cuisine", "Food Safety", "Menu Planning"],
      "salary": "\$20-25/hr", "isFavorite": false,
    },
    {
      "id": 3, "name": "Emily Rodriguez", "role": "Waiter",
      "experience": "2 years", "rating": 4.7, "availability": "Full-time", "distance": "3.5 km",
      "photo": "https://i.pravatar.cc/150?img=3",
      "skills": ["Table Service", "Wine Knowledge", "Customer Relations"],
      "salary": "\$12-15/hr + tips", "isFavorite": true,
    },
    {
      "id": 4, "name": "David Thompson", "role": "Guard",
      "experience": "7 years", "rating": 4.9, "availability": "Immediate", "distance": "4.2 km",
      "photo": "https://i.pravatar.cc/150?img=4",
      "skills": ["Security Systems", "First Aid", "Conflict Resolution"],
      "salary": "\$18-22/hr", "isFavorite": false,
    },
    {
      "id": 5, "name": "Jessica Williams", "role": "Trainer",
      "experience": "4 years", "rating": 4.8, "availability": "Part-time", "distance": "2.9 km",
      "photo": "https://i.pravatar.cc/150?img=5",
      "skills": ["Personal Training", "Nutrition", "Group Classes"],
      "salary": "\$25-30/hr", "isFavorite": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  void _showCreatePositionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreatePositionSheet(
        onCreated: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Position created successfully'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ));
        },
      ),
    );
  }

  void _showJobDetail(Map<String, dynamic> job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _JobDetailSheet(job: job),
    );
  }

  void _showCandidateDetail(Map<String, dynamic> c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CandidateDetailSheet(
        candidate: c,
        onInvite: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Invite sent to ${c["name"]}'),
            behavior: SnackBarBehavior.floating,
          ));
        },
        onMessage: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Opening chat with ${c["name"]}'),
            behavior: SnackBarBehavior.floating,
          ));
        },
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      // No custom AppBar — parent Staff Management scaffold owns it
      body: Column(children: [
        // ── Sub-tab bar: Job Positions / Applications ──
        Container(
          color: _surface,
          child: TabBar(
            controller: _subTabController,
            labelColor: _purple,
            unselectedLabelColor: _grey,
            labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            indicatorColor: _purple,
            indicatorWeight: 2.5,
            tabs: const [
              Tab(text: 'Job Positions'),
              Tab(text: 'Applications'),
            ],
          ),
        ),

        // ── Tab content ──
        Expanded(child: TabBarView(
          controller: _subTabController,
          children: [
            _buildJobPositionsTab(),
            _buildApplicationsTab(),
          ],
        )),
      ]),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePositionSheet,
        backgroundColor: _purple,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Position',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),

      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (i) => setState(() => _currentBottomNavIndex = i),
        variant: CustomBottomBarVariant.standard,
      ),
    );
  }

  // ── JOB POSITIONS TAB ─────────────────────────────────────────────────────
  Widget _buildJobPositionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          const Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Active Roles',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _dark)),
              SizedBox(height: 3),
              Text('Manage and monitor your current recruitment pipelines.',
                  style: TextStyle(fontSize: 12, color: _grey)),
            ],
          )),
          _headerBtn(Icons.tune_rounded, 'Filter'),
          const SizedBox(width: 8),
          _headerBtn(Icons.sort_rounded, 'Sort'),
        ]),

        const SizedBox(height: 20),

        // 2-column grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.80,
          ),
          itemCount: _jobPositions.length + 1,
          itemBuilder: (_, i) {
            if (i == _jobPositions.length) return _buildCreateCard();
            return _buildJobCard(_jobPositions[i]);
          },
        ),
      ]),
    );
  }

  Widget _headerBtn(IconData icon, String label) => GestureDetector(
    onTap: () {},
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E5E5)),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: _dark),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: _dark)),
      ]),
    ),
  );

  Widget _buildJobCard(Map<String, dynamic> job) {
    final isActive = job['status'] == 'ACTIVE';
    final statusColor = isActive ? const Color(0xFF10B981) : _grey;
    final statusBg    = isActive ? const Color(0xFFD1FAE5) : const Color(0xFFF3F4F6);

    return GestureDetector(
      onTap: () => _showJobDetail(job),
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Icon + badge
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: job['iconBg'] as Color,
                  borderRadius: BorderRadius.circular(10)),
                child: Icon(job['icon'] as IconData,
                    color: job['iconColor'] as Color, size: 22),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg, borderRadius: BorderRadius.circular(5)),
                child: Text(job['status'] as String,
                    style: TextStyle(
                        fontSize: 9, fontWeight: FontWeight.w800,
                        color: statusColor, letterSpacing: 0.5)),
              ),
            ]),

            const SizedBox(height: 10),

            Text(job['title'] as String,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: _dark),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(job['department'] as String,
                style: const TextStyle(fontSize: 11, color: _grey),
                maxLines: 1, overflow: TextOverflow.ellipsis),

            const SizedBox(height: 12),
            Container(height: 1, color: const Color(0xFFF0F0F0)),
            const SizedBox(height: 12),

            // Stats
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('APPLICATIONS',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
                        color: _grey, letterSpacing: 0.4)),
                const SizedBox(height: 3),
                Text('${job['applications']}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800, color: _dark)),
              ])),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('POSTED DATE',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
                        color: _grey, letterSpacing: 0.4)),
                const SizedBox(height: 3),
                Text(job['postedDate'] as String,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: _dark)),
              ])),
            ]),

            const SizedBox(height: 14),

            // Avatar stack + View
            Row(children: [
              _buildAvatarStack(
                  job['candidates'] as List<String>,
                  job['extraCount'] as int),
              const Spacer(),
              GestureDetector(
                onTap: () => _showJobDetail(job),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('View',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: isActive ? _purple : _grey)),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 11, color: isActive ? _purple : _grey),
                ]),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildAvatarStack(List<String> urls, int extra) {
    final show = urls.take(3).toList();
    return Row(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        height: 26,
        width: show.length * 18.0 + 8,
        child: Stack(
          children: List.generate(show.length, (i) => Positioned(
            left: i * 18.0,
            child: Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                image: DecorationImage(
                  image: NetworkImage(show[i]), fit: BoxFit.cover),
              ),
            ),
          )),
        ),
      ),
      if (extra > 0) ...[
        const SizedBox(width: 4),
        Text('+$extra',
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: _grey)),
      ],
    ]);
  }

  Widget _buildCreateCard() => GestureDetector(
    onTap: _showCreatePositionSheet,
    child: Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1.5)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: const Color(0xFFE5E0F5), width: 1.5)),
          child: const Icon(Icons.add_rounded, color: _purple, size: 22),
        ),
        const SizedBox(height: 12),
        const Text('Create New Position',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: _dark),
            textAlign: TextAlign.center),
        const SizedBox(height: 6),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'Define a new role and start receiving applications.',
            style: TextStyle(fontSize: 11, color: _grey),
            textAlign: TextAlign.center),
        ),
      ]),
    ),
  );

  // ── APPLICATIONS TAB ──────────────────────────────────────────────────────
  Widget _buildApplicationsTab() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _candidates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _buildCandidateCard(_candidates[i]),
    );
  }

  Widget _buildCandidateCard(Map<String, dynamic> c) {
    final avail = c['availability'] as String;
    Color availColor;
    switch (avail.toLowerCase()) {
      case 'immediate': availColor = const Color(0xFF10B981); break;
      case 'part-time': availColor = const Color(0xFFF59E0B); break;
      default:          availColor = const Color(0xFF3B82F6);
    }

    return GestureDetector(
      onTap: () => _showCandidateDetail(c),
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  c['photo'] as String,
                  width: 52, height: 52, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 52, height: 52, color: const Color(0xFFF0EEFA),
                    child: const Icon(Icons.person_outline, color: _purple, size: 28)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(c['name'] as String,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700, color: _dark))),
                    GestureDetector(
                      onTap: () => setState(() =>
                          c['isFavorite'] = !(c['isFavorite'] as bool)),
                      child: Icon(
                        (c['isFavorite'] as bool)
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: (c['isFavorite'] as bool)
                            ? Colors.red : const Color(0xFFCCCCCC),
                        size: 18),
                    ),
                  ]),
                  const SizedBox(height: 3),
                  Text('${c['role']} · ${c['experience']}',
                      style: const TextStyle(fontSize: 12, color: _grey)),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 14),
                    const SizedBox(width: 3),
                    Text('${c['rating']}',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700, color: _dark)),
                    const SizedBox(width: 10),
                    const Icon(Icons.location_on_outlined, color: _grey, size: 13),
                    const SizedBox(width: 2),
                    Text(c['distance'] as String,
                        style: const TextStyle(fontSize: 11, color: _grey)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: availColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5)),
                      child: Text(avail,
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w600,
                              color: availColor)),
                    ),
                  ]),
                ],
              )),
            ]),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF0F0F0)))),
            child: Row(children: [
              Expanded(child: Wrap(spacing: 6, runSpacing: 4,
                children: (c['skills'] as List).take(2).map((s) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(5)),
                  child: Text(s as String,
                      style: const TextStyle(
                          fontSize: 10, color: _purple, fontWeight: FontWeight.w500)),
                )).toList(),
              )),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Invite sent to ${c['name']}'),
                    behavior: SnackBarBehavior.floating,
                  ));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _purple,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(
                      color: _purple.withOpacity(0.3),
                      blurRadius: 6, offset: const Offset(0, 2))]),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.send_rounded, color: Colors.white, size: 13),
                    SizedBox(width: 5),
                    Text('Invite',
                        style: TextStyle(
                            color: Colors.white, fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Create Position Sheet ──────────────────────────────────────────────────────
class _CreatePositionSheet extends StatefulWidget {
  final VoidCallback onCreated;
  const _CreatePositionSheet({required this.onCreated});

  @override
  State<_CreatePositionSheet> createState() => _CreatePositionSheetState();
}

class _CreatePositionSheetState extends State<_CreatePositionSheet> {
  static const _purple = Color(0xFF6B46C1);
  final _titleCtrl = TextEditingController();
  final _deptCtrl  = TextEditingController();
  String _type = 'Full-time';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
            child: Row(children: [
              const Text('Create New Position',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(children: [
              _field(_titleCtrl, 'Job Title (e.g. Senior Chef)'),
              const SizedBox(height: 12),
              _field(_deptCtrl, 'Department (e.g. Kitchen Operations)'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: InputDecoration(
                  labelText: 'Employment Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _purple, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                items: ['Full-time', 'Part-time', 'Contract', 'Internship']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onCreated,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0),
                  child: const Text('Create Position',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 16),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label) => TextField(
    controller: ctrl,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _purple, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
  );

  @override
  void dispose() {
    _titleCtrl.dispose(); _deptCtrl.dispose();
    super.dispose();
  }
}

// ── Job Detail Sheet ───────────────────────────────────────────────────────────
class _JobDetailSheet extends StatelessWidget {
  final Map<String, dynamic> job;
  const _JobDetailSheet({required this.job});

  static const _purple = Color(0xFF6B46C1);
  static const _dark   = Color(0xFF1A1A1A);
  static const _grey   = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    final isActive     = job['status'] == 'ACTIVE';
    final statusColor  = isActive ? const Color(0xFF10B981) : _grey;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        Container(
          margin: const EdgeInsets.only(top: 10),
          width: 40, height: 4,
          decoration: BoxDecoration(
              color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: job['iconBg'] as Color,
                  borderRadius: BorderRadius.circular(12)),
                child: Icon(job['icon'] as IconData,
                    color: job['iconColor'] as Color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job['title'] as String,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800, color: _dark)),
                  const SizedBox(height: 3),
                  Text(job['department'] as String,
                      style: const TextStyle(fontSize: 12, color: _grey)),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFD1FAE5) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6)),
                child: Text(job['status'] as String,
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: statusColor)),
              ),
            ]),
            const SizedBox(height: 24),
            Row(children: [
              _statBox('Applications', '${job['applications']}',
                  Icons.people_outline_rounded),
              const SizedBox(width: 12),
              _statBox('Posted', job['postedDate'] as String,
                  Icons.calendar_today_outlined),
            ]),
            const SizedBox(height: 24),
            const Text('Applicants',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: _dark)),
            const SizedBox(height: 12),
            Row(children: [
              ...(job['candidates'] as List<String>).take(5).map((url) =>
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CircleAvatar(radius: 22,
                    backgroundImage: NetworkImage(url),
                    onBackgroundImageError: (_, __) {}),
                )),
              if ((job['extraCount'] as int) > 0)
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFF0EEFA),
                  child: Text('+${job['extraCount']}',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700, color: _purple)),
                ),
            ]),
          ]),
        )),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16,
              MediaQuery.of(context).padding.bottom + 16),
          child: Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: Colors.grey.shade300)),
              child: const Text('Close',
                  style: TextStyle(color: _dark, fontWeight: FontWeight.w600)),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0),
              child: const Text('View Applications',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            )),
          ]),
        ),
      ]),
    );
  }

  Widget _statBox(String label, String value, IconData icon) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE))),
      child: Row(children: [
        Icon(icon, color: _purple, size: 20),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: _grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, color: _dark, fontWeight: FontWeight.w700)),
        ]),
      ]),
    ),
  );
}

// ── Candidate Detail Sheet ─────────────────────────────────────────────────────
class _CandidateDetailSheet extends StatelessWidget {
  final Map<String, dynamic> candidate;
  final VoidCallback onInvite;
  final VoidCallback onMessage;

  const _CandidateDetailSheet({
    required this.candidate,
    required this.onInvite,
    required this.onMessage,
  });

  static const _purple = Color(0xFF6B46C1);
  static const _dark   = Color(0xFF1A1A1A);
  static const _grey   = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        Container(
          margin: const EdgeInsets.only(top: 10),
          width: 40, height: 4,
          decoration: BoxDecoration(
              color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  candidate['photo'] as String,
                  width: 68, height: 68, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 68, height: 68, color: const Color(0xFFF0EEFA),
                    child: const Icon(Icons.person_outline, color: _purple, size: 36)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(candidate['name'] as String,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800, color: _dark)),
                  const SizedBox(height: 4),
                  Text('${candidate['role']} · ${candidate['experience']}',
                      style: const TextStyle(fontSize: 13, color: _grey)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 15),
                    const SizedBox(width: 4),
                    Text('${candidate['rating']}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700, color: _dark)),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on_outlined, color: _grey, size: 14),
                    const SizedBox(width: 3),
                    Text(candidate['distance'] as String,
                        style: const TextStyle(fontSize: 12, color: _grey)),
                  ]),
                ],
              )),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: _grey),
                onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 22),
            ...[
              ['Salary',       candidate['salary']],
              ['Availability', candidate['availability']],
            ].map((row) => _detailRow(row[0] as String, row[1] as String)),
            const SizedBox(height: 16),
            const Text('Skills',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: _dark)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8,
              children: (candidate['skills'] as List).map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: const Color(0xFFE5E0F5))),
                child: Text(s as String,
                    style: const TextStyle(
                        fontSize: 12, color: _purple, fontWeight: FontWeight.w500)),
              )).toList(),
            ),
          ]),
        )),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16,
              MediaQuery.of(context).padding.bottom + 16),
          child: Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: onMessage,
              icon: const Icon(Icons.message_outlined, size: 17),
              label: const Text('Message'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                foregroundColor: _purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: _purple)),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton.icon(
              onPressed: onInvite,
              icon: const Icon(Icons.calendar_today_rounded, size: 16),
              label: const Text('Invite'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0),
            )),
          ]),
        ),
      ]),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Text(label, style: const TextStyle(fontSize: 13, color: _grey)),
      const Spacer(),
      Text(value, style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w700, color: _dark)),
    ]),
  );
}