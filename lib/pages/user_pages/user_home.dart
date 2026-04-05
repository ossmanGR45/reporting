import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/firebase_service.dart';
import '../../models/user_model.dart';
import 'home_page.dart';
import 'issues_review_page.dart';
import 'notification_page.dart';
import 'profile.dart';

// A StatefulWidget holds mutable state that can change over time (unlike a StatelessWidget).
// The `override` annotation marks methods that replace behavior in the superclass, and
// `super` is used to call the parent class implementation when needed.
class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
} 

class _UserHomeState extends State<UserHome> {
  final FirebaseService _firebaseService = FirebaseService();
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    // initState: lifecycle method called once when the widget is inserted into the widget tree.
    // Call `super.initState()` to ensure the base class can perform its initialization.
    super.initState();
    _pages = const [
      HomePage(),
      IssuesPage(),
      NotificationPage(),
      ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // FutureBuilder: builds UI based on the result of a Future.
    // A `Future<T>` represents a single asynchronous value that will be available later (use `await` to get it).
    return FutureBuilder<AppUser?>(
      future: _firebaseService.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;
        if (user != null && user.userType == 'admin') {
          // If an admin navigates to user home, redirect them to admin home
          // `addPostFrameCallback` runs this callback after the current frame is rendered;
          // useful to safely call navigation inside build without causing frame errors.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/admin');
          });
          return const Scaffold();
        }

        return Scaffold(
          body: _pages[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Issues'),
              BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}
