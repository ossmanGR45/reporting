import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/widgets/ActionButton.dart';
import '../../core/theme/widgets/stat_card.dart';
import '../../core/theme/widgets/update_tile.dart';
import '../../services/firebase_service.dart';
import '../../models/issue_model.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseService _service = FirebaseService();
  late final Stream<List<Issue>> _myIssuesStream;

  @override
  void initState() {
    super.initState();
    _myIssuesStream = _service.streamUserIssues();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // Try to use a friendly first name for the greeting. Fall back to email prefix or 'Guest'.
    final String? firstName = (user?.displayName != null && user!.displayName!.isNotEmpty)
      ? user.displayName?.split(' ').first
      : (user?.email != null ? user!.email?.split('@').first : 'Guest');

    return Scaffold(
     appBar: AppBar(
        title: const Text('TalkToRepair'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      // BottomNavigationBar is provided by the  (app router) for easy navigation
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1 of the home page
            Text('Welcome, $firstName',
                style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
               const Text('How can we help you today?',
                style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 20),

            // Section 2 - Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ActionButton(
                  icon: Icons.report_problem,
                  label: 'Report Issue',
                  //onTap: () => Navigator.pushNamed(context, '/report'),
                  onTap: () => context.go('/report'),
                ),
                
              ],
            ),

            const SizedBox(height: 30),

            // Section 3 - Recent Updates (live)
            const Text('Recent Updates',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            StreamBuilder<List<Issue>>(
              stream: _myIssuesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final issues = snapshot.data ?? [];
                if (issues.isEmpty) {
                  return const Text('No updates yet');
                }
                final recent = issues.take(3).toList();
                return Column(
                  children: recent
                      .map((i) => UpdateTile(
                            title: '${i.title} — ${i.category}',
                            time: '${i.createdAt.month}/${i.createdAt.day} ${i.createdAt.hour}:${i.createdAt.minute.toString().padLeft(2, '0')}',
                          ))
                      .toList(),
                );
              },
            ),

            const SizedBox(height: 30),

            // Section 4  - Quick Stats (live)
            const Text('Quick Stats',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            StreamBuilder<List<Issue>>(
              stream: _myIssuesStream,
              builder: (context, snapshot) {
                final issues = snapshot.data ?? [];
                final total = issues.length;
                final resolved = issues.where((i) => i.status == 'resolved').length;
                final active = issues.where((i) => i.status != 'resolved' && i.status != 'closed').length;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatCard(label: 'Total', value: total, color: Colors.blue),
                    StatCard(label: 'Active', value: active, color: Colors.orange),
                    StatCard(label: 'Resolved', value: resolved, color: Colors.green),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}