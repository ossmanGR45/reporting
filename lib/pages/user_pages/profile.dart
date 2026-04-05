import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Future<AppUser?> _userFuture;

  bool _isEditing = false;
  bool _controllersInitialized = false;

  late TextEditingController _displayNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    _userFuture = _firebaseService.getCurrentUser();
    _displayNameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _initializeControllers(AppUser user) {
    // If displayName is empty, derive a friendly first name from the email
    if (user.displayName.isEmpty) {
      final fallback = (user.email.isNotEmpty) ? user.email.split('@').first : '';
      _displayNameController.text = fallback;
    } else {
      _displayNameController.text = user.displayName;
    }
    _phoneController.text = user.phoneNumber ?? '';
    _addressController.text = user.address ?? '';
    _cityController.text = user.city ?? '';
  }

  Future<void> _updateProfile() async {
    try {
      await _firebaseService.updateUserProfile(
        displayName: _displayNameController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
        city: _cityController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        setState(() {
          _userFuture = _firebaseService.getCurrentUser();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 1,
      ),
      body: FutureBuilder<AppUser?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

              final user = snapshot.data;
          if (user == null) {
            return const Center(
              child: Text('User not found'),
            );
          }

              // Initialize controllers once when data first arrives
              if (!_controllersInitialized) {
                _initializeControllers(user);
                _controllersInitialized = true;
              }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue[100],
                        ),
                        child: Center(
                          child: Text(
                            (user.displayName.isNotEmpty
                                    ? user.displayName.substring(0, 1)
                                    : user.email.substring(0, 1))
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                          Text(
                            (user.displayName.isNotEmpty
                                ? user.displayName.split(' ').first
                                : user.email.split('@').first),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Edit button in app UI
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!_isEditing)
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      )
                    else
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await _updateProfile();
                              setState(() {
                                _isEditing = false;
                                _controllersInitialized = false; // re-init on next fetch
                              });
                            },
                            child: const Text('Save'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {
                              // revert changes
                              _initializeControllers(user);
                              setState(() {
                                _isEditing = false;
                              });
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                  ],
                ),

                // Account Information
                Text(
                  'Account Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _buildTextField('Display Name', _displayNameController, enabled: _isEditing),
                const SizedBox(height: 12),
                _buildTextField('Email', TextEditingController(text: user.email), enabled: false),
                const SizedBox(height: 12),
                _buildTextField('Phone Number', _phoneController, enabled: _isEditing),
                const SizedBox(height: 24),

                // Location Information
                Text(
                  'Location',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _buildTextField('Address', _addressController, enabled: _isEditing),
                const SizedBox(height: 12),
                _buildTextField('City', _cityController, enabled: _isEditing),
                const SizedBox(height: 24),

                // Account Statistics
                Text(
                  'Account Statistics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'User Type',
                        user.userType.toUpperCase(),
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Member Since',
                        '${user.createdAt.month}/${user.createdAt.day}/${user.createdAt.year}',
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Admin Panel access
                if (user.userType == 'admin')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text('Admin Panel'),
                      onPressed: () {
                        if (mounted) context.go('/admin');
                      },
                    ),
                  ),
                const SizedBox(height: 12),

                // Update Button (only visible while editing)
                if (_isEditing)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _updateProfile();
                        if (mounted) {
                          setState(() {
                            _isEditing = false;
                            _controllersInitialized = false;
                            _userFuture = _firebaseService.getCurrentUser();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                const SizedBox(height: 12),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await _auth.signOut();
                      if (mounted) context.go('/login');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
