import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  UserRole? get role => _userModel?.role;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null && _userModel != null;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (user != null) {
      await _loadUserData();
    } else {
      _userModel = null;
    }
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    if (_user == null) return;

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        _userModel = UserModel.fromFirestore(userDoc);
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phoneNumber,
    String? specialization,
    String? licenseNumber,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userModel = UserModel(
        id: result.user!.uid,
        email: email,
        fullName: fullName,
        role: role,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        specialization: specialization,
        licenseNumber: licenseNumber,
      );

      await _firestore.collection('users').doc(result.user!.uid).set(userModel.toFirestore());
      _userModel = userModel;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      await _firestore.collection('users').doc(_user!.uid).update(updatedUser.toFirestore());
      _userModel = updatedUser;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _userModel = null;
    notifyListeners();
  }
}