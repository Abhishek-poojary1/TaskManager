import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/task.dart';
import '../../domain/models/checkin.dart';
import '../../domain/enums/checkin_status.dart';
import '../../viewmodel/checkin_viewmodel.dart';

class CheckInFormScreen extends ConsumerStatefulWidget {
  final Task task;

  const CheckInFormScreen({super.key, required this.task});

  @override
  ConsumerState<CheckInFormScreen> createState() => _CheckInFormScreenState();
}

class _CheckInFormScreenState extends ConsumerState<CheckInFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  String _category = 'Safety';
  Position? _position;
  bool _isLoadingLocation = true;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Location permission denied';
          _isLoadingLocation = false;
        });
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _position = pos;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = 'Failed to get location';
        _isLoadingLocation = false;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Location is required for check-in'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final checkIn = CheckIn(
      id: const Uuid().v4(),
      taskId: widget.task.id,
      notes: _notesController.text.trim(),
      category: _category,
      latitude: _position!.latitude,
      longitude: _position!.longitude,
      createdAt: DateTime.now(),
      syncStatus: CheckInSyncStatus.pending,
    );

    ref.read(checkInViewModelProvider.notifier).submit(checkIn).then((_) {
      Navigator.pop(context);
    });
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Safety':
        return Colors.red.shade400;
      case 'Progress':
        return Colors.blue.shade400;
      case 'Issue':
        return Colors.orange.shade400;
      case 'Other':
        return Colors.purple.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Safety':
        return Icons.shield_outlined;
      case 'Progress':
        return Icons.trending_up;
      case 'Issue':
        return Icons.warning_amber;
      case 'Other':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkInViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('New Check-In'),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_position != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.location_on, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Located',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Task Info Card
                    Card(
                      elevation: 0,
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.task,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Task Check-In',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.task.title,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Category Selection
                    Text(
                      'Check-In Category',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _buildCategoryOption('Safety'),
                          const SizedBox(height: 8),
                          _buildCategoryOption('Progress'),
                          const SizedBox(height: 8),
                          _buildCategoryOption('Issue'),
                          const SizedBox(height: 8),
                          _buildCategoryOption('Other'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Notes Section
                    Text(
                      'Notes & Observations',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      minLines: 5,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText:
                            'Describe what you observed or want to report...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red.shade300),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.red.shade300,
                            width: 2,
                          ),
                        ),
                        counterText: '',
                      ),
                      maxLength: 500,
                      validator: (v) {
                        if (v == null || v.trim().length < 10) {
                          return 'Please provide at least 10 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Minimum 10 characters required',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Location Card
                    Text(
                      'Location Information',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _position != null
                              ? Colors.green.shade200
                              : _locationError != null
                              ? Colors.red.shade200
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: _isLoadingLocation
                          ? Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Fetching your location...',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            )
                          : _locationError != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red.shade400,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _locationError!,
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _fetchLocation,
                                    icon: const Icon(Icons.refresh, size: 18),
                                    label: const Text('Retry'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          theme.colorScheme.primary,
                                      side: BorderSide(
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.location_on,
                                        color: Colors.green.shade600,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Location Captured',
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.green.shade700,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Lat: ${_position!.latitude.toStringAsFixed(6)}\nLng: ${_position!.longitude.toStringAsFixed(6)}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: Colors.grey.shade600,
                                                  height: 1.4,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _fetchLocation,
                                      icon: Icon(
                                        Icons.refresh,
                                        color: Colors.grey.shade600,
                                        size: 20,
                                      ),
                                      tooltip: 'Refresh location',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Submit Button (Fixed at bottom)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 54,
                  child: state.isLoading
                      ? Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: Colors.grey.shade300,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.send_rounded),
                              SizedBox(width: 8),
                              Text(
                                'Submit Check-In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryOption(String category) {
    final isSelected = _category == category;
    final color = _getCategoryColor(category);
    final icon = _getCategoryIcon(category);
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => setState(() => _category = category),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? color : Colors.grey.shade700,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 22),
          ],
        ),
      ),
    );
  }
}
