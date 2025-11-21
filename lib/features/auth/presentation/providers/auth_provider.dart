import 'package:flutter/material.dart';
import 'package:clone_social/features/auth/domain/entities/user_entity.dart';
import 'package:clone_social/features/auth/domain/repositories/auth_repository.dart';
import 'package:clone_social/features/auth/data/repositories/auth_repository_impl.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider({AuthRepository? authRepository}) 
      : _authRepository = authRepository ?? AuthRepositoryImpl() {
    _init();
  }

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  void _init() {
    _authRepository.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    _setLoading(true);
    try {
      await _authRepository.signUpWithEmailAndPassword(email, password, name);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      await _authRepository.signInWithGoogle();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _authRepository.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _isLoading = false;
    _error = error.replaceAll('Exception: ', '');
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
