import 'package:aqua_sense/models/user.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  bool get isLoggedIn => _currentUser != null;
  User? get currentUser => _currentUser;

  // Mock login function
  Future<User?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simple validation
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }

    // Mock successful login
    if (email.contains('@') && password.length >= 6) {
      _currentUser = User(
        id: 1,
        name: 'John Doe',
        email: email,
        profileImage: 'assets/images/profile.jpg',
        phoneNumber: '+1 (555) 123-4567',
        address: '123 Farm Road, Countryside, CA 90210',
        farmName: 'Green Valley Farm',
        farmSize: 25.5,
        preferredCrops: ['Corn', 'Wheat', 'Tomatoes', 'Apples'],
      );
      return _currentUser;
    } else {
      throw Exception('Invalid email or password');
    }
  }

  // Mock signup function
  Future<User?> signup(String name, String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simple validation
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('All fields are required');
    }

    if (!email.contains('@')) {
      throw Exception('Invalid email format');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // Mock successful signup
    _currentUser = User(
      id: 1,
      name: name,
      email: email,
      preferredCrops: [],
    );
    return _currentUser;
  }

  // Update user profile
  Future<User?> updateProfile(User updatedUser) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (_currentUser == null) {
      throw Exception('Not logged in');
    }

    _currentUser = updatedUser;
    return _currentUser;
  }

  // Update user settings
  Future<User?> updateSettings(Map<String, bool> settings) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (_currentUser == null) {
      throw Exception('Not logged in');
    }

    _currentUser = _currentUser!.copyWith(
      appSettings: settings,
    );
    return _currentUser;
  }

  // Logout function
  Future<void> logout() async {
    _currentUser = null;
  }
}

