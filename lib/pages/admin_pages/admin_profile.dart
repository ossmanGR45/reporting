import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<AppUser>> _usersFuture;
  late Future<AppUser?> _currentUserFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _firebaseService.getAllUsers();
    _currentUserFuture = _firebaseService.getCurrentUser();
  }

  Future<void> _refresh() async {
    setState(() {
      _usersFuture = _firebaseService.getAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Manage Users')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<AppUser>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final users = snapshot.data ?? [];
            if (users.isEmpty) {
              return const Center(child: Text('No users found'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final user = users[idx];
                return FutureBuilder<AppUser?>(
                  future: _currentUserFuture,
                  builder: (context, curSnap) {
                    final current = curSnap.data;
                    final isSelf = current != null && current.id == user.id;

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: Text(
                            (user.displayName.isNotEmpty ? user.displayName.substring(0,1) : user.email.substring(0,1)).toUpperCase(),
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),
                        title: Text(user.displayName.isNotEmpty ? user.displayName : user.email),
                        subtitle: Text(user.email),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DropdownButton<String>(
                              value: user.userType,
                              items: const [
                                DropdownMenuItem(value: 'citizen', child: Text('Citizen')),
                                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                              ],
                              onChanged: (val) async {
                                if (val == null) return;
                                await _firebaseService.updateUserType(user.id, val);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User role updated')));
                                  _refresh();
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: isSelf ? null : () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete user?'),
                                    content: const Text('This will remove the user document from the database (does not delete Auth account).'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                      TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                );
                                if (ok == true) {
                                  await _firebaseService.deleteUser(user.id);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User deleted')));
                                    _refresh();
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
