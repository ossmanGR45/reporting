import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/firebase_service.dart';
import '../../models/issue_model.dart';
import '../../models/user_model.dart';
import 'admin_dashboard.dart';
import '../user_pages/profile.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final FirebaseService _firebaseService = FirebaseService();
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const AdminStatsPage(),
      const AdminDashboard(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Only allow access for admin users
    return FutureBuilder<AppUser?>(
      future: _firebaseService.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;
        if (user == null || user.userType != 'admin') {
          return Scaffold(
            appBar: AppBar(title: const Text('Admin')),
            body: const Center(child: Text('Not authorized to view admin pages')),
          );
        }

        return Scaffold(
          
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
              BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Issues'),
              BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
            ],
          ),
        );
      },
    );
  }
}

class AdminStatsPage extends StatelessWidget {
  const AdminStatsPage({super.key});

  Future<Map<String, int>> _computeStats() async {
    final issues = await FirebaseService().getAllIssues();
    final total = issues.length;
    final reported = issues.where((i) => i.status == 'reported').length;
    final inProgress = issues.where((i) => i.status == 'in_progress').length;
    final resolved = issues.where((i) => i.status == 'resolved').length;
    final closed = issues.where((i) => i.status == 'closed').length;

    return {
      'total': total,
      'reported': reported,
      'in_progress': inProgress,
      'resolved': resolved,
      'closed': closed,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _computeStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final stats = snapshot.data ?? {};

        Widget _statCard(String label, int value, Color color) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(value.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
            );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Overview', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _statCard('Total Issues', stats['total'] ?? 0, Colors.blue),
                  _statCard('Reported', stats['reported'] ?? 0, Colors.orange),
                  _statCard('In Progress', stats['in_progress'] ?? 0, Colors.indigo),
                  _statCard('Resolved', stats['resolved'] ?? 0, Colors.green),
                ],
              ),
              const SizedBox(height: 24),
              Text('Recent Issues', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              FutureBuilder<List<Issue>>(
                future: FirebaseService().getAllIssues(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  final list = snap.data ?? [];
                  if (list.isEmpty) return const Text('No issues');
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: list.length > 5 ? 5 : list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final issue = list[idx];
                      return ListTile(
                        title: Text(issue.title),
                        subtitle: Text('${issue.category} • ${issue.location}'),
                        trailing: Text(issue.status.replaceAll('_', ' ')),
                        onTap: () => context.push('/issue_details/${issue.id}'),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
