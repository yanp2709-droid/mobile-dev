import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:first_application_Yan/firebase_auth_error_message.dart';

void main() {
  test('maps missing Firebase Auth configuration to a setup message', () {
    final error = FirebaseAuthException(
      code: 'internal-error',
      message: 'An internal error has occurred. [ CONFIGURATION_NOT_FOUND ]',
    );

    expect(
      firebaseAuthErrorMessage(error),
      'Firebase Authentication is not enabled for this project yet. Open Firebase Console > Authentication, click Get started, then enable Email/Password.',
    );
  });

  test('keeps known weak-password messaging friendly', () {
    final error = FirebaseAuthException(code: 'weak-password');

    expect(
      firebaseAuthErrorMessage(error),
      'Use a stronger password with at least 6 characters.',
    );
  });
}
