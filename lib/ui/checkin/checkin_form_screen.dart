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

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    final pos = await Geolocator.getCurrentPosition();
    setState(() => _position = pos);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_position == null) return;

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkInViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New Check-in')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                minLines: 3,
                maxLines: 5,
                validator: (v) {
                  if (v == null || v.trim().length < 10) {
                    return 'Minimum 10 characters required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                items: const [
                  DropdownMenuItem(value: 'Safety', child: Text('Safety')),
                  DropdownMenuItem(value: 'Progress', child: Text('Progress')),
                  DropdownMenuItem(value: 'Issue', child: Text('Issue')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _category = v!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 16),
              if (_position == null)
                const Text('Fetching location...')
              else
                Text(
                  'Lat: ${_position!.latitude}, Lng: ${_position!.longitude}',
                ),
              const Spacer(),
              state.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Submit Check-in'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
