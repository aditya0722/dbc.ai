import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/hiring_service.dart';
import './widgets/add_position_dialog_widget.dart';
import './widgets/application_status_chip_widget.dart';
import './widgets/job_position_card_widget.dart';

class StaffHiringScreen extends StatefulWidget {
  const StaffHiringScreen({Key? key}) : super(key: key);

  @override
  State<StaffHiringScreen> createState() => _StaffHiringScreenState();
}

class _StaffHiringScreenState extends State<StaffHiringScreen>
    with SingleTickerProviderStateMixin {
  final HiringService _hiringService = HiringService();
  late TabController _tabController;

  List<Map<String, dynamic>> _jobPositions = [];
  List<Map<String, dynamic>> _allApplications = [];
  List<Map<String, dynamic>> _filteredApplications = [];
  Map<String, int> _statusCounts = {};
  bool _isLoading = true;
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final positions = await _hiringService.getActiveJobPositions();
      final applications =
          await _hiringService.getApplicationsByStatus('pending');
      final counts = await _hiringService.getApplicationStatusCounts();

      setState(() {
        _jobPositions = positions;
        _allApplications = applications;
        _filteredApplications = applications;
        _statusCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  void _filterApplicationsByStatus(String status) {
    setState(() {
      _selectedStatus = status;
      if (status == 'all') {
        _filteredApplications = _allApplications;
      } else {
        _filteredApplications =
            _allApplications.where((app) => app['status'] == status).toList();
      }
    });
  }

  void _showAddPositionDialog() {
    showDialog(
      context: context,
      builder: (context) => AddPositionDialogWidget(
        onPositionAdded: () {
          _loadData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Staff Hiring',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Job Positions'),
            Tab(text: 'Applications'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildJobPositionsTab(),
                _buildApplicationsTab(),
              ],
            ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _showAddPositionDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Position'),
              backgroundColor: Theme.of(context).primaryColor,
            )
          : null,
    );
  }

  Widget _buildJobPositionsTab() {
    if (_jobPositions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 80.sp, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              'No active positions',
              style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 8.h),
            Text(
              'Create a new job position to start hiring',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _jobPositions.length,
        itemBuilder: (context, index) {
          return JobPositionCardWidget(
            position: _jobPositions[index],
            onTap: () {
              // Navigate to position details
            },
          );
        },
      ),
    );
  }

  Widget _buildApplicationsTab() {
    return Column(
      children: [
        _buildStatusFilters(),
        Expanded(
          child: _filteredApplications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 80.sp, color: Colors.grey[400]),
                      SizedBox(height: 16.h),
                      Text(
                        'No applications found',
                        style:
                            TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _filteredApplications.length,
                    itemBuilder: (context, index) {
                      final application = _filteredApplications[index];
                      return _buildApplicationCard(application);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStatusFilters() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
                'All', 'all', (_statusCounts.values.fold(0, (a, b) => a + b))),
            SizedBox(width: 8.w),
            _buildFilterChip(
                'Pending', 'pending', _statusCounts['pending'] ?? 0),
            SizedBox(width: 8.w),
            _buildFilterChip(
                'Reviewing', 'reviewing', _statusCounts['reviewing'] ?? 0),
            SizedBox(width: 8.w),
            _buildFilterChip('Shortlisted', 'shortlisted',
                _statusCounts['shortlisted'] ?? 0),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String status, int count) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) _filterApplicationsByStatus(status);
      },
      backgroundColor: Colors.grey[100],
      selectedColor: Theme.of(context).primaryColor.withAlpha(51),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to application details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      application['candidate_name'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ApplicationStatusChipWidget(
                    status: application['status'] ?? 'pending',
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.email_outlined,
                      size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Text(
                    application['candidate_email'] ?? '',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(Icons.phone_outlined,
                      size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Text(
                    application['candidate_phone'] ?? '',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.business_center_outlined,
                      size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Text(
                    '${application['years_of_experience'] ?? 0} years experience',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                  ),
                  if (application['current_company'] != null) ...[
                    Text(' • ', style: TextStyle(color: Colors.grey[400])),
                    Text(
                      application['current_company'],
                      style:
                          TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      await _hiringService.updateApplicationStatus(
                        application['id'],
                        'reviewing',
                      );
                      _loadData();
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Review'),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Schedule interview
                    },
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: const Text('Schedule'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
