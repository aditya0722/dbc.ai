import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/candidate_card_widget.dart';
import './widgets/role_filter_chip_widget.dart';

class HiringMarketplace extends StatefulWidget {
  const HiringMarketplace({super.key});

  @override
  State<HiringMarketplace> createState() => _HiringMarketplaceState();
}

class _HiringMarketplaceState extends State<HiringMarketplace> {
  int _currentBottomNavIndex = 3;
  String _selectedRole = 'All';
  bool _isRefreshing = false;
  bool _isComparisonMode = false;
  final Set<int> _selectedCandidates = {};
  final TextEditingController _searchController = TextEditingController();

  final List<String> _roles = [
    'All',
    'Cashier',
    'Waiter',
    'Cook',
    'Cleaner',
    'Trainer',
    'Worker',
    'Guard'
  ];

  final List<Map<String, dynamic>> _candidates = [
    {
      "id": 1,
      "name": "Sarah Johnson",
      "role": "Cashier",
      "experience": "3 years",
      "rating": 4.8,
      "availability": "Immediate",
      "distance": "2.3 km",
      "photo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_15df005a3-1763295646280.png",
      "semanticLabel":
          "Professional headshot of a woman with shoulder-length brown hair wearing a white blouse",
      "skills": ["POS Systems", "Customer Service", "Cash Handling"],
      "salary": "\$15-18/hr",
      "backgroundCheck": true,
      "languages": ["English", "Spanish"],
      "transportation": true,
      "isFavorite": false
    },
    {
      "id": 2,
      "name": "Michael Chen",
      "role": "Cook",
      "experience": "5 years",
      "rating": 4.9,
      "availability": "Part-time",
      "distance": "1.8 km",
      "photo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1bf46143f-1763295306481.png",
      "semanticLabel":
          "Professional headshot of an Asian man with short black hair wearing a chef's uniform",
      "skills": ["Italian Cuisine", "Food Safety", "Menu Planning"],
      "salary": "\$20-25/hr",
      "backgroundCheck": true,
      "languages": ["English", "Mandarin"],
      "transportation": true,
      "isFavorite": false
    },
    {
      "id": 3,
      "name": "Emily Rodriguez",
      "role": "Waiter",
      "experience": "2 years",
      "rating": 4.7,
      "availability": "Full-time",
      "distance": "3.5 km",
      "photo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1555e1b4e-1763297995460.png",
      "semanticLabel":
          "Professional headshot of a Hispanic woman with long dark hair wearing a black uniform",
      "skills": ["Table Service", "Wine Knowledge", "Customer Relations"],
      "salary": "\$12-15/hr + tips",
      "backgroundCheck": true,
      "languages": ["English", "Spanish"],
      "transportation": false,
      "isFavorite": true
    },
    {
      "id": 4,
      "name": "David Thompson",
      "role": "Guard",
      "experience": "7 years",
      "rating": 4.9,
      "availability": "Immediate",
      "distance": "4.2 km",
      "photo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_178500a10-1763292673956.png",
      "semanticLabel":
          "Professional headshot of a man with short gray hair wearing a security uniform",
      "skills": ["Security Systems", "First Aid", "Conflict Resolution"],
      "salary": "\$18-22/hr",
      "backgroundCheck": true,
      "languages": ["English"],
      "transportation": true,
      "isFavorite": false
    },
    {
      "id": 5,
      "name": "Jessica Williams",
      "role": "Trainer",
      "experience": "4 years",
      "rating": 4.8,
      "availability": "Part-time",
      "distance": "2.9 km",
      "photo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_112fb449f-1763299843776.png",
      "semanticLabel":
          "Professional headshot of a woman with blonde hair in a ponytail wearing athletic wear",
      "skills": ["Personal Training", "Nutrition", "Group Classes"],
      "salary": "\$25-30/hr",
      "backgroundCheck": true,
      "languages": ["English"],
      "transportation": true,
      "isFavorite": false
    },
    {
      "id": 6,
      "name": "Robert Martinez",
      "role": "Cleaner",
      "experience": "3 years",
      "rating": 4.6,
      "availability": "Full-time",
      "distance": "1.5 km",
      "photo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_16105ed6d-1763296582884.png",
      "semanticLabel":
          "Professional headshot of a Hispanic man with short dark hair wearing a blue work uniform",
      "skills": ["Deep Cleaning", "Equipment Operation", "Safety Protocols"],
      "salary": "\$14-16/hr",
      "backgroundCheck": true,
      "languages": ["English", "Spanish"],
      "transportation": true,
      "isFavorite": false
    },
    {
      "id": 7,
      "name": "Amanda Lee",
      "role": "Cashier",
      "experience": "1 year",
      "rating": 4.5,
      "availability": "Immediate",
      "distance": "3.8 km",
      "photo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_10c9f2490-1763293752822.png",
      "semanticLabel":
          "Professional headshot of an Asian woman with long black hair wearing a retail uniform",
      "skills": ["Retail POS", "Inventory", "Customer Service"],
      "salary": "\$13-16/hr",
      "backgroundCheck": true,
      "languages": ["English", "Korean"],
      "transportation": false,
      "isFavorite": false
    },
    {
      "id": 8,
      "name": "James Wilson",
      "role": "Worker",
      "experience": "6 years",
      "rating": 4.7,
      "availability": "Full-time",
      "distance": "5.1 km",
      "photo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1d29504f2-1763294463041.png",
      "semanticLabel":
          "Professional headshot of a man with short brown hair wearing a construction vest",
      "skills": ["Manual Labor", "Equipment Handling", "Team Coordination"],
      "salary": "\$16-20/hr",
      "backgroundCheck": true,
      "languages": ["English"],
      "transportation": true,
      "isFavorite": false
    }
  ];

