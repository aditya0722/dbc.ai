import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/app_export.dart';

class EventCardWidget extends StatefulWidget {
  final Map<String, dynamic> event;
  final bool isMultiSelectMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const EventCardWidget({
    super.key,
    required this.event,
    this.isMultiSelectMode = false,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<EventCardWidget> createState() => _EventCardWidgetState();
}

class _EventCardWidgetState extends State<EventCardWidget> {
  bool _isExpanded = false;

  Color _getAlertLevelColor(String alertLevel, ColorScheme colorScheme) {
    switch (alertLevel) {
      case 'High':
        return const Color(0xFFEF4444);
      case 'Medium':
        return const Color(0xFFF59E0B);
      case 'Low':
        return const Color(0xFF10B981);
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  IconData _getEventTypeIcon(String eventType) {
    switch (eventType) {
      case 'Person':
        return Icons.person;
      case 'Vehicle':
        return Icons.directions_car;
      case 'Motion':
        return Icons.motion_photos_on;
      default:
        return Icons.circle;
    }
  }

  void _handleShare() {
    final timestamp = DateFormat('MMM dd, yyyy HH:mm').format(widget.event["timestamp"] as DateTime);
    final shareText = '''
Security Event Report
Time: $timestamp
Location: ${widget.event["cameraLocation"]}
Type: ${widget.event["eventType"]}
Alert Level: ${widget.event["alertLevel"]}
Confidence: ${((widget.event["confidence"] as double) * 100).toStringAsFixed(1)}%
Duration: ${widget.event["duration"]}s
${widget.event["notes"].toString().isNotEmpty ? 'Notes: ${widget.event["notes"]}' : ''}
    ''';
    
    Share.share(shareText);
  }

  void _handleAddNote() {
    showDialog(
      context: context,
      builder: (context) => _buildNoteDialog(),
    );
  }

  void _handleMarkReviewed() {
    setState(() {
      widget.event["isReviewed"] = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Event marked as reviewed'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handlePlayVideo() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing video clip from ${widget.event["cameraLocation"]}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildNoteDialog() {
    final theme = Theme.of(context);
    final noteController = TextEditingController(text: widget.event["notes"] as String);
    
    return AlertDialog(
      title: Text('Add Note', style: theme.textTheme.titleLarge),
      content: TextField(
        controller: noteController,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Enter your notes here...',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              widget.event["notes"] = noteController.text;
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Note saved'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timestamp = DateFormat('MMM dd, yyyy HH:mm').format(widget.event["timestamp"] as DateTime);
    final alertColor = _getAlertLevelColor(widget.event["alertLevel"] as String, colorScheme);
    
    return Dismissible(
      key: Key('event_${widget.event["id"]}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'share',
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  'Share',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'note_add',
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  'Note',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  'Review',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      onDismissed: (direction) {},
      child: GestureDetector(
        onTap: widget.isMultiSelectMode ? widget.onTap : () {
          setState(() => _isExpanded = !_isExpanded);
        },
        onLongPress: widget.onLongPress,
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isMultiSelectMode)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Checkbox(
                          value: widget.isSelected,
                          onChanged: (_) => widget.onTap?.call(),
                        ),
                      ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CustomImageWidget(
                        imageUrl: widget.event["thumbnail"] as String,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        semanticLabel: widget.event["semanticLabel"] as String,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: alertColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getEventTypeIcon(widget.event["eventType"] as String),
                                      size: 14,
                                      color: alertColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.event["eventType"] as String,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: alertColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (widget.event["isReviewed"] as bool)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'check',
                                        color: const Color(0xFF10B981),
                                        size: 12,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Reviewed',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: const Color(0xFF10B981),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.event["cameraLocation"] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'access_time',
                                color: colorScheme.onSurfaceVariant,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  timestamp,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!widget.isMultiSelectMode)
                      CustomIconWidget(
                        iconName: _isExpanded ? 'expand_less' : 'expand_more',
                        color: colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                  ],
                ),
              ),
              if (_isExpanded) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CustomImageWidget(
                          imageUrl: widget.event["thumbnail"] as String,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          semanticLabel: widget.event["semanticLabel"] as String,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              theme,
                              'Confidence',
                              '${((widget.event["confidence"] as double) * 100).toStringAsFixed(1)}%',
                            ),
                          ),
                          Expanded(
                            child: _buildInfoItem(
                              theme,
                              'Duration',
                              '${widget.event["duration"]}s',
                            ),
                          ),
                          Expanded(
                            child: _buildInfoItem(
                              theme,
                              'Alert Level',
                              widget.event["alertLevel"] as String,
                            ),
                          ),
                        ],
                      ),
                      if ((widget.event["notes"] as String).isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Notes',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.event["notes"] as String,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _handlePlayVideo,
                              icon: CustomIconWidget(
                                iconName: 'play_circle',
                                color: colorScheme.primary,
                                size: 20,
                              ),
                              label: const Text('Play Video'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _handleShare,
                              icon: CustomIconWidget(
                                iconName: 'share',
                                color: colorScheme.primary,
                                size: 20,
                              ),
                              label: const Text('Share'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _handleAddNote,
                              icon: CustomIconWidget(
                                iconName: 'note_add',
                                color: colorScheme.primary,
                                size: 20,
                              ),
                              label: const Text('Add Note'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _handleMarkReviewed,
                              icon: CustomIconWidget(
                                iconName: 'check_circle',
                                color: colorScheme.onPrimary,
                                size: 20,
                              ),
                              label: const Text('Mark Reviewed'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}