import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

// ─────────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────────

class StaffMember {
  String name, role, status, hours;
  Color avatarColor;
  StaffMember(
      {required this.name,
      required this.role,
      required this.status,
      required this.hours,
      required this.avatarColor});
}

class JobPosition {
  String title, department, status, postedDate;
  int applications;
  Color iconBg;
  IconData icon;
  JobPosition(
      {required this.title,
      required this.department,
      required this.status,
      required this.applications,
      required this.postedDate,
      required this.iconBg,
      required this.icon});
}

class Candidate {
  String name, email, phone, company, status;
  int experience;
  Color avatarColor;
  Candidate(
      {required this.name,
      required this.email,
      required this.phone,
      required this.experience,
      required this.company,
      required this.status,
      required this.avatarColor});
}

class AttendanceRecord {
  String initials, name, role, checkIn, arrivalNote, locationStatus;
  Color avatarColor;
  AttendanceRecord(
      {required this.initials,
      required this.name,
      required this.role,
      required this.checkIn,
      required this.arrivalNote,
      required this.locationStatus,
      required this.avatarColor});
}

// ─────────────────────────────────────────────
//  CONSTANTS
// ─────────────────────────────────────────────

const _purple = Color(0xff6D28D9);
const _purpleLight = Color(0xffEDE9FE);
const _bg = Color(0xffF3F4F8);
const _white = Colors.white;
const _textDark = Color(0xff111827);
const _textMid = Color(0xff6B7280);
const _border = Color(0xffE5E7EB);
const _green = Color(0xff16A34A);
const _red = Color(0xffDC2626);
const _orange = Color(0xffD97706);
const _teal = Color(0xff0D9488);

// ─────────────────────────────────────────────
//  WIDGET
// ─────────────────────────────────────────────

class StaffManagement extends StatefulWidget {
  const StaffManagement({super.key});
  @override
  State<StaffManagement> createState() => _StaffManagementState();
}

