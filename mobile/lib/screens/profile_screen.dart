import 'package:flutter/material.dart';
import 'package:aqua_sense/models/user.dart';
import 'package:aqua_sense/services/auth_service.dart';
import 'package:aqua_sense/widgets/bottom_navigation.dart';
import 'package:aqua_sense/widgets/loading_indicator.dart';
import 'package:aqua_sense/widgets/error_display.dart';
import 'package:aqua_sense/widgets/custom_card.dart';
import 'package:aqua_sense/utils/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 4; // Profile tab
  bool _isLoading = true;
  String? _errorMessage;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      _user = authService.currentUser;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load profile: ${e.toString()}';
      });
    }
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });

      // Navigate to different screens based on the tab index
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/water_reservoirs');
          break;
        case 2:
          // Refresh action
          _loadData();
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/plants');
          break;
        case 4:
          // Already on profile screen
          break;
      }
    }
  }

  void _editProfile() {
    Navigator.pushNamed(context, '/edit_profile').then((_) => _loadData());
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authService = AuthService();
              await authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _loadData,
                )
              : _user == null
                  ? const ErrorDisplay(
                      message: 'User not found. Please login again.',
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile header
                          Center(
                            child: Column(
                              children: [
                                // Profile image
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                  backgroundImage: _user!.profileImage != null
                                      ? AssetImage(_user!.profileImage!)
                                      : null,
                                  child: _user!.profileImage == null
                                      ? Icon(
                                          Icons.person,
                                          size: 60,
                                          color: AppTheme.primaryColor,
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                
                                // User name
                                Text(
                                  _user!.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                
                                // User email
                                Text(
                                  _user!.email,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Edit profile button
                                OutlinedButton.icon(
                                  onPressed: _editProfile,
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Edit Profile'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Farm information
                          CustomCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Farm Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow('Farm Name', _user!.farmName ?? 'Not set'),
                                _buildInfoRow('Farm Size', _user!.farmSize != null ? '${_user!.farmSize} hectares' : 'Not set'),
                                _buildInfoRow('Address', _user!.address ?? 'Not set'),
                                _buildInfoRow('Phone', _user!.phoneNumber ?? 'Not set'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Preferred crops
                          CustomCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Preferred Crops',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () {
                                        // Edit preferred crops
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _user!.preferredCrops.isEmpty
                                    ? const Text(
                                        'No preferred crops set',
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      )
                                    : Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: _user!.preferredCrops.map((crop) {
                                          return Chip(
                                            label: Text(crop),
                                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                            labelStyle: TextStyle(
                                              color: AppTheme.primaryColor,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Account actions
                          CustomCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Account',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildActionRow(
                                  'Change Password',
                                  Icons.lock,
                                  () {
                                    // Navigate to change password screen
                                  },
                                ),
                                _buildActionRow(
                                  'Notifications',
                                  Icons.notifications,
                                  () {
                                    Navigator.pushNamed(context, '/notifications');
                                  },
                                ),
                                _buildActionRow(
                                  'Settings',
                                  Icons.settings,
                                  () {
                                    Navigator.pushNamed(context, '/settings');
                                  },
                                ),
                                _buildActionRow(
                                  'Help & Support',
                                  Icons.help,
                                  () {
                                    Navigator.pushNamed(context, '/faq');
                                  },
                                ),
                                _buildActionRow(
                                  'Logout',
                                  Icons.logout,
                                  _logout,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(String title, IconData icon, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: color ?? Colors.grey.shade700,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

