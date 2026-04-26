import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FirebaseSetupPage extends StatelessWidget {
  const FirebaseSetupPage({super.key, required this.errorMessage});

  final String errorMessage;

  static const _flutterFireCommand =
      'flutterfire configure --platforms=android,ios,macos,web,windows';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final platformName = kIsWeb ? 'web' : defaultTargetPlatform.name;

    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Setup Required')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Firebase authentication is wired into the app, but the project is not configured for $platformName yet.',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Finish the Firebase setup once, then restart the app.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recommended command',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const SelectableText(_flutterFireCommand),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What to check',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '1. Create or select your Firebase project.\n'
                            '2. Enable Email/Password in Firebase Authentication.\n'
                            '3. Run the FlutterFire command above to replace lib/firebase_options.dart.\n'
                            '4. For Android, keep the Google services Gradle plugin enabled in this repo.\n'
                            '5. Restart flutter run after configuration.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current startup error',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          SelectableText(errorMessage),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