class _StaffManagementState extends State<StaffManagement>
    with TickerProviderStateMixin {
  late TabController _mainTab;
  late TabController _hiringSubTab;
  int _appFilter = 0;

  // ── Data ──────────────────────────────────

  late final List<StaffMember> _staff = [
    StaffMember(
        name: "Amelia Thorne",
        role: "Lead Designer",
        status: "In Office",
        hours: "6.2h",
        avatarColor: const Color(0xff4F86C6)),
    StaffMember(
        name: "Marcus Chen",
        role: "Operations Hub",
        status: "Off Duty",
        hours: "0.0h",
        avatarColor: const Color(0xff5BA85C)),
    StaffMember(
        name: "Julian Brooks",
        role: "Senior Architect",
        status: "In Office",
        hours: "4.5h",
        avatarColor: const Color(0xff2C3E50)),
    StaffMember(
        name: "Sarah Jenkins",
        role: "Security Head",
        status: "Break",
        hours: "5.1h",
        avatarColor: const Color(0xff1A6B8A)),
    StaffMember(
        name: "Elena Rossi",
        role: "Inventory Specialist",
        status: "In Office",
        hours: "3.8h",
        avatarColor: const Color(0xff7B5EA7)),
  ];

  final List<AttendanceRecord> _attendance = [
    AttendanceRecord(
        initials: "JD",
        name: "Jordan Davis",
        role: "Lead Designer",
        checkIn: "08:52 AM",
        arrivalNote: "Early",
        locationStatus: "ON-SITE",
        avatarColor: const Color(0xff5BA85C)),
    AttendanceRecord(
        initials: "SL",
        name: "Sarah Lopez",
        role: "Project Manager",
        checkIn: "09:14 AM",
        arrivalNote: "14m Late",
        locationStatus: "LATE",
        avatarColor: const Color(0xffD97706)),
    AttendanceRecord(
        initials: "MK",
        name: "Marcus Kane",
        role: "Security Tech",
        checkIn: "-- : --",
        arrivalNote: "No Entry",
        locationStatus: "ABSENT",
        avatarColor: const Color(0xff6B7280)),
    AttendanceRecord(
        initials: "EA",
        name: "Elena Aris",
        role: "Software Engineer",
        checkIn: "08:45 AM",
        arrivalNote: "Early",
        locationStatus: "REMOTE",
        avatarColor: const Color(0xff4F86C6)),
  ];

  late final List<JobPosition> _jobs = [
    JobPosition(
        title: "Senior Chef",
        department: "Kitchen Operations",
        status: "ACTIVE",
        applications: 24,
        postedDate: "Oct 12, 2023",
        iconBg: const Color(0xffFFF7ED),
        icon: Icons.restaurant),
    JobPosition(
        title: "Waitstaff",
        department: "Front of House",
        status: "ACTIVE",
        applications: 142,
        postedDate: "Oct 05, 2023",
        iconBg: const Color(0xffF0FDF4),
        icon: Icons.local_bar),
    JobPosition(
        title: "Housekeeping",
        department: "Maintenance",
        status: "CLOSED",
        applications: 8,
        postedDate: "Sep 28, 2023",
        iconBg: const Color(0xffF8F8F8),
        icon: Icons.cleaning_services),
    JobPosition(
        title: "Receptionist",
        department: "Administration",
        status: "ACTIVE",
        applications: 56,
        postedDate: "Oct 14, 2023",
        iconBg: const Color(0xffF5F3FF),
        icon: Icons.support_agent),
  ];

  late final List<Candidate> _candidates = [
    Candidate(
        name: "Marcus Chambers",
        email: "marcus.c@gmail.com",
        phone: "+1 (555) 012-3456",
        experience: 6,
        company: "Design Flow Inc.",
        status: "Pending",
        avatarColor: const Color(0xff2C3E50)),
    Candidate(
        name: "Sarah Jenkins",
        email: "s.jenkins@outlook.com",
        phone: "+1 (555) 012-9988",
        experience: 4,
        company: "Studio Creative",
        status: "Reviewing",
        avatarColor: const Color(0xff4F86C6)),
    Candidate(
        name: "Jordan Smith",
        email: "jsmith@techcore.io",
        phone: "+1 (555) 012-7722",
        experience: 8,
        company: "TechCore Systems",
        status: "Shortlisted",
        avatarColor: const Color(0xff5BA85C)),
    Candidate(
        name: "Priya Nair",
        email: "priya.n@studio.in",
        phone: "+1 (555) 012-4411",
        experience: 3,
        company: "Nik Designs",
        status: "Pending",
        avatarColor: const Color(0xff7B5EA7)),
  ];

  @override
  void initState() {
    super.initState();
    _mainTab = TabController(length: 4, vsync: this);
    _hiringSubTab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _mainTab.dispose();
    _hiringSubTab.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  MODALS
  // ─────────────────────────────────────────────

  void _showAddStaffModal() {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final hoursCtrl = TextEditingController(text: "0.0h");
    String selectedStatus = "In Office";

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setS) {
        return _buildModal(
          title: "Add New Staff",
          icon: Icons.person_add_outlined,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _inputField("Full Name", nameCtrl, hint: "e.g. Alex Rivera"),
              const SizedBox(height: 12),
              _inputField("Role / Position", roleCtrl,
                  hint: "e.g. Lead Designer"),
              const SizedBox(height: 12),
              _inputField("Hours Today", hoursCtrl, hint: "e.g. 4.5h"),
              const SizedBox(height: 12),
              const Text("Status",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textDark)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ["In Office", "Off Duty", "Break", "Remote"].map((s) {
                  final sel = selectedStatus == s;
                  return GestureDetector(
                    onTap: () => setS(() => selectedStatus = s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: sel ? _purple : _white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? _purple : _border),
                      ),
                      child: Text(s,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: sel ? _white : _textMid)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          onConfirm: () {
            if (nameCtrl.text.trim().isEmpty || roleCtrl.text.trim().isEmpty) {
              _snack("Please fill in all required fields");
              return;
            }
            final colors = [
              const Color(0xff4F86C6),
              const Color(0xff5BA85C),
              const Color(0xff7B5EA7),
              const Color(0xff2C3E50),
              const Color(0xff1A6B8A)
            ];
            setState(() {
              _staff.add(StaffMember(
                name: nameCtrl.text.trim(),
                role: roleCtrl.text.trim(),
                status: selectedStatus,
                hours: hoursCtrl.text.trim().isEmpty
                    ? "0.0h"
                    : hoursCtrl.text.trim(),
                avatarColor: colors[_staff.length % colors.length],
              ));
            });
            Navigator.pop(context);
            _snack("Staff member added successfully");
          },
          confirmLabel: "Add Staff",
        );
      }),
    );
  }

  void _showAddPositionModal() {
    final titleCtrl = TextEditingController();
    final deptCtrl = TextEditingController();
    String selectedStatus = "ACTIVE";
    int selectedIcon = 0;
    final icons = [
      Icons.restaurant,
      Icons.local_bar,
      Icons.cleaning_services,
      Icons.support_agent,
      Icons.computer,
      Icons.build_outlined
    ];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setS) {
        return _buildModal(
          title: "Create New Position",
          icon: Icons.work_outline_rounded,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _inputField("Job Title", titleCtrl, hint: "e.g. Senior Chef"),
              const SizedBox(height: 14),
              _inputField("Department", deptCtrl,
                  hint: "e.g. Kitchen Operations"),
              const SizedBox(height: 14),
              const Text("Status",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textDark)),
              const SizedBox(height: 8),
              Row(
                children: ["ACTIVE", "CLOSED"].map((s) {
                  final sel = selectedStatus == s;
                  return GestureDetector(
                    onTap: () => setS(() => selectedStatus = s),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? _purple : _white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? _purple : _border),
                      ),
                      child: Text(s,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: sel ? _white : _textMid)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              const Text("Icon",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textDark)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(icons.length, (i) {
                  final sel = selectedIcon == i;
                  return GestureDetector(
                    onTap: () => setS(() => selectedIcon = i),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: sel ? _purple : _purpleLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icons[i],
                          size: 20, color: sel ? _white : _purple),
                    ),
                  );
                }),
              ),
            ],
          ),
          onConfirm: () {
            if (titleCtrl.text.trim().isEmpty || deptCtrl.text.trim().isEmpty) {
              _snack("Please fill in all required fields");
              return;
            }
            final now = DateTime.now();
            setState(() {
              _jobs.add(JobPosition(
                title: titleCtrl.text.trim(),
                department: deptCtrl.text.trim(),
                status: selectedStatus,
                applications: 0,
                postedDate: "${_monthName(now.month)} ${now.day}, ${now.year}",
                iconBg: _purpleLight,
                icon: icons[selectedIcon],
              ));
            });
            Navigator.pop(context);
            _snack("Position created successfully");
          },
          confirmLabel: "Create Position",
        );
      }),
    );
  }

  void _showJobDetailModal(JobPosition job) {
    showDialog(
      context: context,
      builder: (_) => _buildModal(
        title: job.title,
        icon: job.icon,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow("Department", job.department),
            _detailRow("Status", job.status),
            _detailRow("Total Applications", "${job.applications}"),
            _detailRow("Posted Date", job.postedDate),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: _purpleLight, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.people_outline, color: _purple, size: 20),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(
                        "${job.applications} candidates have applied for this role.",
                        style: const TextStyle(
                            color: _purple,
                            fontWeight: FontWeight.w500,
                            fontSize: 13))),
              ]),
            ),
          ],
        ),
        onConfirm: () {
          Navigator.pop(context);
          _hiringSubTab.animateTo(1);
        },
        confirmLabel: "View Applications",
      ),
    );
  }

  void _showCandidateModal(Candidate c, String action) {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setS) {
        return _buildModal(
          title: action == "review" ? "Review Candidate" : "Schedule Interview",
          icon: action == "review"
              ? Icons.rate_review_outlined
              : Icons.calendar_month_outlined,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: c.avatarColor,
                  child: Text(c.name.split(' ').map((w) => w[0]).take(2).join(),
                      style: const TextStyle(
                          color: _white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                ),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(c.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: _textDark)),
                      Text(c.company,
                          style:
                              const TextStyle(fontSize: 13, color: _textMid)),
                    ])),
              ]),
              const SizedBox(height: 16),
              _detailRow("Experience", "${c.experience} Years"),
              _detailRow("Email", c.email),
              _detailRow("Phone", c.phone),
              _detailRow("Current Status", c.status),
              if (action == "review") ...[
                const SizedBox(height: 14),
                const Text("Update Status",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _textDark)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ["Pending", "Reviewing", "Shortlisted"].map((s) {
                    final sel = c.status == s;
                    return GestureDetector(
                      onTap: () {
                        setState(() => c.status = s);
                        setS(() {});
                        _snack("Status updated to $s");
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: sel ? _purple : _white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: sel ? _purple : _border),
                        ),
                        child: Text(s,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: sel ? _white : _textMid)),
                      ),
                    );
                  }).toList(),
                ),
              ],
              if (action == "schedule") ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: _purpleLight,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Row(children: [
                    Icon(Icons.event_available_outlined,
                        color: _purple, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                        child: Text(
                            "Interview will be scheduled and candidate notified via email.",
                            style: TextStyle(
                                color: _purple,
                                fontWeight: FontWeight.w500,
                                fontSize: 13))),
                  ]),
                ),
              ],
            ],
          ),
          onConfirm: action == "schedule"
              ? () {
                  Navigator.pop(context);
                  setState(() => c.status = "Reviewing");
                  _snack("Interview scheduled for ${c.name}");
                }
              : () => Navigator.pop(context),
          confirmLabel: action == "schedule" ? "Confirm Schedule" : "Done",
        );
      }),
    );
  }

  void _showStaffDetailModal(StaffMember s) {
    showDialog(
      context: context,
      builder: (_) => _buildModal(
        title: s.name,
        icon: Icons.person_outline,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: s.avatarColor,
                child: Text(s.name.split(' ').map((w) => w[0]).take(2).join(),
                    style: const TextStyle(
                        color: _white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20)),
              ),
            ),
            const SizedBox(height: 20),
            _detailRow("Role", s.role),
            _detailRow("Status", s.status),
            _detailRow("Hours Today", s.hours),
          ],
        ),
        onConfirm: () => Navigator.pop(context),
        confirmLabel: "Close",
      ),
    );
  }

  // ── Shared modal builder ──────────────────

  Widget _buildModal({
    required String title,
    required IconData icon,
    required Widget content,
    required void Function() onConfirm,
    required String confirmLabel,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: _white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: _purpleLight,
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: _purple, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(title,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _textDark))),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: _bg, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.close, size: 16, color: _textMid),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              const Divider(color: _border, height: 1),
              const SizedBox(height: 16),
              // Scrollable content
              Flexible(child: SingleChildScrollView(child: content)),
              const SizedBox(height: 20),
              // Actions
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _border),
                    foregroundColor: _textMid,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 11),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 11),
                  ),
                  onPressed: onConfirm,
                  child: Text(confirmLabel,
                      style: const TextStyle(
                          color: _white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shared helpers ───────────────────────

  Widget _inputField(String label, TextEditingController ctrl,
      {String hint = ""}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: _textDark)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _textMid, fontSize: 13),
            filled: true,
            fillColor: _bg,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _purple, width: 1.5)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: _textMid))),
        Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textDark))),
      ]),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: _white)),
      backgroundColor: _purple,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  String _monthName(int m) => [
        "",
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec"
      ][m];

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    String text;
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _topBar(),
          Container(
            color: _white,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: TabBar(
              controller: _mainTab,
              labelColor: _purple,
              unselectedLabelColor: _textMid,
              indicatorColor: _purple,
              indicatorWeight: 2.5,
              isScrollable: true,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              tabs: const [
                Tab(text: "Staff"),
                Tab(text: "Attendance"),
                Tab(text: "Hiring"),
                Tab(text: "Payroll")
              ]
                  .map((t) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        child: t,
                      ))
                  .toList(),
            ),
          ),
          const Divider(height: 1, color: _border),
          Expanded(
            child: TabBarView(
              controller: _mainTab,
              children: [
                _staffTab(),
                _attendanceTab(),
                _hiringMainTab(),
                _payrollTab()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Container(
      color: _white,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text("Studio Workspace",
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: _purple)),
          Text("Management Console",
              style: TextStyle(fontSize: 11, color: _textMid)),
        ]),
        const Spacer(),
        Container(
          width: 230,
          height: 38,
          decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _border)),
          child: const TextField(
            decoration: InputDecoration(
              hintText: "Quick find...",
              hintStyle: TextStyle(fontSize: 13, color: _textMid),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, size: 17, color: _textMid),
              contentPadding: EdgeInsets.symmetric(vertical: 9),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _circleBtn(Icons.notifications_none_rounded),
        const SizedBox(width: 8),
        _circleBtn(Icons.settings_outlined),
        const SizedBox(width: 10),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: _purple.withOpacity(0.12)),
          child: const Icon(Icons.person, color: _purple, size: 17),
        ),
      ]),
    );
  }

  Widget _circleBtn(IconData icon) => Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _border),
            color: _white),
        child: Icon(icon, size: 17, color: _textMid),
      );

  Widget _purpleBtn(String label, VoidCallback onTap) => SizedBox(
        height: 38,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _purple,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onPressed: onTap,
          child: Text(label,
              style: const TextStyle(
                  color: _white, fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      );

  Widget _outlineBtn(IconData icon, String label, VoidCallback onTap) =>
      SizedBox(
        height: 36,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _border),
            foregroundColor: _textMid,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          onPressed: onTap,
          icon: Icon(icon, size: 15),
          label: Text(label, style: const TextStyle(fontSize: 12)),
        ),
      );

  // ═══════════════════════════════════════════
  //  STAFF TAB
  // ═══════════════════════════════════════════

  Widget _staffTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text("Staff Directory",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _textDark)),
            const Spacer(),
            _purpleBtn("+ Add New Staff", _showAddStaffModal),
          ]),
          const SizedBox(height: 4),
          const Text("Search by name or role...",
              style: TextStyle(fontSize: 13, color: _textMid)),
          const SizedBox(height: 18),
          // Stat cards
          Row(children: [
            _staffStatCard(
                icon: Icons.person_outline_rounded,
                iconColor: _purple,
                iconBg: _purpleLight,
                label: "Total Personnel",
                value: "${_staff.length}",
                sub: "↑ +4 this month",
                subColor: _green),
            const SizedBox(width: 14),
            _staffStatCard(
                icon: Icons.schedule_rounded,
                iconColor: const Color(0xff7C3AED),
                iconBg: const Color(0xffEDE9FE),
                label: "Avg. Shift Duration",
                value: "7.8h",
                sub: "Standard baseline",
                subColor: _textMid),
            const SizedBox(width: 14),
            _staffStatCard(
                icon: Icons.calendar_today_rounded,
                iconColor: _orange,
                iconBg: const Color(0xffFFFBEB),
                label: "On Duty Today",
                value: "${_staff.where((s) => s.status == "In Office").length}",
                sub: "12 pending shifts",
                subColor: _textMid),
          ]),
          const SizedBox(height: 20),
          // Staff grid – fixed height per card, no aspect ratio issues
          LayoutBuilder(builder: (ctx, box) {
            int cols = (box.maxWidth / 170).floor().clamp(3, 6);
            const cardH = 148.0;
            int rows = ((_staff.length + 1) / cols).ceil();
            return SizedBox(
              height: rows * cardH + (rows - 1) * 12,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: cardH,
                ),
                itemCount: _staff.length + 1,
                itemBuilder: (_, i) => i == _staff.length
                    ? _growTeamCard()
                    : _staffCard(_staff[i]),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _staffStatCard(
      {required IconData icon,
      required Color iconColor,
      required Color iconBg,
      required String label,
      required String value,
      required String sub,
      required Color subColor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, color: iconColor, size: 18)),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: _textMid, fontWeight: FontWeight.w500)),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w700, color: _textDark)),
          const SizedBox(height: 3),
          Text(sub, style: TextStyle(fontSize: 11, color: subColor)),
        ]),
      ),
    );
  }

  Widget _staffCard(StaffMember s) {
    Color statusColor;
    switch (s.status) {
      case "In Office":
        statusColor = _green;
        break;
      case "Break":
        statusColor = _orange;
        break;
      case "Remote":
        statusColor = _teal;
        break;
      default:
        statusColor = _textMid;
    }
    return GestureDetector(
      onTap: () => _showStaffDetailModal(s),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Stack(clipBehavior: Clip.none, children: [
            CircleAvatar(
                radius: 22,
                backgroundColor: s.avatarColor,
                child: Text(s.name.split(' ').map((w) => w[0]).take(2).join(),
                    style: const TextStyle(
                        color: _white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12))),
            Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: _white, width: 2)))),
          ]),
          const SizedBox(height: 6),
          Text(s.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 12, color: _textDark)),
          Text(s.role,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: _textMid)),
          const SizedBox(height: 6),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("STATUS",
                  style: TextStyle(
                      fontSize: 6,
                      color: _textMid,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4)),
              Text(s.status,
                  style: TextStyle(
                      fontSize: 6,
                      fontWeight: FontWeight.w600,
                      color: statusColor)),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text("HOURS",
                  style: TextStyle(
                      fontSize: 8,
                      color: _textMid,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4)),
              Text(s.hours,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _textDark)),
            ]),
          ]),
        ]),
      ),
    );
  }

  Widget _growTeamCard() {
    return GestureDetector(
      onTap: () => _mainTab.animateTo(2),
      child: Container(
        decoration: BoxDecoration(
          color: _purpleLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _purple.withOpacity(0.25), width: 1.5),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              width: 40,
              height: 40,
              decoration:
                  const BoxDecoration(color: _white, shape: BoxShape.circle),
              child: const Icon(Icons.person_add_alt_1_rounded,
                  color: _purple, size: 20)),
          const SizedBox(height: 8),
          const Text("Grow the Team",
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 12, color: _purple)),
          const SizedBox(height: 2),
          const Text("Start a new hiring cycle",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Color(0xff7C3AED))),
        ]),
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  ATTENDANCE TAB
  // ═══════════════════════════════════════════

  Widget _attendanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text("Staff Attendance",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _textDark)),
            const Spacer(),
            _circleBtn(Icons.chevron_left),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: const [
              Text("SELECTED DATE",
                  style: TextStyle(
                      fontSize: 10, color: _textMid, letterSpacing: 0.5)),
              Text("Oct 24, 2023",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textDark)),
            ]),
            const SizedBox(width: 8),
            _circleBtn(Icons.chevron_right),
            const SizedBox(width: 6),
            _circleBtn(Icons.calendar_month_outlined),
          ]),
          const SizedBox(height: 18),
          Row(children: [
            _attendStatCard("Present Today", "42", " / 48",
                "● 87% attendance rate", _green),
            const SizedBox(width: 14),
            _attendStatCard(
                "Absent", "04", " Today", "● 2 personal, 2 sick leave", _red),
            const SizedBox(width: 14),
            _attendStatCard("Late Arrivals", "02", " Pending Review",
                "● Average delay: 12m", _orange),
          ]),
          const SizedBox(height: 18),
          LayoutBuilder(builder: (ctx, box) {
            final wide = box.maxWidth > 650;
            if (wide) {
              return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _recentActivity()),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(children: [
                      _calendarCard(),
                      const SizedBox(height: 14),
                      _monthlyOverviewCard()
                    ])),
                  ]);
            }
            return Column(children: [
              _recentActivity(),
              const SizedBox(height: 14),
              _calendarCard(),
              const SizedBox(height: 14),
              _monthlyOverviewCard()
            ]);
          }),
        ],
      ),
    );
  }

  Widget _attendStatCard(
      String label, String value, String suffix, String sub, Color subColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 12, color: _textMid)),
          const SizedBox(height: 6),
          RichText(
              text: TextSpan(children: [
            TextSpan(
                text: value,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: _textDark)),
            TextSpan(
                text: suffix,
                style: const TextStyle(fontSize: 13, color: _textMid)),
          ])),
          const SizedBox(height: 5),
          Text(sub, style: TextStyle(fontSize: 11, color: subColor)),
        ]),
      ),
    );
  }

  Widget _recentActivity() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text("Recent Activity",
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14, color: _textDark)),
          const Spacer(),
          GestureDetector(
            onTap: () => _snack("Showing full log..."),
            child: const Text("View Full Log",
                style: TextStyle(
                    color: _purple, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            Expanded(
                flex: 3,
                child: Text("STAFF MEMBER",
                    style: TextStyle(
                        fontSize: 9,
                        color: _textMid,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5))),
            Expanded(
                flex: 2,
                child: Text("CHECK-IN",
                    style: TextStyle(
                        fontSize: 9,
                        color: _textMid,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5))),
            Expanded(
                flex: 2,
                child: Text("STATUS",
                    style: TextStyle(
                        fontSize: 9,
                        color: _textMid,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5))),
            SizedBox(width: 30),
          ]),
        ),
        const Divider(color: _border, height: 1),
        ..._attendance.map(_activityRow),
      ]),
    );
  }

  Widget _activityRow(AttendanceRecord r) {
    Color statusBg, statusFg;
    switch (r.locationStatus) {
      case "ON-SITE":
        statusBg = const Color(0xffDCFCE7);
        statusFg = _green;
        break;
      case "LATE":
        statusBg = const Color(0xffFEF3C7);
        statusFg = _orange;
        break;
      case "ABSENT":
        statusBg = const Color(0xffFEE2E2);
        statusFg = _red;
        break;
      default:
        statusBg = const Color(0xffE0F2FE);
        statusFg = _teal;
    }
    final arrivalColor = r.arrivalNote.contains("Late")
        ? _orange
        : (r.arrivalNote == "No Entry" ? _red : _green);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Expanded(
            flex: 3,
            child: Row(children: [
              CircleAvatar(
                  radius: 15,
                  backgroundColor: r.avatarColor,
                  child: Text(r.initials,
                      style: const TextStyle(
                          color: _white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700))),
              const SizedBox(width: 8),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(r.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: _textDark),
                        overflow: TextOverflow.ellipsis),
                    Text(r.role,
                        style: const TextStyle(fontSize: 10, color: _textMid),
                        overflow: TextOverflow.ellipsis),
                  ])),
            ])),
        Expanded(
            flex: 2,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.checkIn,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textDark)),
              Text(r.arrivalNote,
                  style: TextStyle(fontSize: 10, color: arrivalColor)),
            ])),
        Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: statusBg, borderRadius: BorderRadius.circular(6)),
              child: Text(r.locationStatus,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusFg)),
            )),
        SizedBox(
            width: 30,
            child: IconButton(
              icon: const Icon(Icons.more_vert, size: 15, color: _textMid),
              onPressed: () => _snack("Options for ${r.name}"),
              padding: EdgeInsets.zero,
            )),
      ]),
    );
  }

  Widget _calendarCard() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border)),
      child: TableCalendar(
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          leftChevronIcon: Icon(Icons.chevron_left, size: 18, color: _textMid),
          rightChevronIcon:
              Icon(Icons.chevron_right, size: 18, color: _textMid),
          headerPadding: EdgeInsets.symmetric(vertical: 8),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
              fontSize: 11, color: _textMid, fontWeight: FontWeight.w600),
          weekendStyle: TextStyle(
              fontSize: 11, color: _textMid, fontWeight: FontWeight.w600),
        ),
        calendarStyle: CalendarStyle(
          cellMargin: const EdgeInsets.all(2),
          defaultTextStyle: const TextStyle(fontSize: 12, color: _textDark),
          weekendTextStyle: const TextStyle(fontSize: 12, color: _textMid),
          outsideTextStyle: TextStyle(fontSize: 12, color: _border),
          todayDecoration:
              const BoxDecoration(color: _purple, shape: BoxShape.circle),
          todayTextStyle: const TextStyle(
              fontSize: 12, color: _white, fontWeight: FontWeight.w700),
          selectedDecoration: BoxDecoration(
              color: _purple.withOpacity(0.5), shape: BoxShape.circle),
          selectedTextStyle: const TextStyle(fontSize: 12, color: _white),
        ),
        rowHeight: 36,
        focusedDay: DateTime(2023, 10, 24),
        firstDay: DateTime(2020),
        lastDay: DateTime(2030),
        selectedDayPredicate: (d) => isSameDay(d, DateTime(2023, 10, 24)),
        onDaySelected: (selected, _) => _snack(
            "Selected: ${selected.day} ${_monthName(selected.month)} ${selected.year}"),
      ),
    );
  }

  Widget _monthlyOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xff5B21B6), Color(0xff7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Monthly Overview",
            style: TextStyle(
                color: _white, fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 12),
        _overviewRow("Avg. Attendance", "92.4%"),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
              value: 0.924,
              minHeight: 5,
              backgroundColor: _white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(_white)),
        ),
        const SizedBox(height: 10),
        _overviewRow("Total Overtime", "148h"),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _white),
              foregroundColor: _white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 9),
            ),
            onPressed: () => _snack("Downloading monthly report..."),
            child: const Text("Download Monthly Report",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }

  Widget _overviewRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: _white.withOpacity(0.8), fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  color: _white, fontWeight: FontWeight.w700, fontSize: 14)),
        ],
      );

  // ═══════════════════════════════════════════
  //  HIRING TAB
  // ═══════════════════════════════════════════

  Widget _hiringMainTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
          child: Row(children: [
            const Text("Staff Hiring",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _textDark)),
            const Spacer(),
            _purpleBtn("+ Add Position", _showAddPositionModal),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TabBar(
            controller: _hiringSubTab,
            labelColor: _purple,
            unselectedLabelColor: _textMid,
            indicatorColor: _purple,
            indicatorWeight: 2.5,
            isScrollable: true,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            tabs: const [Tab(text: "Job Positions"), Tab(text: "Applications")],
          ),
        ),
        const Divider(height: 1, color: _border),
        Expanded(
          child: TabBarView(
            controller: _hiringSubTab,
            children: [_jobPositionsView(), _applicationsView()],
          ),
        ),
      ],
    );
  }

  Widget _payrollTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 HEADER
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 10),
          child: Row(
            children: [
              const Text(
                "Staff Payroll",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showAddPositionModal,
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Add Payroll"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 🔹 SUMMARY CARDS (NEW)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _summaryCard("Total", "₹1,20,000", Colors.blue),
              _summaryCard("Paid", "₹80,000", Colors.green),
              _summaryCard("Pending", "₹40,000", Colors.orange),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 🔹 IMPROVED TAB BAR
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _hiringSubTab,
              indicator: BoxDecoration(
                color: _purple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: _purple,
              unselectedLabelColor: _textMid,
              tabs: const [
                Tab(text: "Payroll"),
                Tab(text: "History"),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // 🔹 CONTENT
        Expanded(
          child: TabBarView(
            controller: _hiringSubTab,
            children: [
              _modernPayrollList(), // 👈 updated list
              _applicationsView(), // keep your old one if needed
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String amount, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 6),
            Text(amount,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _modernPayrollList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _purple.withOpacity(0.1),
                child: Icon(Icons.person, color: _purple),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("John Doe",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text("UI Developer",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text("₹25,000",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 4),
                  Text("Pending",
                      style: TextStyle(fontSize: 12, color: Colors.orange)),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _jobPositionsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Active Roles",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textDark)),
                  Text("Manage and monitor your current recruitment pipelines.",
                      style: TextStyle(fontSize: 12, color: _textMid)),
                ]),
            const Spacer(),
            _outlineBtn(Icons.filter_list, "Filter",
                () => _snack("Filter coming soon")),
            const SizedBox(width: 8),
            _outlineBtn(Icons.sort, "Sort", () => _snack("Sort coming soon")),
          ]),
          const SizedBox(height: 18),
          LayoutBuilder(builder: (ctx, box) {
            int cols = (box.maxWidth / 260).floor().clamp(2, 4);
            const cardH = 210.0;
            int rows = ((_jobs.length + 1) / cols).ceil();
            return SizedBox(
              height: rows * cardH + (rows - 1) * 14,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: cardH,
                ),
                itemCount: _jobs.length + 1,
                itemBuilder: (_, i) => i == _jobs.length
                    ? _createPositionCard()
                    : _jobCard(_jobs[i]),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _jobCard(JobPosition job) {
    final isActive = job.status == "ACTIVE";
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: job.iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(job.icon,
                  color: isActive ? _purple : _textMid, size: 19)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xffDCFCE7)
                    : const Color(0xffF3F4F6),
                borderRadius: BorderRadius.circular(6)),
            child: Text(job.status,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isActive ? _green : _textMid)),
          ),
        ]),
        const SizedBox(height: 10),
        Text(job.title,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14, color: _textDark)),
        Text(job.department,
            style: const TextStyle(fontSize: 11, color: _textMid)),
        const Spacer(),
        Row(children: [
          _jobStat("APPLICATIONS", "${job.applications}"),
          const SizedBox(width: 14),
          Expanded(child: _jobStat("POSTED", job.postedDate)),
        ]),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(
              width: 52,
              height: 20,
              child: Stack(
                  children: List.generate(3, (i) {
                final colors = [
                  const Color(0xff4F86C6),
                  const Color(0xff5BA85C),
                  const Color(0xff7B5EA7)
                ];
                return Positioned(
                    left: i * 13.0,
                    child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors[i],
                            border: Border.all(color: _white, width: 2))));
              }))),
          GestureDetector(
            onTap: () => _showJobDetailModal(job),
            child: Row(children: [
              Text("View",
                  style: TextStyle(
                      color: isActive ? _purple : _textMid,
                      fontWeight: FontWeight.w600,
                      fontSize: 12)),
              Icon(Icons.chevron_right,
                  size: 14, color: isActive ? _purple : _textMid),
            ]),
          ),
        ]),
      ]),
    );
  }

  Widget _jobStat(String label, String value) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontSize: 9,
                color: _textMid,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4)),
        Text(value,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
      ]);

  Widget _createPositionCard() {
    return GestureDetector(
      onTap: _showAddPositionModal,
      child: Container(
        decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border, width: 1.5)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: _purpleLight, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.add, color: _purple, size: 20)),
          const SizedBox(height: 10),
          const Text("Create New Position",
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13, color: _textDark)),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text("Define a new role and start receiving applications.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: _textMid)),
          ),
        ]),
      ),
    );
  }

  Widget _applicationsView() {
    final filters = ["All", "Pending (12)", "Reviewing (5)", "Shortlisted (8)"];
    final filtered = _appFilter == 0
        ? _candidates
        : _candidates.where((c) {
            if (_appFilter == 1) return c.status == "Pending";
            if (_appFilter == 2) return c.status == "Reviewing";
            return c.status == "Shortlisted";
          }).toList();

    return StatefulBuilder(builder: (ctx, setS) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Review Candidates",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textDark)),
                  Text("Manage and schedule interviews for open positions.",
                      style: TextStyle(fontSize: 12, color: _textMid)),
                ]),
            const Spacer(),
            _outlineBtn(Icons.filter_alt_outlined, "Advanced Filter",
                () => _snack("Advanced filter coming soon")),
            const SizedBox(width: 8),
            _purpleBtn(
                "↑ Export List", () => _snack("Exporting candidate list...")),
          ]),
          const SizedBox(height: 14),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(filters.length, (i) {
                final active = _appFilter == i;
                return GestureDetector(
                  onTap: () => setState(() => _appFilter = i),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: active ? _purple : _white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: active ? _purple : _border),
                    ),
                    child: Text(filters[i],
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: active ? _white : _textMid)),
                  ),
                );
              })),
          const SizedBox(height: 12),
          ...filtered.map((c) => _candidateCard(c)),
        ]),
      );
    });
  }

  Widget _candidateCard(Candidate c) {
    Color statusColor, statusBg;
    switch (c.status) {
      case "Reviewing":
        statusColor = _orange;
        statusBg = const Color(0xffFEF3C7);
        break;
      case "Shortlisted":
        statusColor = _purple;
        statusBg = _purpleLight;
        break;
      default:
        statusColor = _textMid;
        statusBg = const Color(0xffF3F4F6);
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border)),
      child: Row(children: [
        CircleAvatar(
            radius: 20,
            backgroundColor: c.avatarColor,
            child: Text(c.name.split(' ').map((w) => w[0]).take(2).join(),
                style: const TextStyle(
                    color: _white, fontWeight: FontWeight.w700, fontSize: 11))),
        const SizedBox(width: 12),
        Expanded(
            flex: 3,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: _textDark)),
              Row(children: [
                const Icon(Icons.email_outlined, size: 10, color: _textMid),
                const SizedBox(width: 2),
                Flexible(
                    child: Text(c.email,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: _textMid))),
              ]),
              Row(children: [
                const Icon(Icons.phone_outlined, size: 10, color: _textMid),
                const SizedBox(width: 2),
                Flexible(
                    child: Text(c.phone,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: _textMid))),
              ]),
            ])),
        Expanded(
            flex: 2,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("EXPERIENCE",
                  style: TextStyle(
                      fontSize: 9,
                      color: _textMid,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4)),
              Text("${c.experience} Years",
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: _textDark)),
            ])),
        Expanded(
            flex: 2,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("CURRENT COMPANY",
                  style: TextStyle(
                      fontSize: 9,
                      color: _textMid,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4)),
              Text(c.company,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: _textDark)),
            ])),
        Expanded(
            flex: 2,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("STATUS",
                  style: TextStyle(
                      fontSize: 9,
                      color: _textMid,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4)),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: statusBg, borderRadius: BorderRadius.circular(20)),
                child: Text(c.status,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor)),
              ),
            ])),
        Row(mainAxisSize: MainAxisSize.min, children: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _border),
              foregroundColor: _textDark,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => _showCandidateModal(c, "review"),
            child: const Text("Review",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 6),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => _showCandidateModal(c, "schedule"),
            child: const Text("Schedule",
                style: TextStyle(
                    color: _white, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ]),
      ]),
    );
  }
}
