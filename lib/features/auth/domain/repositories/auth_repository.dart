import 'package:firebase_auth/firebase_auth.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<UserEntity> signInWithEmailAndPassword(String email, String password);
  Future<UserEntity> signUpWithEmailAndPassword(String email, String password, String name);
  Future<UserEntity> signInWithGoogle();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  UserEntity? get currentUser;
}
