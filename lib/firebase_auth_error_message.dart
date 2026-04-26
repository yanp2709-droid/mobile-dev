import 'package:firebase_auth/firebase_auth.dart';

String firebaseAuthErrorMessage(FirebaseAuthException error) {
  final message = error.message?.trim();

  if (_isMissingFirebaseAuthConfiguration(error, message)) {
    return 'Firebase Authentication is not enabled for this project yet. Open Firebase Console > Authentication, click Get started, then enable Email/Password.';
  }

  switch (error.code) {
    case 'email-already-in-use':
      return 'That email is already registered. Try logging in instead.';
    case 'invalid-credential':
      return 'The email or password is incorrect.';
    case 'invalid-email':
      return 'Enter a valid email address.';
    case 'network-request-failed':
      return 'Network error. Check your connection and try again.';
    case 'operation-not-allowed':
      return 'Email/password sign-in is not enabled in Firebase Auth yet.';
    case 'too-many-requests':
      return 'Too many attempts. Please wait a bit and try again.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'user-not-found':
      return 'No account was found for that email.';
    case 'weak-password':
      return 'Use a stronger password with at least 6 characters.';
    case 'wrong-password':
      return 'The email or password is incorrect.';
    default:
      if (message != null && message.isNotEmpty) {
        return message;
      }
      return 'Authentication failed. Please try again.';
  }
}

bool _isMissingFirebaseAuthConfiguration(
  FirebaseAuthException error,
  String? message,
) {
  if (error.code == 'configuration-not-found') {
    return true;
  }

  final normalizedMessage = message?.toUpperCase() ?? '';
  return normalizedMessage.contains('CONFIGURATION_NOT_FOUND');
}
