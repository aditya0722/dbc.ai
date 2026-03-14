import 'package:flutter/material.dart';

class HelpService {
  static final HelpService _instance = HelpService._internal();
  factory HelpService() => _instance;
  HelpService._internal();

  final Map<String, ScreenHelpData> _screenHelp = {
    '/business-dashboard': ScreenHelpData(
      screenName: 'Business Dashboard',
      overview: 'Your central command center for all business operations',
      quickTips: [
        'View real-time business metrics at a glance',
        'Access quick actions for common tasks',
        'Monitor security alerts and notifications',
        'Track daily sales and financial performance',
      ],
      videoTutorialUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      stepByStepTasks: [
        TaskWalkthrough(
          title: 'Daily Morning Routine',
          steps: [
            'Check overnight security alerts',
            'Review yesterday\'s sales performance',
            'Check inventory low stock warnings',
            'Process pending staff requests',
          ],
          estimatedTime: '5 minutes',
        ),
        TaskWalkthrough(
          title: 'Weekly Financial Review',
          steps: [
            'Navigate to Payment Processing Center',
            'Review weekly transaction summary',
            'Check pending GST filing requirements',
            'Generate weekly financial reports',
          ],
          estimatedTime: '15 minutes',
        ),
      ],
      contextualHelp: {
        'metrics_card':
            'Displays key performance indicators updated in real-time',
        'quick_actions': 'One-tap shortcuts to frequently used features',
        'security_alerts': 'Urgent notifications requiring immediate attention',
      },
    ),
    '/security-alerts-dashboard': ScreenHelpData(
      screenName: 'Security Alerts Dashboard',
      overview:
          'Monitor and respond to security incidents across your business',
      quickTips: [
        'Red alerts require immediate attention',
        'Swipe to acknowledge or dismiss alerts',
        'Filter by severity to prioritize responses',
        'Use live camera view for visual verification',
      ],
      videoTutorialUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      stepByStepTasks: [
        TaskWalkthrough(
          title: 'Responding to Security Alerts',
          steps: [
            'Review alert severity and timestamp',
            'Tap to view full incident details',
            'Check associated camera footage if available',
            'Mark as acknowledged or escalate to authorities',
            'Document incident in security log',
          ],
          estimatedTime: '3 minutes',
        ),
      ],
      contextualHelp: {
        'severity_filters':
            'Filter alerts by urgency: Critical, High, Medium, Low',
        'alert_card': 'Tap for details, swipe for quick actions',
        'status_indicator': 'Shows if alert is new, acknowledged, or resolved',
      },
    ),
    '/inventory-management': ScreenHelpData(
      screenName: 'Inventory Management',
      overview: 'Track stock levels and manage product inventory',
      quickTips: [
        'Red indicators show items below minimum stock',
        'Use search to find products quickly',
        'Tap items to update quantities',
        'Filter by category for easier management',
      ],
      videoTutorialUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      stepByStepTasks: [
        TaskWalkthrough(
          title: 'Restocking Low Inventory',
          steps: [
            'Filter to show items with low stock',
            'Review reorder quantities and lead times',
            'Navigate to Marketplace Product Catalog',
            'Search for required products',
            'Place orders with preferred vendors',
            'Update expected delivery dates',
          ],
          estimatedTime: '10 minutes',
        ),
      ],
      contextualHelp: {
        'stock_indicator':
            'Color codes: Green (sufficient), Yellow (low), Red (critical)',
        'reorder_button': 'Quick link to marketplace for replenishment',
        'filter_options': 'Sort by stock level, category, or supplier',
      },
    ),
    '/staff-management': ScreenHelpData(
      screenName: 'Staff Management',
      overview: 'Manage employee records, schedules, and performance',
      quickTips: [
        'Use department filters to view specific teams',
        'Tap staff cards to view detailed profiles',
        'Track attendance and leave requests',
        'Access payroll processing from here',
      ],
      videoTutorialUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      stepByStepTasks: [
        TaskWalkthrough(
          title: 'Processing Leave Requests',
          steps: [
            'Filter to show pending leave requests',
            'Review staff member\'s attendance history',
            'Check team coverage for requested dates',
            'Approve or deny with optional comments',
            'System automatically updates schedule',
          ],
          estimatedTime: '5 minutes',
        ),
      ],
      contextualHelp: {
        'staff_card': 'Shows employee status, role, and quick actions',
        'department_chip': 'Filter by department for focused management',
        'add_button': 'Create new employee profile or post job opening',
      },
    ),
    '/order-management-hub': ScreenHelpData(
      screenName: 'Order Management Hub',
      overview: 'Track and manage customer orders from placement to delivery',
      quickTips: [
        'Status colors indicate order progress',
        'Swipe orders for quick status updates',
        'Filter by status to focus on specific stages',
        'Tap for detailed order information',
      ],
      videoTutorialUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      stepByStepTasks: [
        TaskWalkthrough(
          title: 'Processing New Orders',
          steps: [
            'Filter to show "Pending" orders',
            'Verify product availability in inventory',
            'Confirm order details and payment status',
            'Update status to "Processing"',
            'Assign to delivery/pickup schedule',
            'Notify customer of estimated completion',
          ],
          estimatedTime: '8 minutes per order',
        ),
      ],
      contextualHelp: {
        'order_card': 'Displays order number, items, status, and customer info',
        'status_chip': 'Current order stage: Pending → Processing → Completed',
        'quick_actions': 'Swipe left for update options',
      },
    ),
    '/payment-processing-center': ScreenHelpData(
      screenName: 'Payment Processing Center',
      overview: 'Process customer payments and track financial transactions',
      quickTips: [
        'Select payment method before processing',
        'Daily summary shows transaction totals',
        'All transactions are automatically logged',
        'Use search to find specific transactions',
      ],
      videoTutorialUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      stepByStepTasks: [
        TaskWalkthrough(
          title: 'End of Day Payment Reconciliation',
          steps: [
            'Review daily transaction summary',
            'Verify cash drawer matches cash payments',
            'Check digital payment gateway settlements',
            'Document any discrepancies',
            'Export daily report for accounting',
            'Reset daily totals for next business day',
          ],
          estimatedTime: '20 minutes',
        ),
      ],
      contextualHelp: {
        'payment_method': 'Select before processing: Cash, Card, UPI, Wallet',
        'transaction_card': 'Shows payment details, timestamp, and receipt',
        'daily_summary': 'Real-time totals by payment method',
      },
    ),
    '/gst-filing-center': ScreenHelpData(
      screenName: 'GST Filing Center',
      overview: 'Manage GST returns and ensure tax compliance',
      quickTips: [
        'File returns before the deadline to avoid penalties',
        'Review all transactions before filing',
        'System auto-calculates GST amounts',
        'Download filed returns for records',
      ],
      videoTutorialUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      stepByStepTasks: [
        TaskWalkthrough(
          title: 'Monthly GST Return Filing',
          steps: [
            'Select current filing period',
            'Review auto-generated GSTR-1 summary',
            'Verify input tax credit details',
            'Check for any calculation discrepancies',
            'Submit return to GST portal',
            'Download acknowledgment receipt',
            'Update filing status in system',
          ],
          estimatedTime: '30 minutes',
        ),
      ],
      contextualHelp: {
        'period_selector': 'Choose month/quarter for filing',
        'overview_card': 'Summary of taxable sales and input credits',
        'filing_timeline': 'Visual timeline of return deadlines',
      },
    ),
    '/notification-center': ScreenHelpData(
      screenName: 'Notification Center',
      overview: 'View all system and business notifications in one place',
      quickTips: [
        'Red badge shows unread notification count',
        'Filter by category for specific notification types',
        'Swipe to mark as read or delete',
        'Configure notification preferences in settings',
      ],
      videoTutorialUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      stepByStepTasks: [
        TaskWalkthrough(
          title: 'Managing Daily Notifications',
          steps: [
            'Review security alerts first (highest priority)',
            'Check staff-related notifications',
            'Review inventory low stock warnings',
            'Clear read notifications to declutter',
            'Configure notification preferences if needed',
          ],
          estimatedTime: '5 minutes',
        ),
      ],
      contextualHelp: {
        'filter_tabs': 'Quick filters: All, Security, Staff, Orders, System',
        'notification_card': 'Shows title, timestamp, and priority level',
        'settings_icon': 'Customize which notifications you receive',
      },
    ),
  };

