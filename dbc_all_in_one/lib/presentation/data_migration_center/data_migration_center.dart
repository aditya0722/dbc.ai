import 'package:flutter/material.dart';
import '../../widgets/dbc_back_button.dart';
import 'package:sizer/sizer.dart';

import '../../services/data_migration_service.dart';
import './widgets/migration_project_card_widget.dart';
import './widgets/source_selector_widget.dart';

class DataMigrationCenter extends StatefulWidget {
  const DataMigrationCenter({super.key});

  @override
  State<DataMigrationCenter> createState() => _DataMigrationCenterState();
}

class _DataMigrationCenterState extends State<DataMigrationCenter> {
  final DataMigrationService _migrationService = DataMigrationService();
  List<Map<String, dynamic>> _migrationProjects = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadMigrationProjects();
  }

  Future<void> _loadMigrationProjects() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final projects = await _migrationService.getMigrationProjects();
      setState(() {
        _migrationProjects = projects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredProjects {
    if (_selectedFilter == 'all') return _migrationProjects;
    return _migrationProjects
        .where((p) => p['status'] == _selectedFilter)
        .toList();
  }

  void _showCreateMigrationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New Migration Project',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Project Name',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
            SizedBox(height: 2.h),
            SourceSelectorWidget(
              onSourceSelected: (sourceType) {
                Navigator.pop(context);
                _createNewProject(sourceType);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createNewProject(String sourceType) async {
    try {
      await _migrationService.createMigrationProject(
        projectName: '$sourceType Import ${DateTime.now().year}',
        sourceType: sourceType,
        targetModules: ['invoices', 'customers', 'products'],
      );
      _loadMigrationProjects();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Migration project created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: DBCBackButton(
          onPressed: () => Navigator.maybePop(context),
          iconColor: Colors.black87,
          backgroundColor: Colors.white,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data Migration Center',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            Text('Import data from other ERP platforms',
                style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 2.h),
                      Text(_error!,
                          style: TextStyle(fontSize: 12.sp),
                          textAlign: TextAlign.center),
                      SizedBox(height: 2.h),
                      ElevatedButton(
                        onPressed: _loadMigrationProjects,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMigrationProjects,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(3.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Quick Actions',
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: 2.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: _QuickActionButton(
                                      icon: Icons.add_circle_outline,
                                      label: 'New Migration',
                                      color: const Color(0xFF2196F3),
                                      onTap: _showCreateMigrationDialog,
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: _QuickActionButton(
                                      icon: Icons.folder_outlined,
                                      label: 'Templates',
                                      color: const Color(0xFF9C27B0),
                                      onTap: () {},
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: _QuickActionButton(
                                      icon: Icons.history,
                                      label: 'History',
                                      color: const Color(0xFFFF9800),
                                      onTap: () {},
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 2.h)),
                      SliverToBoxAdapter(
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(3.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Migration Projects',
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600)),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 2.w, vertical: 0.5.h),
                                    decoration: BoxDecoration(
                                      color:
                                          const Color(0xFF2196F3).withAlpha(26),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Text(
                                        '${_migrationProjects.length} total',
                                        style: TextStyle(
                                            fontSize: 10.sp,
                                            color: const Color(0xFF2196F3),
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _FilterChip(
                                      label: 'All',
                                      isSelected: _selectedFilter == 'all',
                                      onTap: () => setState(
                                          () => _selectedFilter = 'all'),
                                    ),
                                    SizedBox(width: 2.w),
                                    _FilterChip(
                                      label: 'Draft',
                                      isSelected: _selectedFilter == 'draft',
                                      onTap: () => setState(
                                          () => _selectedFilter = 'draft'),
                                    ),
                                    SizedBox(width: 2.w),
                                    _FilterChip(
                                      label: 'Validating',
                                      isSelected:
                                          _selectedFilter == 'validating',
                                      onTap: () => setState(
                                          () => _selectedFilter = 'validating'),
                                    ),
                                    SizedBox(width: 2.w),
                                    _FilterChip(
                                      label: 'Importing',
                                      isSelected:
                                          _selectedFilter == 'importing',
                                      onTap: () => setState(
                                          () => _selectedFilter = 'importing'),
                                    ),
                                    SizedBox(width: 2.w),
                                    _FilterChip(
                                      label: 'Completed',
                                      isSelected:
                                          _selectedFilter == 'completed',
                                      onTap: () => setState(
                                          () => _selectedFilter = 'completed'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 1.h)),
                      _filteredProjects.isEmpty
                          ? SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.folder_open,
                                        size: 64, color: Colors.grey.shade300),
                                    SizedBox(height: 2.h),
                                    Text('No migration projects found',
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey)),
                                    SizedBox(height: 1.h),
                                    ElevatedButton.icon(
                                      onPressed: _showCreateMigrationDialog,
                                      icon: const Icon(Icons.add),
                                      label: const Text('Create New Migration'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF2196F3),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SliverPadding(
                              padding: EdgeInsets.symmetric(horizontal: 3.w),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final project = _filteredProjects[index];
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 2.h),
                                      child: MigrationProjectCardWidget(
                                        project: project,
                                        onTap: () {},
                                        onRefresh: _loadMigrationProjects,
                                      ),
                                    );
                                  },
                                  childCount: _filteredProjects.length,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: color.withAlpha(77)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 0.5.h),
            Text(label,
                style: TextStyle(
                    fontSize: 10.sp,
                    color: color,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color:
              isSelected ? const Color(0xFF2196F3) : Colors.grey.withAlpha(26),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11.sp,
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w500)),
      ),
    );
  }
}
