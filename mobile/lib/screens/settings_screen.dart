import 'package:flutter/material.dart';
import 'package:aqua_sense/models/user.dart';
import 'package:aqua_sense/services/auth_service.dart';
import 'package:aqua_sense/widgets/loading_indicator.dart';
import 'package:aqua_sense/widgets/error_display.dart';
import 'package:aqua_sense/widgets/custom_card.dart';
import 'package:aqua_sense/utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  User? _user;
  Map<String, bool> _settings = {};

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
      
      if (_user != null) {
        _settings = Map.from(_user!.appSettings);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load settings: ${e.toString()}';
      });
    }
  }

  Future<void> _updateSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      await authService.updateSettings(_settings);
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings updated successfully')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to update settings: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                          // Notifications settings
                          CustomCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Notifications',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildSwitchRow(
                                  'Enable Notifications',
                                  _settings['notifications'] ?? true,
                                  (value) {
                                    setState(() {
                                      _settings['notifications'] = value;
                                    });
                                  },
                                ),
                                _buildSwitchRow(
                                  'Water Level Alerts',
                                  _settings['waterAlerts'] ?? true,
                                  (value) {
                                    setState(() {
                                      _settings['waterAlerts'] = value;
                                    });
                                  },
                                ),
                                _buildSwitchRow(
                                  'Weather Alerts',
                                  _settings['weatherAlerts'] ?? true,
                                  (value) {
                                    setState(() {
                                      _settings['weatherAlerts'] = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // App settings
                          CustomCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'App Settings',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildSwitchRow(
                                  'Dark Mode',
                                  _settings['darkMode'] ?? false,
                                  (value) {
                                    setState(() {
                                      _settings['darkMode'] = value;
                                    });
                                  },
                                ),
                                _buildSwitchRow(
                                  'Data Synchronization',
                                  _settings['dataSync'] ?? true,
                                  (value) {
                                    setState(() {
                                      _settings['dataSync'] = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Units settings
                          CustomCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Units',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildDropdownRow(
                                  'Temperature',
                                  ['Celsius', 'Fahrenheit'],
                                  'Celsius',
                                  (value) {
                                    // Update temperature unit
                                  },
                                ),
                                _buildDropdownRow(
                                  'Distance',
                                  ['Kilometers', 'Miles'],
                                  'Kilometers',
                                  (value) {
                                    // Update distance unit
                                  },
                                ),
                                _buildDropdownRow(
                                  'Area',
                                  ['Hectares', 'Acres'],
                                  'Hectares',
                                  (value) {
                                    // Update area unit
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Data management
                          CustomCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Data Management',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildActionRow(
                                  'Export Data',
                                  Icons.download,
                                  () {
                                    // Export data
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Data exported successfully')),
                                    );
                                  },
                                ),
                                _buildActionRow(
                                  'Clear Cache',
                                  Icons.cleaning_services,
                                  () {
                                    // Clear cache
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Clear Cache'),
                                        content: const Text('Are you sure you want to clear the app cache? This will not delete any of your data.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Cache cleared successfully')),
                                              );
                                            },
                                            child: const Text('Clear'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                _buildActionRow(
                                  'Delete Account',
                                  Icons.delete_forever,
                                  () {
                                    // Delete account
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Account'),
                                        content: const Text('Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              // Delete account logic
                                              Navigator.pushReplacementNamed(context, '/login');
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // About
                          CustomCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'About',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildActionRow(
                                  'App Version',
                                  Icons.info,
                                  () {
                                    // Show app version
                                  },
                                  trailing: const Text('1.0.0'),
                                ),
                                _buildActionRow(
                                  'Terms of Service',
                                  Icons.description,
                                  () {
                                    // Show terms of service
                                  },
                                ),
                                _buildActionRow(
                                  'Privacy Policy',
                                  Icons.privacy_tip,
                                  () {
                                    // Show privacy policy
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Save button
                          ElevatedButton(
                            onPressed: _updateSettings,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text('Save Settings'),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildSwitchRow(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(String title, List<String> options, String value, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(String title, IconData icon, VoidCallback onTap, {Color? color, Widget? trailing}) {
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
            trailing ??
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