  ScreenHelpData? getScreenHelp(String route) {
    return _screenHelp[route];
  }

  void showContextualHelp(
    BuildContext context,
    String elementKey,
    String route,
  ) {
    final screenHelp = _screenHelp[route];
    if (screenHelp == null ||
        !screenHelp.contextualHelp.containsKey(elementKey)) {
      return;
    }

    final helpText = screenHelp.contextualHelp[elementKey]!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue[700]),
            const SizedBox(width: 8),
            const Expanded(child: Text('Quick Help')),
          ],
        ),
        content: Text(helpText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void showFullScreenHelp(BuildContext context, String route) {
    final screenHelp = _screenHelp[route];
    if (screenHelp == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenHelpView(screenHelp: screenHelp),
      ),
    );
  }
}

class ScreenHelpData {
  final String screenName;
  final String overview;
  final List<String> quickTips;
  final String videoTutorialUrl;
  final List<TaskWalkthrough> stepByStepTasks;
  final Map<String, String> contextualHelp;

  ScreenHelpData({
    required this.screenName,
    required this.overview,
    required this.quickTips,
    required this.videoTutorialUrl,
    required this.stepByStepTasks,
    required this.contextualHelp,
  });
}

class TaskWalkthrough {
  final String title;
  final List<String> steps;
  final String estimatedTime;

  TaskWalkthrough({
    required this.title,
    required this.steps,
    required this.estimatedTime,
  });
}

class FullScreenHelpView extends StatelessWidget {
  final ScreenHelpData screenHelp;

  const FullScreenHelpView({super.key, required this.screenHelp});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${screenHelp.screenName} Help'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    screenHelp.overview,
                    style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '💡 Quick Tips',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...screenHelp.quickTips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.blue[700],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(tip, style: const TextStyle(fontSize: 15)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '📹 Video Tutorial',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 64,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to watch video tutorial',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '📝 Step-by-Step Walkthroughs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...screenHelp.stepByStepTasks.map(
              (task) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            task.estimatedTime,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...task.steps.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.blue[700],
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
