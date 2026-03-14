import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/notification_service.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/filter_tab_widget.dart';
import './widgets/notification_card_widget.dart';
import './widgets/notification_search_widget.dart';

class NotificationCenter extends StatefulWidget {
  const NotificationCenter({Key? key}) : super(key: key);

  @override
  State<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  final NotificationService _notificationService = NotificationService();
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _selectedNotifications = [];
  String _selectedFilter = 'All';
  bool _isLoading = true;
  bool _isSelectionMode = false;
  String? _searchQuery;

  final List<String> _filterOptions = [
    'All',
    'Security',
    'Inventory',
    'Staff',
    'Orders',
    'System',
    'GST',
    'Payroll',
    'Hiring',
    'Marketplace'
  ];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await _notificationService.fetchNotifications(
        typeFilter: _selectedFilter,
      );
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notifications: $e')),
        );
      }
    }
  }

  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) {
      _loadNotifications();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final results = await _notificationService.searchNotifications(query);
      setState(() {
        _notifications = results;
        _searchQuery = query;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      _loadNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark as read: $e')),
        );
      }
    }
  }

  Future<void> _archiveNotification(String notificationId) async {
    try {
      await _notificationService.archiveNotification(notificationId);
      _loadNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification archived')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to archive: $e')),
        );
      }
    }
  }

  void _toggleSelection(Map<String, dynamic> notification) {
    setState(() {
      if (_selectedNotifications.contains(notification)) {
        _selectedNotifications.remove(notification);
      } else {
        _selectedNotifications.add(notification);
      }
      _isSelectionMode = _selectedNotifications.isNotEmpty;
    });
  }

  Future<void> _markSelectedAsRead() async {
    try {
      final ids = _selectedNotifications.map((n) => n['id'] as String).toList();
      await _notificationService.markMultipleAsRead(ids);
      setState(() {
        _selectedNotifications.clear();
        _isSelectionMode = false;
      });
      _loadNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark as read: $e')),
        );
      }
    }
  }

  Future<void> _archiveSelected() async {
    try {
      final ids = _selectedNotifications.map((n) => n['id'] as String).toList();
      await _notificationService.archiveMultiple(ids);
      setState(() {
        _selectedNotifications.clear();
        _isSelectionMode = false;
      });
      _loadNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications archived')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to archive: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Notification Center',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/notification-settings');
            },
          ),
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _selectedNotifications.clear();
                  _isSelectionMode = false;
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          NotificationSearchWidget(
            onSearch: _handleSearch,
            onClear: () {
              setState(() => _searchQuery = null);
              _loadNotifications();
            },
          ),

          // Filter tabs
          Container(
            height: 6.h,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                return FilterTabWidget(
                  label: _filterOptions[index],
                  isSelected: _selectedFilter == _filterOptions[index],
                  onTap: () {
                    setState(() => _selectedFilter = _filterOptions[index]);
                    _loadNotifications();
                  },
                );
              },
            ),
          ),

          // Notifications list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none,
                                size: 20.w, color: Colors.grey[400]),
                            SizedBox(height: 2.h),
                            Text(
                              'No notifications',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadNotifications,
                        child: ListView.builder(
                          padding: EdgeInsets.all(2.w),
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            return NotificationCardWidget(
                              notification: notification,
                              isSelected:
                                  _selectedNotifications.contains(notification),
                              onTap: () {
                                if (_isSelectionMode) {
                                  _toggleSelection(notification);
                                } else {
                                  // Navigate to action URL if available
                                  if (notification['action_url'] != null) {
                                    Navigator.pushNamed(
                                      context,
                                      notification['action_url'],
                                    );
                                  }
                                  if (!(notification['is_read'] ?? false)) {
                                    _markAsRead(notification['id']);
                                  }
                                }
                              },
                              onLongPress: () => _toggleSelection(notification),
                              onMarkRead: () => _markAsRead(notification['id']),
                              onArchive: () =>
                                  _archiveNotification(notification['id']),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _isSelectionMode
          ? Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 4.0,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: _markSelectedAsRead,
                    icon: const Icon(Icons.mark_email_read),
                    label: const Text('Mark Read'),
                  ),
                  TextButton.icon(
                    onPressed: _archiveSelected,
                    icon: const Icon(Icons.archive),
                    label: const Text('Archive'),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
