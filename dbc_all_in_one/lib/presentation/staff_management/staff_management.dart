import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/add_staff_button_widget.dart';
import './widgets/department_chip_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/staff_card_widget.dart';

class StaffManagement extends StatefulWidget {
  const StaffManagement({super.key});

  @override
  State<StaffManagement> createState() => _StaffManagementState();
}

class _StaffManagementState extends State<StaffManagement>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomNavIndex = 3; // Staff tab
  String _selectedDepartment = 'All';
  String _searchQuery = '';
  bool _isRefreshing = false;
  Set<String> _selectedStaffIds = {};
  bool _isMultiSelectMode = false;

  final List<String> _departments = [
    'All',
    'Front',
    'Kitchen',
    'Rooms',
    'Floor',
    'Production',
    'Gym'
  ];

  final List<Map<String, dynamic>> _staffMembers = [
    {
      "id": "staff_001",
      "name": "Sarah Johnson",
      "role": "Cashier",
      "department": "Front",
      "profilePhoto":
          "https://img.rocket.new/generatedImages/rocket_gen_img_15df005a3-1763295646280.png",
      "semanticLabel":
          "Professional headshot of a woman with shoulder-length brown hair wearing a white blouse",
      "status": "checked-in",
      "checkInTime": "08:30 AM",
      "hoursWorked": "3.5",
      "wageType": "hourly",
      "hourlyRate": "\$15.00",
      "phone": "+1 555-0101",
      "email": "sarah.j@business.com"
    },
    {
      "id": "staff_002",
      "name": "Michael Chen",
      "role": "Cook",
      "department": "Kitchen",
      "profilePhoto":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1bf46143f-1763295306481.png",
      "semanticLabel":
          "Professional headshot of an Asian man with short black hair wearing a chef's uniform",
      "status": "checked-out",
      "checkInTime": "07:00 AM",
      "checkOutTime": "03:00 PM",
      "hoursWorked": "8.0",
      "wageType": "daily",
      "dailyRate": "\$120.00",
      "phone": "+1 555-0102",
      "email": "michael.c@business.com"
    },
    {
      "id": "staff_003",
      "name": "Emily Rodriguez",
      "role": "Waiter",
      "department": "Front",
      "profilePhoto":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1555e1b4e-1763297995460.png",
      "semanticLabel":
          "Professional headshot of a Hispanic woman with long dark hair wearing a black uniform",
      "status": "checked-in",
      "checkInTime": "09:00 AM",
      "hoursWorked": "3.0",
      "wageType": "hourly",
      "hourlyRate": "\$12.00",
      "phone": "+1 555-0103",
      "email": "emily.r@business.com"
    },
    {
      "id": "staff_004",
      "name": "James Wilson",
      "role": "Cleaner",
      "department": "Rooms",
      "profilePhoto":
          "https://img.rocket.new/generatedImages/rocket_gen_img_187ac2848-1764684680250.png",
      "semanticLabel":
          "Professional headshot of a man with gray hair wearing a blue work shirt",
      "status": "checked-in",
      "checkInTime": "06:00 AM",
      "hoursWorked": "6.0",
      "wageType": "daily",
      "dailyRate": "\$100.00",
      "phone": "+1 555-0104",
      "email": "james.w@business.com"
    },
    {
      "id": "staff_005",
      "name": "Priya Patel",
      "role": "Trainer",
      "department": "Gym",
      "profilePhoto":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1e94201ef-1763296134446.png",
      "semanticLabel":
          "Professional headshot of an Indian woman with long black hair wearing athletic wear",
      "status": "checked-out",
      "checkInTime": "05:00 AM",
      "checkOutTime": "01:00 PM",
      "hoursWorked": "8.0",
      "wageType": "hourly",
      "hourlyRate": "\$25.00",
      "phone": "+1 555-0105",
      "email": "priya.p@business.com"
    },
    {
      "id": "staff_006",
      "name": "David Martinez",
      "role": "Worker",
      "department": "Production",
      "profilePhoto":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1d29504f2-1763294463041.png",
      "semanticLabel":
          "Professional headshot of a Hispanic man with short dark hair wearing a safety vest",
      "status": "checked-in",
      "checkInTime": "07:30 AM",
      "hoursWorked": "4.5",
      "wageType": "piece-rate",
      "pieceRate": "\$5.00/unit",
      "unitsCompleted": "45",
      "phone": "+1 555-0106",
      "email": "david.m@business.com"
    },
    {
      "id": "staff_007",
      "name": "Lisa Anderson",
      "role": "Guard",
      "department": "Floor",
      "profilePhoto":
          "https://img.rocket.new/generatedImages/rocket_gen_img_158342851-1763297924538.png",
      "semanticLabel":
          "Professional headshot of a woman with short blonde hair wearing a security uniform",
      "status": "checked-in",
      "checkInTime": "10:00 PM",
      "hoursWorked": "2.0",
      "wageType": "hourly",
      "hourlyRate": "\$18.00",
      "phone": "+1 555-0107",
      "email": "lisa.a@business.com"
    },
    {
      "id": "staff_008",
      "name": "Robert Kim",
      "role": "Cook",
      "department": "Kitchen",
      "profilePhoto":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1bf46143f-1763295306481.png",
      "semanticLabel":
          "Professional headshot of an Asian man with glasses wearing a white chef's coat",
      "status": "checked-out",
      "checkInTime": "11:00 AM",
      "checkOutTime": "07:00 PM",
      "hoursWorked": "8.0",
      "wageType": "daily",
      "dailyRate": "\$130.00",
      "phone": "+1 555-0108",
      "email": "robert.k@business.com"
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredStaffMembers {
    return _staffMembers.where((staff) {
      final matchesDepartment = _selectedDepartment == 'All' ||
          (staff['department'] as String) == _selectedDepartment;
      final matchesSearch = _searchQuery.isEmpty ||
          (staff['name'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (staff['role'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchesDepartment && matchesSearch;
    }).toList();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Staff data synced successfully'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        onApplyFilters: (filters) {
          setState(() {
            if (filters['department'] != null) {
              _selectedDepartment = filters['department'] as String;
            }
          });
        },
      ),
    );
  }

  void _toggleStaffSelection(String staffId) {
    setState(() {
      if (_selectedStaffIds.contains(staffId)) {
        _selectedStaffIds.remove(staffId);
        if (_selectedStaffIds.isEmpty) {
          _isMultiSelectMode = false;
        }
      } else {
        _selectedStaffIds.add(staffId);
        _isMultiSelectMode = true;
      }
    });
  }

  void _handleStaffCardTap(Map<String, dynamic> staff) {
    if (_isMultiSelectMode) {
      _toggleStaffSelection(staff['id'] as String);
    } else {
      _navigateToStaffProfile(staff);
    }
  }

  void _handleStaffCardLongPress(String staffId) {
    _toggleStaffSelection(staffId);
  }

  void _navigateToStaffProfile(Map<String, dynamic> staff) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening profile for ${staff['name']}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleMarkAttendance(Map<String, dynamic> staff) {
    final isCheckedIn = staff['status'] == 'checked-in';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCheckedIn
            ? 'Checking out ${staff['name']}...'
            : 'Checking in ${staff['name']}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleViewTimesheet(Map<String, dynamic> staff) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening timesheet for ${staff['name']}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleCalculatePay(Map<String, dynamic> staff) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calculating pay for ${staff['name']}...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleSendMessage(Map<String, dynamic> staff) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening message to ${staff['name']}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleAddStaff() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening staff registration form...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleBulkAttendance() {
    if (_selectedStaffIds.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Marking attendance for ${_selectedStaffIds.length} staff members...'),
        duration: const Duration(seconds: 2),
      ),
    );

    setState(() {
      _selectedStaffIds.clear();
      _isMultiSelectMode = false;
    });
  }

  void _navigateToStaffHiring() {
    Navigator.pushNamed(context, AppRoutes.staffHiring);
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Staff Management',
        variant: CustomAppBarVariant.standard,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _showFilterBottomSheet,
            tooltip: 'Filter staff',
          ),
          if (_isMultiSelectMode)
            IconButton(
              icon: CustomIconWidget(
                iconName: 'check_circle',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              onPressed: _handleBulkAttendance,
              tooltip: 'Mark bulk attendance',
            ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: theme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              indicatorColor: theme.colorScheme.primary,
              tabs: const [
                Tab(text: 'Staff'),
                Tab(text: 'Attendance'),
                Tab(text: 'Hiring'),
              ],
            ),
          ),

          // Search Bar
          Container(
            padding: EdgeInsets.all(4.w),
            color: theme.colorScheme.surface,
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search by name or role...',
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // Department Chips
          Container(
            height: 8.h,
            color: theme.colorScheme.surface,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              itemCount: _departments.length,
              separatorBuilder: (context, index) => SizedBox(width: 2.w),
              itemBuilder: (context, index) {
                return DepartmentChipWidget(
                  label: _departments[index],
                  isSelected: _selectedDepartment == _departments[index],
                  onTap: () =>
                      setState(() => _selectedDepartment = _departments[index]),
                );
              },
            ),
          ),

          // Staff List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Staff Tab
                RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: _filteredStaffMembers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'people_outline',
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 64,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'No staff members found',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Try adjusting your filters',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.all(4.w),
                          itemCount: _filteredStaffMembers.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 2.h),
                          itemBuilder: (context, index) {
                            final staff = _filteredStaffMembers[index];
                            return StaffCardWidget(
                              staff: staff,
                              isSelected:
                                  _selectedStaffIds.contains(staff['id']),
                              onTap: () => _handleStaffCardTap(staff),
                              onLongPress: () => _handleStaffCardLongPress(
                                  staff['id'] as String),
                              onMarkAttendance: () =>
                                  _handleMarkAttendance(staff),
                              onViewTimesheet: () =>
                                  _handleViewTimesheet(staff),
                              onCalculatePay: () => _handleCalculatePay(staff),
                              onSendMessage: () => _handleSendMessage(staff),
                            );
                          },
                        ),
                ),

                // Attendance Tab
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'calendar_today',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 64,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Attendance View',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Coming soon',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Hiring Tab
                Container(
                  color: theme.colorScheme.surface,
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 2.h),
                      Text(
                        'Staff Hiring & Recruitment',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Manage job positions and review applications',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 4.h),

                      // Quick Stats Cards
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'work',
                                    color: theme.colorScheme.primary,
                                    size: 32,
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    'Active',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  Text(
                                    'Positions',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'assignment',
                                    color: theme.colorScheme.secondary,
                                    size: 32,
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    'Pending',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme
                                          .colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                  Text(
                                    'Applications',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme
                                          .colorScheme.onSecondaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      // Main Action Button
                      ElevatedButton(
                        onPressed: _navigateToStaffHiring,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'person_search',
                              color: theme.colorScheme.onPrimary,
                              size: 24,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'View Jobs & Applications',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 2.h),

                      // Secondary Action Buttons
                      OutlinedButton(
                        onPressed: _navigateToStaffHiring,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          side: BorderSide(color: theme.colorScheme.primary),
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'add_circle_outline',
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Post New Job',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 4.h),

                      // Quick Info Section
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'info_outline',
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Text(
                                'Manage job postings, review candidate applications, and schedule interviews all in one place',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AddStaffButtonWidget(
        onPressed: _handleAddStaff,
      ),
    );
  }
}
