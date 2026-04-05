import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/issue_model.dart';
import '../../services/firebase_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<Issue>> _issuesFuture;

  @override
  void initState() {
    super.initState();
    _issuesFuture = _firebaseService.getAllIssues();
  }

  Future<void> _refresh() async {
    setState(() {
      _issuesFuture = _firebaseService.getAllIssues();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 1,
      ),
      body: FutureBuilder(
        future: _firebaseService.getCurrentUser(),
        builder: (context, authSnap) {
          if (authSnap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final user = authSnap.data;
          if (user == null || user.userType != 'admin') {
            return const Center(child: Text('Not authorized to view admin pages'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: FutureBuilder<List<Issue>>(
              future: _issuesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final issues = snapshot.data ?? [];
                if (issues.isEmpty) {
                  return const Center(child: Text('No issues found'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: issues.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final issue = issues[idx];
                    return Card(
                      child: ListTile(
                        title: Text(issue.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${issue.category} • ${issue.location}'),
                            const SizedBox(height: 4),
                            Text('By: ${issue.userId}'),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'view') {
                              if (context.mounted) context.push('/issue_details/${issue.id}');
                            } else if (value == 'delete') {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete issue?'),
                                  content: const Text('This will permanently delete the issue.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                await _firebaseService.deleteIssue(issue.id);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Issue deleted')));
                                _refresh();
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'view', child: Text('View')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () => context.push('/issue_details/${issue.id}'),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
} 