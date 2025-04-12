import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String email;
  final String? name;
  final Map<String, dynamic>? userMetadata;

  User({
    required this.id,
    required this.email,
    this.name,
    this.userMetadata,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      userMetadata: json['userMetadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'userMetadata': userMetadata,
    };
  }
}

class AuthService extends ChangeNotifier {
  static const String _userKey = 'current_user';
  static const String _usersKey = 'users';
  User? _currentUser;

  User? get currentUser => _currentUser;

  AuthService() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      _currentUser = User.fromJson(json.decode(userJson));
      notifyListeners();
    }
  }

  Future<User?> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if user already exists
    final usersJson = prefs.getStringList(_usersKey) ?? [];
    final users = usersJson.map((u) => json.decode(u)).toList();
    
    if (users.any((u) => u['email'] == email)) {
      throw Exception('User with this email already exists');
    }
    
    // Create new user
    final user = User(
      id: const Uuid().v4(),
      email: email,
      name: data?['name'],
      userMetadata: data,
    );
    
    // Store user credentials
    final userCredential = {
      'email': email,
      'password': password,
      'id': user.id,
    };
    
    // Add to users list
    usersJson.add(json.encode(userCredential));
    await prefs.setStringList(_usersKey, usersJson);
    
    // Set as current user
    _currentUser = user;
    await prefs.setString(_userKey, json.encode(user.toJson()));
    
    notifyListeners();
    return user;
  }

  Future<User?> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey) ?? [];
    
    // Find user with matching credentials
    for (final userJson in usersJson) {
      final userData = json.decode(userJson);
      if (userData['email'] == email && userData['password'] == password) {
        // Get user ID and create user object
        final userId = userData['id'];
        final user = User(
          id: userId,
          email: email,
          userMetadata: {'name': email.split('@').first},
        );
        
        // Set as current user
        _currentUser = user;
        await prefs.setString(_userKey, json.encode(user.toJson()));
        
        notifyListeners();
        return user;
      }
    }
    
    throw Exception('Invalid email or password');
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    _currentUser = null;
    notifyListeners();
  }
}

// Global instance
final authService = AuthService();