  List<Map<String, dynamic>> get _filteredCandidates {
    List<Map<String, dynamic>> filtered = _candidates;

    if (_selectedRole != 'All') {
      filtered = filtered.where((c) => c["role"] == _selectedRole).toList();
    }

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((c) {
        return (c["name"] as String).toLowerCase().contains(query) ||
            (c["role"] as String).toLowerCase().contains(query) ||
            (c["skills"] as List)
                .any((s) => (s as String).toLowerCase().contains(query));
      }).toList();
    }

    return filtered;
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isRefreshing = false);
  }

  void _toggleFavorite(int candidateId) {
    setState(() {
      final index = _candidates.indexWhere((c) => c["id"] == candidateId);
      if (index != -1) {
        _candidates[index]["isFavorite"] =
            !(_candidates[index]["isFavorite"] as bool);
      }
    });
  }

  void _toggleComparisonMode(int candidateId) {
    setState(() {
      if (_selectedCandidates.contains(candidateId)) {
        _selectedCandidates.remove(candidateId);
        if (_selectedCandidates.isEmpty) {
          _isComparisonMode = false;
        }
      } else {
        _selectedCandidates.add(candidateId);
        _isComparisonMode = true;
      }
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  void _showCandidateDetails(Map<String, dynamic> candidate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCandidateDetailsSheet(candidate),
    );
  }

  void _quickInvite(Map<String, dynamic> candidate) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Interview invitation sent to ${candidate["name"]}'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View',
          onPressed: () {},
        ),
      ),
    );
  }

  void _sendMessage(Map<String, dynamic> candidate) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with ${candidate["name"]}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _compareSelected() {
    if (_selectedCandidates.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least 2 candidates to compare'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final selected = _candidates
        .where((c) => _selectedCandidates.contains(c["id"]))
        .toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildComparisonSheet(selected),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Hiring Marketplace',
        variant: CustomAppBarVariant.standard,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _showFilterBottomSheet,
            tooltip: 'Advanced Filters',
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'notifications_outlined',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            _buildSearchBar(theme),
            _buildRoleFilters(theme),
            if (_isComparisonMode) _buildComparisonBar(theme),
            Expanded(
              child: _filteredCandidates.isEmpty
                  ? _buildEmptyState(theme)
                  : _buildCandidateList(theme),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post New Job feature coming soon'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        icon: CustomIconWidget(
          iconName: 'add',
          color: theme.colorScheme.onPrimary,
          size: 24,
        ),
        label: Text(
          'Post Job',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() => _currentBottomNavIndex = index);
        },
        variant: CustomBottomBarVariant.standard,
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      color: theme.colorScheme.surface,
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search by name, role, or skills...',
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'search',
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: CustomIconWidget(
                    iconName: 'clear',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
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
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        ),
      ),
    );
  }

  Widget _buildRoleFilters(ThemeData theme) {
    return Container(
      height: 6.h,
      color: theme.colorScheme.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: _roles.length,
        separatorBuilder: (context, index) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          return RoleFilterChipWidget(
            role: _roles[index],
            isSelected: _selectedRole == _roles[index],
            onTap: () {
              setState(() => _selectedRole = _roles[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildComparisonBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      color: theme.colorScheme.primaryContainer,
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'compare_arrows',
            color: theme.colorScheme.onPrimaryContainer,
            size: 24,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              '${_selectedCandidates.length} candidates selected',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: _compareSelected,
            child: Text(
              'Compare',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'close',
              color: theme.colorScheme.onPrimaryContainer,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _isComparisonMode = false;
                _selectedCandidates.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateList(ThemeData theme) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: _filteredCandidates.length,
      separatorBuilder: (context, index) => SizedBox(height: 2.h),
      itemBuilder: (context, index) {
        final candidate = _filteredCandidates[index];
        return GestureDetector(
          onTap: () => _showCandidateDetails(candidate),
          onLongPress: () => _toggleComparisonMode(candidate["id"] as int),
          child: CandidateCardWidget(
            candidate: candidate,
            isSelected: _selectedCandidates.contains(candidate["id"]),
            isComparisonMode: _isComparisonMode,
            onFavoriteToggle: () => _toggleFavorite(candidate["id"] as int),
            onQuickInvite: () => _quickInvite(candidate),
            onSendMessage: () => _sendMessage(candidate),
            onViewProfile: () => _showCandidateDetails(candidate),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'person_search',
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 80,
            ),
            SizedBox(height: 3.h),
            Text(
              'No candidates found',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Try adjusting your filters or search criteria',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedRole = 'All';
                  _searchController.clear();
                });
              },
              icon: CustomIconWidget(
                iconName: 'refresh',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: const Text('Reset Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBottomSheet() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Advanced Filters',
                style: theme.textTheme.titleLarge,
              ),
              IconButton(
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildFilterSection(theme, 'Experience Level', [
            'Entry Level (0-2 years)',
            'Mid Level (3-5 years)',
            'Senior Level (5+ years)',
          ]),
          SizedBox(height: 2.h),
          _buildFilterSection(theme, 'Availability', [
            'Immediate',
            'Part-time',
            'Full-time',
          ]),
          SizedBox(height: 2.h),
          _buildFilterSection(theme, 'Background Check', [
            'Verified',
            'Pending',
          ]),
          SizedBox(height: 2.h),
          _buildFilterSection(theme, 'Transportation', [
            'Has Own Transport',
            'Public Transport',
          ]),
          SizedBox(height: 4.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Reset'),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
      ThemeData theme, String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: options.map((option) {
            return FilterChip(
              label: Text(option),
              selected: false,
              onSelected: (selected) {},
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCandidateDetailsSheet(Map<String, dynamic> candidate) {
    final theme = Theme.of(context);
    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomImageWidget(
                    imageUrl: candidate["photo"] as String,
                    width: 20.w,
                    height: 20.w,
                    fit: BoxFit.cover,
                    semanticLabel: candidate["semanticLabel"] as String,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidate["name"] as String,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '${candidate["role"]} • ${candidate["experience"]}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'star',
                            color: Colors.amber,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '${candidate["rating"]}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          CustomIconWidget(
                            iconName: 'location_on',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            candidate["distance"] as String,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection(
                    theme,
                    'Skills',
                    null,
                    Wrap(
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children: (candidate["skills"] as List).map((skill) {
                        return Chip(
                          label: Text(skill as String),
                          backgroundColor: theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.3),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  _buildDetailSection(theme, 'Salary Expectation',
                      candidate["salary"] as String, null),
                  SizedBox(height: 2.h),
                  _buildDetailSection(theme, 'Availability',
                      candidate["availability"] as String, null),
                  SizedBox(height: 2.h),
                  _buildDetailSection(theme, 'Languages',
                      (candidate["languages"] as List).join(', '), null),
                  SizedBox(height: 2.h),
                  _buildDetailSection(
                      theme,
                      'Background Check',
                      (candidate["backgroundCheck"] as bool)
                          ? 'Verified ✓'
                          : 'Pending',
                      null),
                  SizedBox(height: 2.h),
                  _buildDetailSection(
                      theme,
                      'Transportation',
                      (candidate["transportation"] as bool)
                          ? 'Has Own Transport'
                          : 'Public Transport',
                      null),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _sendMessage(candidate);
                    },
                    icon: CustomIconWidget(
                      iconName: 'message',
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    label: const Text('Message'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _quickInvite(candidate);
                    },
                    icon: CustomIconWidget(
                      iconName: 'calendar_today',
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                    label: const Text('Invite'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
      ThemeData theme, String title, String? value, Widget? customWidget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        customWidget ??
            Text(
              value ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
      ],
    );
  }

  Widget _buildComparisonSheet(List<Map<String, dynamic>> candidates) {
    final theme = Theme.of(context);
    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Compare Candidates',
                  style: theme.textTheme.titleLarge,
                ),
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: candidates.map((candidate) {
                  return Container(
                    width: 70.w,
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CustomImageWidget(
                            imageUrl: candidate["photo"] as String,
                            width: 30.w,
                            height: 30.w,
                            fit: BoxFit.cover,
                            semanticLabel: candidate["semanticLabel"] as String,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          candidate["name"] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 1.h),
                        _buildComparisonRow(
                            theme, 'Role', candidate["role"] as String),
                        _buildComparisonRow(theme, 'Experience',
                            candidate["experience"] as String),
                        _buildComparisonRow(
                            theme, 'Rating', '${candidate["rating"]}'),
                        _buildComparisonRow(
                            theme, 'Salary', candidate["salary"] as String),
                        _buildComparisonRow(theme, 'Availability',
                            candidate["availability"] as String),
                        _buildComparisonRow(
                            theme, 'Distance', candidate["distance"] as String),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
