import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:go_router/go_router.dart';
import '../../models/issue_model.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';

class IssueDetailsPage extends StatefulWidget {
  final String issueId;

  const IssueDetailsPage({super.key, required this.issueId});

  @override
  State<IssueDetailsPage> createState() => _IssueDetailsPageState();
}

class _IssueDetailsPageState extends State<IssueDetailsPage> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<Issue?> _issueFuture;
  late Future<AppUser?> _authorFuture;
  late Future<AppUser?> _currentUserFuture;

  @override
  void initState() {
    super.initState();
    _issueFuture = _firebaseService.getIssueById(widget.issueId);
    _currentUserFuture = _firebaseService.getCurrentUser();
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
        return '🔴 High Priority';
      case 'medium':
        return '🟡 Medium Priority';
      case 'low':
        return '🟢 Low Priority';
      default:
        return '🟡 Medium Priority';
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Details'),
      ),
      body: FutureBuilder<Issue?>(
        future: _issueFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final issue = snapshot.data;
          if (issue == null) {
            return const Center(
              child: Text('Issue not found'),
            );
          }

          _authorFuture = _firebaseService.getUserById(issue.userId);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with images
                if (issue.imageUrls.isNotEmpty)
                  SizedBox(
                    height: 250,
                    child: PageView.builder(
                      itemCount: issue.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: Text(
                              'Image ${index + 1}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        issue.title,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 12),

                      // Status and Priority
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Color(
                                int.parse(_getStatusColor(issue.status)
                                    .replaceFirst('#', '0xff')),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              issue.status
                                  .replaceAll('_', ' ')
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.amber[100],
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: Colors.amber[300]!),
                            ),
                            child: Text(
                              _getPriorityLabel(issue.priority),
                              style: TextStyle(
                                color: Colors.amber[900],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Location and Category
                      _buildInfoRow('📍 Location', issue.location),
                      const SizedBox(height: 8),
                      _buildInfoRow('📋 Category', issue.category),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          issue.description,
                          style: const TextStyle(
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Report Author
                      FutureBuilder<AppUser?>(
                        future: _authorFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox.shrink();
                          }

                          final author = snapshot.data;
                          if (author == null) return const SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reported by',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Colors.blue[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.blue[200],
                                      ),
                                      child: Center(
                                        child: Text(
                                              (author.displayName.isNotEmpty
                                                      ? author.displayName.substring(0, 1)
                                                      : author.email.substring(0, 1))
                                                  .toUpperCase(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              (author.displayName.isNotEmpty
                                                  ? author.displayName.split(' ').first
                                                  : author.email.split('@').first),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Reported on ${_formatDate(issue.createdAt)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Admin controls (status update, delete)
                      FutureBuilder<AppUser?>(
                        future: _currentUserFuture,
                        builder: (context, usnap) {
                          if (usnap.connectionState == ConnectionState.waiting) return const SizedBox.shrink();
                          final currentUser = usnap.data;
                          if (currentUser == null || currentUser.userType != 'admin') return const SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: issue.status,
                                      items: const [
                                        DropdownMenuItem(value: 'reported', child: Text('Reported')),
                                        DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                                        DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                                        DropdownMenuItem(value: 'closed', child: Text('Closed')),
                                      ],
                                      onChanged: (val) async {
                                        if (val == null) return;
                                        await _firebaseService.updateIssueStatus(issue.id, val);
                                        if (mounted) {
                                          setState(() {
                                            _issueFuture = _firebaseService.getIssueById(widget.issueId);
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated')));
                                        }
                                      },
                                      decoration: const InputDecoration(labelText: 'Change status'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                                    onPressed: () async {
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
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Issue deleted')));
                                          context.go('/issues');
                                        }
                                      }
                                    },
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      // Share button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Share feature coming soon!'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Share Issue'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
