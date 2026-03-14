import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../services/help_service.dart';

class HelpFloatingButton extends StatelessWidget {
  final String currentRoute;

  const HelpFloatingButton({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final screenHelp = HelpService().getScreenHelp(currentRoute);

    if (screenHelp == null) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      heroTag: 'help_button_$currentRoute',
      onPressed: () {
        _showHelpOptions(context, screenHelp);
      },
      backgroundColor: Colors.blue[700],
      child: const Icon(Icons.help_outline),
    );
  }

  void _showHelpOptions(BuildContext context, ScreenHelpData screenHelp) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[500]!],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.help, color: Colors.white, size: 7.w),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      '${screenHelp.screenName} Help',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                children: [
                  _buildHelpOption(
                    context,
                    'Quick Tips',
                    Icons.lightbulb_outline,
                    Colors.amber,
                    () {
                      Navigator.pop(context);
                      _showQuickTips(context, screenHelp);
                    },
                  ),
                  SizedBox(height: 2.h),
                  _buildHelpOption(
                    context,
                    'Watch Video Tutorial',
                    Icons.play_circle_outline,
                    Colors.red,
                    () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Opening video tutorial for ${screenHelp.screenName}',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 2.h),
                  _buildHelpOption(
                    context,
                    'Step-by-Step Tasks',
                    Icons.list_alt,
                    Colors.green,
                    () {
                      Navigator.pop(context);
                      HelpService().showFullScreenHelp(context, currentRoute);
                    },
                  ),
                  SizedBox(height: 2.h),
                  _buildHelpOption(
                    context,
                    'Complete Help Guide',
                    Icons.menu_book,
                    Colors.blue,
                    () {
                      Navigator.pop(context);
                      HelpService().showFullScreenHelp(context, currentRoute);
                    },
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpOption(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 6.w),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 4.w, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showQuickTips(BuildContext context, ScreenHelpData screenHelp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.amber[700]),
            const SizedBox(width: 8),
            const Text('Quick Tips'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                screenHelp.overview,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              ...screenHelp.quickTips.map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(tip, style: const TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
