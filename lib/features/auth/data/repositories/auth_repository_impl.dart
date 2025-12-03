import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/services/firebase_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseService _firebaseService;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseService? firebaseService,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firebaseService = firebaseService ?? FirebaseService(),
        _googleSignIn = googleSignIn ?? GoogleSignIn(
          scopes: ['email', 'profile'],
        );

  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await _getUserData(user);
    });
  }

  @override
  UserEntity? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    // Note: This returns a basic entity from Auth data. 
    // For full profile, we need to fetch from DB which is async.
    return _mapFirebaseUserToEntity(user);
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _getUserData(result.user!);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword(String email, String password, String name) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = result.user!;
      await user.updateDisplayName(name);
      
      final newUser = UserEntity(
        id: user.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
        isOnline: true,
      );
      
      // Save to Realtime Database
      await _firebaseService.userRef(user.uid).set({
        'email': email,
        'name': name,
        'createdAt': ServerValue.timestamp,
        'isOnline': true,
        'lastSeen': ServerValue.timestamp,
      });
      
      return newUser;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      UserCredential result;
      
      if (kIsWeb) {
        // Web: Use signInWithPopup
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        result = await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        // Mobile: Use GoogleSignIn package
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) throw Exception('Google Sign In aborted');

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        result = await _firebaseAuth.signInWithCredential(credential);
      }

      final user = result.user!;
      
      // Check if user exists in DB, if not create
      final snapshot = await _firebaseService.userRef(user.uid).get();
      
      if (!snapshot.exists) {
        await _firebaseService.userRef(user.uid).set({
          'email': user.email,
          'name': user.displayName ?? 'User',
          'profileImage': user.photoURL,
          'createdAt': ServerValue.timestamp,
          'isOnline': true,
          'lastSeen': ServerValue.timestamp,
        });
      } else {
        // Update online status
        await _firebaseService.userRef(user.uid).update({
          'isOnline': true,
          'lastSeen': ServerValue.timestamp,
        });
      }
      
      return await _getUserData(user);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> signOut() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await _firebaseService.userRef(user.uid).update({
        'isOnline': false,
        'lastSeen': ServerValue.timestamp,
      });
    }
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserEntity> _getUserData(User firebaseUser) async {
    final snapshot = await _firebaseService.userRef(firebaseUser.uid).get();
    
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return UserEntity(
        id: firebaseUser.uid,
        email: data['email'] ?? firebaseUser.email ?? '',
        name: data['name'] ?? firebaseUser.displayName ?? '',
        profileImage: data['profileImage'] ?? firebaseUser.photoURL,
        coverImage: data['coverImage'],
        bio: data['bio'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
        isOnline: data['isOnline'] ?? false,
      );
    }
    
    return _mapFirebaseUserToEntity(firebaseUser);
  }

  UserEntity _mapFirebaseUserToEntity(User user) {
    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
      profileImage: user.photoURL,
      createdAt: DateTime.now(), // Fallback
      isOnline: true,
    );
  }

  Exception _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return Exception('No user found for that email.');
        case 'wrong-password':
          return Exception('Wrong password provided.');
        case 'email-already-in-use':
          return Exception('The account already exists for that email.');
        case 'invalid-email':
          return Exception('The email address is not valid.');
        default:
          return Exception(e.message ?? 'Authentication failed');
      }
    }
    return Exception(e.toString());
  }
}
