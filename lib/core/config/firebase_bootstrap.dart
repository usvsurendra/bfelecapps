import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

bool _firebaseReady = false;

bool get firebaseReady => _firebaseReady;

Future<void> initFirebase() async {
  try {
    await Firebase.initializeApp();
    _firebaseReady = true;
  } catch (error) {
    _firebaseReady = false;
    debugPrint('Firebase unavailable, continuing without auth: $error');
  }
}

FirebaseAuth? get safeAuth => _firebaseReady ? FirebaseAuth.instance : null;

FirebaseStorage? get safeStorage =>
    _firebaseReady ? FirebaseStorage.instance : null;

Stream<User?> safeAuthStateChanges() => _firebaseReady
    ? FirebaseAuth.instance.authStateChanges()
    : const Stream<User?>.empty();

Stream<User?> safeUserChanges() => _firebaseReady
    ? FirebaseAuth.instance.userChanges()
    : const Stream<User?>.empty();