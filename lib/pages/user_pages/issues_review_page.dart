import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/issue_model.dart';
import '../../services/firebase_service.dart';

class IssuesPage extends StatefulWidget {
  const IssuesPage({super.key});

  @override
  State<IssuesPage> createState() => _IssuesPageState();
}

class _IssuesPageState extends State<IssuesPage> {
  final FirebaseService _firebaseService = FirebaseService();
  late Stream<List<Issue>> _issuesStream;

  @override
  void initState() {
    super.initState();
    _issuesStream = _firebaseService.streamUserIssues();
  }

  String _getStatusColor(String status) {
    switch (status) {
      case 'reported':
        return '#FFA500';
      case 'in_progress':
        return '#4169E1';
      case 'resolved':
        return '#32CD32';
      case 'closed':
        return '#808080';
      default:
        return '#808080';
    }
  }

  String _getPriorityLabel(String? priority) {
    switch (priority) {
      case 'high':
        return '🔴 High';
      case 'medium':
        return '🟡 Medium';
      case 'low':
        return '🟢 Low';
      default:
        return '🟡 Medium';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Issues'),
        elevation: 1,
      ),
      body: StreamBuilder<List<Issue>>(
        stream: _issuesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final issues = snapshot.data ?? [];

          if (issues.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No issues reported yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/report'),
                    child: const Text('Report an Issue'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue = issues[index];
              return _buildIssueCard(context, issue);
            },
          );
        },
      ),
    );
  }

  Widget _buildIssueCard(BuildContext context, Issue issue) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: () => context.push('/issue_details/${issue.id}'),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              issue.category.substring(0, 2).toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ),
        title: Text(
          issue.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              issue.location,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(_getStatusColor(issue.status).replaceFirst('#', '0xff')),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    issue.status.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getPriorityLabel(issue.priority),
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
