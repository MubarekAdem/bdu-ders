import 'package:flutter/material.dart';
import 'lecture_management_screen.dart';
import 'previous_lecture_management_screen.dart';
import 'lecture_availability_screen.dart';

class AdminTab extends StatelessWidget {
  const AdminTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Admin actions
            _AdminActionCard(
              title: 'Manage Lectures',
              subtitle: 'Add, edit, or delete lecture schedules',
              icon: Icons.schedule,
              color: Theme.of(context).colorScheme.primary,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LectureManagementScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _AdminActionCard(
              title: 'Previous Lectures',
              subtitle: 'Manage recorded lecture links',
              icon: Icons.video_library,
              color: Theme.of(context).colorScheme.secondary,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const PreviousLectureManagementScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _AdminActionCard(
              title: 'Lecture Availability',
              subtitle: 'Manage lecture availability by day of week',
              icon: Icons.event_available,
              color: Colors.orange,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LectureAvailabilityScreen(),
                  ),
                );
              },
            ),
            const SizedBox(
              height: 24,
            ), // Extra bottom padding for better scrolling
          ],
        ),
      ),
    );
  }
}

class _AdminActionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_AdminActionCard> createState() => _AdminActionCardState();
}

class _AdminActionCardState extends State<_AdminActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: widget.color, width: 2),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTapDown: (_) => _animationController.forward(),
              onTapUp: (_) => _animationController.reverse(),
              onTapCancel: () => _animationController.reverse(),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: widget.color, width: 2),
                      ),
                      child: Icon(widget.icon, color: widget.color, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: widget.color,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
