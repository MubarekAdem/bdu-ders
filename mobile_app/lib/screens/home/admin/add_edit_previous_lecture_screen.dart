import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/previous_lecture_provider.dart';
import '../../../models/previous_lecture.dart';

class AddEditPreviousLectureScreen extends StatefulWidget {
  final PreviousLecture? lecture;

  const AddEditPreviousLectureScreen({super.key, this.lecture});

  @override
  State<AddEditPreviousLectureScreen> createState() =>
      _AddEditPreviousLectureScreenState();
}

class _AddEditPreviousLectureScreenState
    extends State<AddEditPreviousLectureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _telegramLinkController = TextEditingController();
  DateTime? _selectedDate;

  bool get _isEditing => widget.lecture != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.lecture!.title;
      _telegramLinkController.text = widget.lecture!.telegramLink;
      _selectedDate = widget.lecture!.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _telegramLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Previous Lecture' : 'Add Previous Lecture',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isEditing)
            IconButton(icon: const Icon(Icons.save), onPressed: _saveLecture),
        ],
      ),
      body: Consumer<PreviousLectureProvider>(
        builder: (context, provider, child) {
          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lecture Details',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Lecture Title',
                              hintText: 'Enter the lecture title',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a lecture title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _selectDate,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _selectedDate != null
                                        ? 'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                        : 'Select Lecture Date',
                                    style: TextStyle(
                                      color: _selectedDate != null
                                          ? Colors.black
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_selectedDate == null &&
                              _formKey.currentState?.validate() == false)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Please select a date',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _telegramLinkController,
                            decoration: const InputDecoration(
                              labelText: 'Telegram Link',
                              hintText: 'https://t.me/...',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.telegram),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a telegram link';
                              }
                              if (!value.startsWith('https://t.me/') &&
                                  !value.startsWith('http://t.me/')) {
                                return 'Please enter a valid telegram link';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'The telegram link will open the recording when students tap on it',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!_isEditing)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : _saveLecture,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: provider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                _isEditing ? 'Update Lecture' : 'Add Lecture',
                              ),
                      ),
                    ),
                  if (provider.error != null)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.error!,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => provider.clearError(),
                            color: Colors.red[700],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _saveLecture() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a date'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final provider = context.read<PreviousLectureProvider>();
    bool success;

    if (_isEditing) {
      success = await provider.updatePreviousLecture(
        id: widget.lecture!.id,
        title: _titleController.text.trim(),
        date: _selectedDate!,
        telegramLink: _telegramLinkController.text.trim(),
      );
    } else {
      success = await provider.createPreviousLecture(
        title: _titleController.text.trim(),
        date: _selectedDate!,
        telegramLink: _telegramLinkController.text.trim(),
      );
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Previous lecture updated successfully'
                : 'Previous lecture added successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }
}
