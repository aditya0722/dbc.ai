import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/date_range_picker_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/event_card_widget.dart';
import './widgets/filter_chips_widget.dart';

class SecurityEventsHistory extends StatefulWidget {
  const SecurityEventsHistory({super.key});

  @override
  State<SecurityEventsHistory> createState() => _SecurityEventsHistoryState();
}

class _SecurityEventsHistoryState extends State<SecurityEventsHistory> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool _isSearchVisible = false;
  bool _isLoading = false;
  bool _isMultiSelectMode = false;
  Set<int> _selectedEventIds = {};

  DateTimeRange? _selectedDateRange;
  Set<String> _activeFilters = {};

  List<Map<String, dynamic>> _allEvents = [];
  List<Map<String, dynamic>> _filteredEvents = [];

  int _currentPage = 1;
  final int _eventsPerPage = 20;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initializeMockData() {
    _allEvents = [
      {
        "id": 1,
        "timestamp": DateTime.now().subtract(const Duration(minutes: 15)),
        "cameraLocation": "Main Entrance",
        "eventType": "Person",
        "alertLevel": "High",
        "thumbnail":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1cf610b34-1764637173688.png",
        "semanticLabel":
            "Security camera view of main entrance showing person approaching door",
        "confidence": 0.94,
        "duration": 12,
        "isReviewed": false,
        "notes": "",
        "videoClipUrl": "https://example.com/clip1.mp4"
      },
      {
        "id": 2,
        "timestamp":
            DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        "cameraLocation": "Parking Lot",
        "eventType": "Vehicle",
        "alertLevel": "Medium",
        "thumbnail":
            "https://images.unsplash.com/photo-1595391907659-16f28b0c02b5",
        "semanticLabel":
            "Parking lot camera showing white sedan entering parking area",
        "confidence": 0.89,
        "duration": 8,
        "isReviewed": true,
        "notes": "Regular delivery vehicle",
        "videoClipUrl": "https://example.com/clip2.mp4"
      },
      {
        "id": 3,
        "timestamp": DateTime.now().subtract(const Duration(hours: 3)),
        "cameraLocation": "Back Door",
        "eventType": "Motion",
        "alertLevel": "Low",
        "thumbnail":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1374abedb-1765197586047.png",
        "semanticLabel":
            "Back door area with motion detected near storage boxes",
        "confidence": 0.76,
        "duration": 5,
        "isReviewed": true,
        "notes": "",
        "videoClipUrl": "https://example.com/clip3.mp4"
      },
      {
        "id": 4,
        "timestamp": DateTime.now().subtract(const Duration(hours: 5)),
        "cameraLocation": "Kitchen Area",
        "eventType": "Person",
        "alertLevel": "High",
        "thumbnail":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1b5f5c3b4-1764658223738.png",
        "semanticLabel":
            "Kitchen surveillance showing staff member working at preparation station",
        "confidence": 0.92,
        "duration": 15,
        "isReviewed": false,
        "notes": "",
        "videoClipUrl": "https://example.com/clip4.mp4"
      },
      {
        "id": 5,
        "timestamp": DateTime.now().subtract(const Duration(hours: 8)),
        "cameraLocation": "Store Room",
        "eventType": "Motion",
        "alertLevel": "Medium",
        "thumbnail":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1374abedb-1765197586047.png",
        "semanticLabel":
            "Store room interior with shelving units and detected movement",
        "confidence": 0.81,
        "duration": 7,
        "isReviewed": true,
        "notes": "Inventory check",
        "videoClipUrl": "https://example.com/clip5.mp4"
      },
      {
        "id": 6,
        "timestamp": DateTime.now().subtract(const Duration(hours: 12)),
        "cameraLocation": "Front Counter",
        "eventType": "Person",
        "alertLevel": "Low",
        "thumbnail":
            "https://img.rocket.new/generatedImages/rocket_gen_img_104a4f368-1764730876735.png",
        "semanticLabel":
            "Front counter area showing customer interaction with staff",
        "confidence": 0.88,
        "duration": 20,
        "isReviewed": true,
        "notes": "",
        "videoClipUrl": "https://example.com/clip6.mp4"
      },
      {
        "id": 7,
        "timestamp": DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        "cameraLocation": "Side Entrance",
        "eventType": "Vehicle",
        "alertLevel": "High",
        "thumbnail":
            "https://images.unsplash.com/photo-1632433217186-3c74be5aa9a7",
        "semanticLabel": "Side entrance showing black SUV approaching building",
        "confidence": 0.91,
        "duration": 10,
        "isReviewed": false,
        "notes": "",
        "videoClipUrl": "https://example.com/clip7.mp4"
      },
      {
        "id": 8,
        "timestamp": DateTime.now().subtract(const Duration(days: 1, hours: 6)),
        "cameraLocation": "Gym Floor",
        "eventType": "Person",
        "alertLevel": "Low",
        "thumbnail":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1b621f478-1764872610910.png",
        "semanticLabel": "Gym floor showing person exercising on equipment",
        "confidence": 0.85,
        "duration": 18,
        "isReviewed": true,
        "notes": "Regular member",
        "videoClipUrl": "https://example.com/clip8.mp4"
      },
    ];

    _filteredEvents = List.from(_allEvents);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoading && _hasMoreData) {
        _loadMoreEvents();
      }
    }
  }

  Future<void> _loadMoreEvents() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _currentPage++;
      if (_currentPage > 2) {
        _hasMoreData = false;
      }
      _isLoading = false;
    });
  }

  Future<void> _refreshEvents() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _currentPage = 1;
      _hasMoreData = true;
      _applyFilters();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        _applyFilters();
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _applyFilters();
    });
  }

  void _onDateRangeSelected(DateTimeRange? range) {
    setState(() {
      _selectedDateRange = range;
      _applyFilters();
    });
  }

  void _toggleFilter(String filter) {
    setState(() {
      _activeFilters.contains(filter)
          ? _activeFilters.remove(filter)
          : _activeFilters.add(filter);
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allEvents);

    if (_selectedDateRange != null) {
      filtered = filtered.where((event) {
        final eventDate = event["timestamp"] as DateTime;
        return eventDate.isAfter(_selectedDateRange!.start) &&
            eventDate
                .isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    if (_activeFilters.isNotEmpty) {
      filtered = filtered.where((event) {
        return _activeFilters.contains(event["eventType"]) ||
            _activeFilters.contains(event["alertLevel"]);
      }).toList();
    }

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((event) {
        return (event["cameraLocation"] as String)
                .toLowerCase()
                .contains(query) ||
            (event["notes"] as String).toLowerCase().contains(query) ||
            DateFormat('MMM dd, yyyy HH:mm')
                .format(event["timestamp"] as DateTime)
                .toLowerCase()
                .contains(query);
      }).toList();
    }

    setState(() {
      _filteredEvents = filtered;
    });
  }

  void _toggleMultiSelect() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedEventIds.clear();
      }
    });
  }

  void _toggleEventSelection(int eventId) {
    setState(() {
      _selectedEventIds.contains(eventId)
          ? _selectedEventIds.remove(eventId)
          : _selectedEventIds.add(eventId);
    });
  }

  void _handleBulkAction(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action ${_selectedEventIds.length} events'),
        duration: const Duration(seconds: 2),
      ),
    );

    setState(() {
      _isMultiSelectMode = false;
      _selectedEventIds.clear();
    });
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildAdvancedFiltersSheet(),
    );
  }

  Widget _buildAdvancedFiltersSheet() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
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
          const SizedBox(height: 24),
          Text(
            'Confidence Score',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('> 90%'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('> 80%'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('> 70%'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Duration',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('< 5s'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('5-15s'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('> 15s'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply Filters'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Security Events',
        variant: CustomAppBarVariant.standard,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: _isSearchVisible ? 'search_off' : 'search',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _toggleSearch,
          ),
          if (_isMultiSelectMode)
            IconButton(
              icon: CustomIconWidget(
                iconName: 'close',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
              onPressed: _toggleMultiSelect,
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearchVisible) _buildSearchBar(theme),
          DateRangePickerWidget(
            selectedRange: _selectedDateRange,
            onRangeSelected: _onDateRangeSelected,
          ),
          FilterChipsWidget(
            activeFilters: _activeFilters,
            onFilterToggled: _toggleFilter,
          ),
          Expanded(
            child: _filteredEvents.isEmpty
                ? const EmptyStateWidget()
                : RefreshIndicator(
                    onRefresh: _refreshEvents,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: _filteredEvents.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _filteredEvents.length) {
                          return _buildLoadingIndicator();
                        }

                        final event = _filteredEvents[index];
                        return EventCardWidget(
                          event: event,
                          isMultiSelectMode: _isMultiSelectMode,
                          isSelected: _selectedEventIds.contains(event["id"]),
                          onTap: () => _isMultiSelectMode
                              ? _toggleEventSelection(event["id"] as int)
                              : null,
                          onLongPress: () {
                            if (!_isMultiSelectMode) {
                              _toggleMultiSelect();
                              _toggleEventSelection(event["id"] as int);
                            }
                          },
                        );
                      },
                    ),
                  ),
          ),
          if (_isMultiSelectMode) _buildBulkActionBar(theme),
        ],
      ),
      bottomNavigationBar: const CustomBottomBar(
        currentIndex: 1,
        variant: CustomBottomBarVariant.standard,
      ),
      floatingActionButton: !_isMultiSelectMode
          ? FloatingActionButton(
              onPressed: _showAdvancedFilters,
              child: CustomIconWidget(
                iconName: 'tune',
                color: theme.colorScheme.onPrimary,
                size: 24,
              ),
            )
          : null,
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search by location, time, or notes...',
          prefixIcon: CustomIconWidget(
            iconName: 'search',
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
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
                    _onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildBulkActionBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Text(
              '${_selectedEventIds.length} selected',
              style: theme.textTheme.titleMedium,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _handleBulkAction('Export'),
              icon: CustomIconWidget(
                iconName: 'file_download',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              label: const Text('Export'),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () => _handleBulkAction('Mark Reviewed'),
              icon: CustomIconWidget(
                iconName: 'check_circle',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              label: const Text('Mark Reviewed'),
            ),
          ],
        ),
      ),
    );
  }
}
