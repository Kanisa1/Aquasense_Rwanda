import 'package:flutter/material.dart';
import 'package:aqua_sense/models/user.dart';
import 'package:aqua_sense/services/auth_service.dart';
import 'package:aqua_sense/widgets/loading_indicator.dart';
import 'package:aqua_sense/widgets/error_display.dart';
import 'package:aqua_sense/widgets/custom_card.dart';
import 'package:aqua_sense/utils/app_theme.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  String? _errorMessage;
  User? _user;
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _farmSizeController = TextEditingController();
  
  List<String> _preferredCrops = [];
  String _newCrop = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _farmNameController.dispose();
    _farmSizeController.dispose();
    super.dispose();
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
        _nameController.text = _user!.name;
        _emailController.text = _user!.email;
        _phoneController.text = _user!.phoneNumber ?? '';
        _addressController.text = _user!.address ?? '';
        _farmNameController.text = _user!.farmName ?? '';
        _farmSizeController.text = _user!.farmSize?.toString() ?? '';
        _preferredCrops = List.from(_user!.preferredCrops);
      }

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

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        if (_user != null) {
          final updatedUser = User(
            id: _user!.id,
            name: _nameController.text,
            email: _emailController.text,
            profileImage: _user!.profileImage,
            phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
            address: _addressController.text.isEmpty ? null : _addressController.text,
            farmName: _farmNameController.text.isEmpty ? null : _farmNameController.text,
            farmSize: _farmSizeController.text.isEmpty ? null : double.parse(_farmSizeController.text),
            preferredCrops: _preferredCrops,
            appSettings: _user!.appSettings,
          );

          final authService = AuthService();
          await authService.updateProfile(updatedUser);
          
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to update profile: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // In a real app, you would upload the image to a server
      // and update the user's profile image URL
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated')),
      );
    }
  }

  void _addCrop() {
    if (_newCrop.isNotEmpty && !_preferredCrops.contains(_newCrop)) {
      setState(() {
        _preferredCrops.add(_newCrop);
        _newCrop = '';
      });
    }
  }

  void _removeCrop(String crop) {
    setState(() {
      _preferredCrops.remove(crop);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile picture
                            Center(
                              child: Stack(
                                children: [
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
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        onPressed: _pickImage,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Personal information
                            CustomCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Personal Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Full Name',
                                      prefixIcon: Icon(Icons.person),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon: Icon(Icons.email),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(
                                      labelText: 'Phone Number',
                                      prefixIcon: Icon(Icons.phone),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _addressController,
                                    decoration: const InputDecoration(
                                      labelText: 'Address',
                                      prefixIcon: Icon(Icons.location_on),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            
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
                                  TextFormField(
                                    controller: _farmNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Farm Name',
                                      prefixIcon: Icon(Icons.home),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _farmSizeController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Farm Size (hectares)',
                                      prefixIcon: Icon(Icons.crop_square),
                                    ),
                                    validator: (value) {
                                      if (value != null && value.isNotEmpty) {
                                        final farmSize = double.tryParse(value);
                                        if (farmSize == null) {
                                          return 'Please enter a valid number';
                                        }
                                        if (farmSize <= 0) {
                                          return 'Farm size must be greater than 0';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Preferred crops
                            CustomCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Preferred Crops',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: 'Add Crop',
                                            hintText: 'e.g. Corn',
                                            prefixIcon: Icon(Icons.grass),
                                          ),
                                          onChanged: (value) {
                                            _newCrop = value;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      ElevatedButton(
                                        onPressed: _addCrop,
                                        child: const Text('Add'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _preferredCrops.map((crop) {
                                      return Chip(
                                        label: Text(crop),
                                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                        labelStyle: TextStyle(
                                          color: AppTheme.primaryColor,
                                        ),
                                        deleteIcon: const Icon(
                                          Icons.close,
                                          size: 16,
                                        ),
                                        onDeleted: () => _removeCrop(crop),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Save button
                            ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text('Save Profile'),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}

