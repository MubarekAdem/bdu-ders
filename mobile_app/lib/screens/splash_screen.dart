import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Check if there's a stored token first
      final storedToken = await ApiService.getToken();
      print('Stored token: ${storedToken != null ? "EXISTS" : "NULL"}');

      if (storedToken == null) {
        // No token stored, go directly to login
        print('No token found, going to login screen');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return;
      }

      // Validate if the stored token is still valid and fetch user data
      print('Validating token and fetching user data...');
      final isValidToken = await ApiService.validateToken();
      print('Token validation result: $isValidToken');

      if (isValidToken) {
        // Fetch user data and set it in AuthProvider
        try {
          final response = await ApiService.get('/auth/me');
          if (response['user'] != null) {
            authProvider.setUserFromJson(response['user']);
            print('User data loaded successfully');
          }
        } catch (e) {
          print('Error fetching user data: $e');
          // If we can't fetch user data, clear token and go to login
          await ApiService.clearToken();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
          return;
        }

        // User has a valid token and data, go to home screen
        print('Valid token and user data, going to home screen');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // User is not logged in or token is invalid, go to login screen
        print('Invalid token, going to login screen');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 100,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(height: 20),
            Text(
              'Lecture Scheduler',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Manage your lectures efficiently',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 40),
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(height: 40),
            // Temporary buttons for debugging
            Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await ApiService.clearToken();
                    print('Token cleared manually');
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text('Clear Data & Go to Login'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    final token = await ApiService.getToken();
                    print('Current token: $token');
                    final isValid = await ApiService.validateToken();
                    print('Token valid: $isValid');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Token exists: ${token != null}, Valid: $isValid',
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.onPrimary.withOpacity(0.8),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text('Check Token Status'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
