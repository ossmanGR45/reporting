// lib/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
//import '../pages/user_pages/home_page.dart';
import '../pages/user_pages/report_page.dart';
import '../pages/user_pages/submit_confirmation_page.dart';
import '../pages/user_pages/issues_review_page.dart';
import '../pages/user_pages/notification_page.dart';
import '../pages/user_pages/profile.dart';
import '../pages/user_pages/issue_details_page.dart';
//import '../pages/admin_pages/admin_dashboard.dart';
import '../pages/admin_pages/admin_home.dart';
import '../pages/user_pages/user_home.dart';

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }
}

final _authChangeNotifier = _AuthChangeNotifier();

final _rootNavigatorKey = GlobalKey<NavigatorState>();
//final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  refreshListenable: _authChangeNotifier,
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final loggingIn = state.uri.path == '/login' || state.uri.path == '/register';

    if (!loggedIn && !loggingIn) {
      // not logged in -> go to /login
      return '/login';
    }
    if (loggedIn && loggingIn) {
      // already logged in -> go to home
      return '/home';
    }
    return null;
  },
  routes: [
    // Auth routes (use root navigator)
    GoRoute(path: '/login', builder: (context, _) => const LoginPage()),
    GoRoute(path: '/register', builder: (context, _) => const RegisterPage()),

    // User-specific home (user-only navbar). Admins are redirected to /admin
    GoRoute(path: '/home', builder: (context, state) => const UserHome()),

    // Keep the other routes available at top-level
    GoRoute(path: '/issues', builder: (context, state) => const IssuesPage()),
    GoRoute(path: '/notification', builder: (context, state) => const NotificationPage()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),

    // Admin routes
    GoRoute(path: '/admin', builder: (context, state) => const AdminHome()),

    GoRoute(path: '/report', builder: (context, state) => const ReportIssuePage()),
    GoRoute(
      path: '/issue_details/:issueId',
      builder: (context, state) {
        final issueId = state.pathParameters['issueId'] ?? '';
        return IssueDetailsPage(issueId: issueId);
      },
    ),

    // Submission confirmation expects navigation extras (Map) with keys:
    // referenceId, category, location, submittedAt
    GoRoute(
      path: '/submit_confirmation',
      builder: (context, state) {
        final extra = state.extra;
        String referenceId = '';
        String category = '';
        String location = '';
        DateTime submittedAt = DateTime.now();

        if (extra is Map<String, Object?>) {
          referenceId = (extra['referenceId'] as String?) ?? '';
          category = (extra['category'] as String?) ?? '';
          location = (extra['location'] as String?) ?? '';
          submittedAt = (extra['submittedAt'] as DateTime?) ?? DateTime.now();
        }

        return SubmissionConfirmationPage(
          referenceId: referenceId,
          category: category,
          location: location,
          submittedAt: submittedAt,
        );
      },
    ),
  ],
);

