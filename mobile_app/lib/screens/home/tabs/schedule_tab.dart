import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/lecture_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/lecture.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDay = 'Monday';

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
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LectureProvider>(context, listen: false).loadLectures();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecture Schedule'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(
            context,
          ).colorScheme.onPrimary.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTodaysLectures(), _buildAllLectures()],
      ),
    );
  }

  Widget _buildTodaysLectures() {
    return Consumer<LectureProvider>(
      builder: (context, lectureProvider, child) {
        if (lectureProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (lectureProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
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

        final todaysLectures = lectureProvider.getTodaysLectures();

        if (todaysLectures.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_available, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No lectures scheduled for today',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: todaysLectures.length,
          itemBuilder: (context, index) {
            final lecture = todaysLectures[index];
            return LectureCard(lecture: lecture);
          },
        );
      },
    );
  }

  Widget _buildAllLectures() {
    return Column(
      children: [
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
                    });
                  },
                ),
              );
            },
          ),
        ),
        const Divider(),
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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
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
                  return LectureCard(lecture: lecture);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class LectureCard extends StatefulWidget {
  final Lecture lecture;

  const LectureCard({super.key, required this.lecture});

  @override
  State<LectureCard> createState() => _LectureCardState();
}

class _LectureCardState extends State<LectureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LectureProvider>(
      builder: (context, lectureProvider, child) {
        final updatedLecture = lectureProvider.lectures.firstWhere(
          (lecture) => lecture.id == widget.lecture.id,
          orElse: () => widget.lecture,
        );

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: updatedLecture.isAvailableForToday ? 3 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: updatedLecture.isAvailableForToday
                          ? (updatedLecture.isMarkedForToday
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.primary)
                          : Colors.grey,
                      width: 2,
                    ),
                  ),
                  color: updatedLecture.isAvailableForToday
                      ? null
                      : Colors.grey[100],
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    updatedLecture.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              updatedLecture.isAvailableForToday
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.onSurface
                                              : Colors.grey[600],
                                        ),
                                  ),
                                ),
                                // Availability status
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: updatedLecture.isAvailableForToday
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: updatedLecture.isAvailableForToday
                                          ? Colors.green
                                          : Colors.red,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    updatedLecture.isAvailableForToday
                                        ? 'Available'
                                        : 'Unavailable',
                                    style: TextStyle(
                                      color: updatedLecture.isAvailableForToday
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${updatedLecture.timeStart} - ${updatedLecture.timeEnd}',
                                  style: TextStyle(
                                    color: updatedLecture.isAvailableForToday
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onSurface
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    updatedLecture.location,
                                    style: TextStyle(
                                      color: updatedLecture.isAvailableForToday
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.onSurface
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  updatedLecture.lecturerName,
                                  style: TextStyle(
                                    color: updatedLecture.isAvailableForToday
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onSurface
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                final isAdmin =
                                    authProvider.user?.role == 'admin';

                                if (!isAdmin) return const SizedBox.shrink();

                                return Column(
                                  children: [
                                    const SizedBox(height: 12),
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    // Availability toggle
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            _showAvailabilityDialog(
                                              context,
                                              updatedLecture,
                                            ),
                                        icon: Icon(
                                          updatedLecture.isAvailableForToday
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          size: 16,
                                        ),
                                        label: Text(
                                          updatedLecture.isAvailableForToday
                                              ? 'Set Unavailable'
                                              : 'Set Available',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              updatedLecture.isAvailableForToday
                                              ? Colors.red
                                              : Colors.green,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAvailabilityDialog(BuildContext context, Lecture lecture) {
    final lectureProvider = Provider.of<LectureProvider>(
      context,
      listen: false,
    );

    final today = DateTime.now();
    final todayString = _formatDateString(today);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          lecture.isAvailableForToday
              ? 'Set Lecture Unavailable for Today'
              : 'Set Lecture Available for Today',
        ),
        content: Text(
          lecture.isAvailableForToday
              ? 'Are you sure you want to make "${lecture.title}" unavailable for today (${_formatDisplayDate(today)})? This will only affect today, not future dates.'
              : 'Are you sure you want to make "${lecture.title}" available for today (${_formatDisplayDate(today)})? This will only affect today, not future dates.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await lectureProvider.updateLectureDateAvailability(
                id: lecture.id,
                date: todayString,
                available: !lecture.isAvailableForToday,
              );
            },
            child: Text(
              lecture.isAvailableForToday
                  ? 'Set Unavailable for Today'
                  : 'Set Available for Today',
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateString(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDisplayDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
