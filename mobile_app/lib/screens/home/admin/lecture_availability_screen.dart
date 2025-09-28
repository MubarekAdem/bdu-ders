import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/lecture_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/lecture.dart';

class LectureAvailabilityScreen extends StatefulWidget {
  const LectureAvailabilityScreen({super.key});

  @override
  State<LectureAvailabilityScreen> createState() =>
      _LectureAvailabilityScreenState();
}

class _LectureAvailabilityScreenState extends State<LectureAvailabilityScreen> {
  String _selectedDay = 'Monday';
  String? _selectedLectureId;

  final List<String> _days = [
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LectureProvider>(context, listen: false).loadLectures();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecture Availability Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Day selector
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _days.length,
              itemBuilder: (context, index) {
                final day = _days[index];
                final isSelected = day == _selectedDay;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(day),
                    selected: isSelected,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    selectedColor: Theme.of(context).colorScheme.secondary,
                    checkmarkColor: Theme.of(context).colorScheme.onSecondary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onSecondary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedDay = day;
                        _selectedLectureId = null;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(),
          // Lecture list for selected day
          Expanded(
            child: Consumer<LectureProvider>(
              builder: (context, lectureProvider, child) {
                if (lectureProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (lectureProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          lectureProvider.error!,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            lectureProvider.loadLectures();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final dayLectures = lectureProvider.getLecturesByDay(
                  _selectedDay,
                );

                if (dayLectures.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No lectures scheduled for $_selectedDay',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dayLectures.length,
                  itemBuilder: (context, index) {
                    final lecture = dayLectures[index];
                    return AvailabilityCard(
                      lecture: lecture,
                      selectedDay: _selectedDay,
                      isSelected: _selectedLectureId == lecture.id,
                      onTap: () {
                        setState(() {
                          _selectedLectureId = _selectedLectureId == lecture.id
                              ? null
                              : lecture.id;
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AvailabilityCard extends StatelessWidget {
  final Lecture lecture;
  final String selectedDay;
  final bool isSelected;
  final VoidCallback onTap;

  const AvailabilityCard({
    super.key,
    required this.lecture,
    required this.selectedDay,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = lecture.isAvailableForDay(selectedDay);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 8 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : isAvailable
              ? Colors.green
              : Colors.red,
          width: isSelected ? 3 : 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lecture.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  // Availability status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isAvailable ? Colors.green : Colors.red,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      isAvailable ? 'Available' : 'ደርስ የለም',
                      style: TextStyle(
                        color: isAvailable ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${lecture.timeStart} - ${lecture.timeEnd}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lecture.location,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    lecture.lecturerName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (isSelected) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final isAdmin = authProvider.user?.role == 'admin';

                    if (!isAdmin) return const SizedBox.shrink();

                    return Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _toggleAvailability(context),
                            icon: Icon(
                              isAvailable ? Icons.cancel : Icons.check_circle,
                              size: 16,
                            ),
                            label: Text(
                              isAvailable ? 'ደርስ የለም አድርግ' : 'Set Available',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAvailable
                                  ? Colors.red
                                  : Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _toggleAvailability(BuildContext context) {
    final lectureProvider = Provider.of<LectureProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          lecture.isAvailableForDay(selectedDay)
              ? 'ደርስ የለም አድርግ ለሁሉም $selectedDay'
              : 'Set Lecture Available for All $selectedDay',
        ),
        content: Text(
          lecture.isAvailableForDay(selectedDay)
              ? 'Are you sure you want to make "${lecture.title}" unavailable for ALL $selectedDay? This will affect every $selectedDay.'
              : 'Are you sure you want to make "${lecture.title}" available for ALL $selectedDay? This will affect every $selectedDay.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await lectureProvider.updateLectureAvailability(
                id: lecture.id,
                day: selectedDay,
                available: !lecture.isAvailableForDay(selectedDay),
              );
            },
            child: Text(
              lecture.isAvailableForDay(selectedDay)
                  ? 'ደርስ የለም አድርግ ለሁሉም $selectedDay'
                  : 'Set Available for All $selectedDay',
            ),
          ),
        ],
      ),
    );
  }
}
