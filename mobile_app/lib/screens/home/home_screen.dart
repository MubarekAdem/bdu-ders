import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lecture_provider.dart';
import '../../providers/previous_lecture_provider.dart';
import '../auth/login_screen.dart';
import 'tabs/schedule_tab.dart';
import 'tabs/previous_lectures_tab.dart';
import 'tabs/profile_tab.dart';
import 'admin/admin_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const ScheduleTab(),
    const PreviousLecturesTab(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      Provider.of<LectureProvider>(context, listen: false).loadLectures(),
      Provider.of<PreviousLectureProvider>(
        context,
        listen: false,
      ).fetchPreviousLectures(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Authentication guard - redirect to login if no user data
    if (!authProvider.isAuthenticated || authProvider.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isAdmin = authProvider.user?.role == 'admin';

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: isAdmin ? [..._tabs, const AdminTab()] : _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Lectures',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          if (isAdmin)
            const BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
        ],
      ),
    );
  }
}
