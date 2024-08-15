import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:map_app/models/user_model.dart';
import 'package:map_app/helpers/constant/auth_exception_handler.dart';
import 'package:map_app/helpers/constant/enums.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(auth: FirebaseAuth.instance, db: FirebaseFirestore.instance),
);

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore db;

  AuthRepository({
    required this.auth,
    required this.db,
  });

  String get currentUserId => auth.currentUser?.uid ?? '';

  Future<void> saveUserInfo(UserModel userModel, bool isAdmin) async {
    String collection = isAdmin ? 'admins' : 'users';
    await db.collection(collection).doc(currentUserId).set(userModel.toMap());
  }

  Future<AuthResultStatus> createAccount(
      String email, String name, String lastName, String password, bool isAdmin) async {
    AuthResultStatus status;
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName('$name $lastName');
        UserModel userModel = UserModel(name: name, lastName: lastName, email: email);
        await saveUserInfo(userModel, isAdmin);
        status = AuthResultStatus.successful;
      } else {
        status = AuthResultStatus.undefined;
      }
    } on FirebaseAuthException catch (e) {
      status = AuthExceptionHandler.handleException(e);
    }
    return status;
  }

  Future<AuthResultStatus> login(String email, String password, bool isAdmin) async {
    AuthResultStatus status;
    try {
      final authResult = await auth.signInWithEmailAndPassword(email: email, password: password);
      if (authResult.user != null) {
        String collection = isAdmin ? 'admins' : 'users';
        DocumentSnapshot snapshot = await db.collection(collection).doc(authResult.user!.uid).get();
        if (snapshot.exists) {
          status = AuthResultStatus.successful;
        } else {
          status = AuthResultStatus.invalidEmail;
        }
      } else {
        status = AuthResultStatus.undefined;
      }
    } on FirebaseAuthException catch (e) {
      status = AuthExceptionHandler.handleException(e);
    }
    return status;
  }

  Future<void> logout() async {
    try {
      await auth.signOut();
    } catch (e) {
      e.toString();
    }
  }
}
