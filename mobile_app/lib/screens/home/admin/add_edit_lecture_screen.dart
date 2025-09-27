import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/lecture_provider.dart';
import '../../../models/lecture.dart';

class AddEditLectureScreen extends StatefulWidget {
  final Lecture? lecture;

  const AddEditLectureScreen({super.key, this.lecture});

  @override
  State<AddEditLectureScreen> createState() => _AddEditLectureScreenState();
}

class _AddEditLectureScreenState extends State<AddEditLectureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeStartController = TextEditingController();
  final _timeEndController = TextEditingController();
  final _locationController = TextEditingController();
  final _lecturerController = TextEditingController();

  List<String> _selectedDays = [];
  final List<String> _availableDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.lecture != null) {
      _titleController.text = widget.lecture!.title;
      _timeStartController.text = widget.lecture!.timeStart;
      _timeEndController.text = widget.lecture!.timeEnd;
      _selectedDays = List.from(widget.lecture!.days);
      _locationController.text = widget.lecture!.location;
      _lecturerController.text = widget.lecture!.lecturerName;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeStartController.dispose();
    _timeEndController.dispose();
    _locationController.dispose();
    _lecturerController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(
    TextEditingController controller,
    String label,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        // Convert to HH:MM format (24-hour)
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        controller.text = '$hour:$minute';
      });
    }
  }

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  String _formatTimeForDisplay(String time24) {
    // Convert 24-hour format (HH:MM) to 12-hour format for display
    final parts = time24.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];

    if (hour == 0) {
      return '12:$minute AM';
    } else if (hour < 12) {
      return '$hour:$minute AM';
    } else if (hour == 12) {
      return '12:$minute PM';
    } else {
      return '${hour - 12}:$minute PM';
    }
  }

  Future<void> _saveLecture() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one day'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final lectureProvider = Provider.of<LectureProvider>(
        context,
        listen: false,
      );
      bool success;

      if (widget.lecture != null) {
        // Update existing lecture
        success = await lectureProvider.updateLecture(
          id: widget.lecture!.id,
          title: _titleController.text.trim(),
          timeStart: _timeStartController.text.trim(),
          timeEnd: _timeEndController.text.trim(),
          days: _selectedDays,
          location: _locationController.text.trim(),
          lecturerName: _lecturerController.text.trim(),
        );
      } else {
        // Create new lecture
        success = await lectureProvider.createLecture(
          title: _titleController.text.trim(),
          timeStart: _timeStartController.text.trim(),
          timeEnd: _timeEndController.text.trim(),
          days: _selectedDays,
          location: _locationController.text.trim(),
          lecturerName: _lecturerController.text.trim(),
        );
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.lecture != null
                  ? 'Lecture updated successfully'
                  : 'Lecture created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lecture != null ? 'Edit Lecture' : 'Add Lecture'),
        actions: [
          IconButton(onPressed: _saveLecture, icon: const Icon(Icons.save)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Lecture Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a lecture title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Time Start
              TextFormField(
                controller: _timeStartController,
                decoration: InputDecoration(
                  labelText: 'Start Time (HH:MM format)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.access_time),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.schedule),
                    onPressed: () =>
                        _selectTime(_timeStartController, 'Start Time'),
                  ),
                  hintText: 'Tap clock to select time',
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select start time';
                  }
                  // Validate HH:MM format
                  final timeRegex = RegExp(
                    r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$',
                  );
                  if (!timeRegex.hasMatch(value)) {
                    return 'Invalid time format. Use HH:MM';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Time End
              TextFormField(
                controller: _timeEndController,
                decoration: InputDecoration(
                  labelText: 'End Time (HH:MM format)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.access_time),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.schedule),
                    onPressed: () =>
                        _selectTime(_timeEndController, 'End Time'),
                  ),
                  hintText: 'Tap clock to select time',
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select end time';
                  }
                  // Validate HH:MM format
                  final timeRegex = RegExp(
                    r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$',
                  );
                  if (!timeRegex.hasMatch(value)) {
                    return 'Invalid time format. Use HH:MM';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Days Selection
              const Text(
                'Select Days:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableDays.map((day) {
                  final isSelected = _selectedDays.contains(day);
                  return FilterChip(
                    label: Text(day),
                    selected: isSelected,
                    onSelected: (_) => _toggleDay(day),
                    selectedColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Lecturer Name
              TextFormField(
                controller: _lecturerController,
                decoration: const InputDecoration(
                  labelText: 'Lecturer Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter lecturer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Save Button
              Consumer<LectureProvider>(
                builder: (context, lectureProvider, child) {
                  return ElevatedButton(
                    onPressed: lectureProvider.isLoading ? null : _saveLecture,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: lectureProvider.isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            widget.lecture != null
                                ? 'Update Lecture'
                                : 'Create Lecture',
                          ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Error Display
              if (Provider.of<LectureProvider>(context).error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    Provider.of<LectureProvider>(context).error!,
                    style: TextStyle(color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
