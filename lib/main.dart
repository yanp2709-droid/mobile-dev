import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/firebase_setup_page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';

void main() {
  runApp(const MyApp());
}

enum AppBootstrapMode { firebase, demo }

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.bootstrapMode = AppBootstrapMode.firebase});

  final AppBootstrapMode bootstrapMode;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'first_application_Yan',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 227, 109, 164),
          ),
        ),
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
        },
        home: switch (bootstrapMode) {
          AppBootstrapMode.firebase => const FirebaseBootstrapPage(),
          AppBootstrapMode.demo => const MyHomePage(),
        },
      ),
    );
  }
}

class FirebaseBootstrapPage extends StatefulWidget {
  const FirebaseBootstrapPage({super.key});

  @override
  State<FirebaseBootstrapPage> createState() => _FirebaseBootstrapPageState();
}

class _FirebaseBootstrapPageState extends State<FirebaseBootstrapPage> {
  late final Future<void> _bootstrapFuture = _initializeFirebase();

  Future<void> _initializeFirebase() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return FirebaseFallbackShell(errorMessage: snapshot.error.toString());
        }

        return const AuthWrapper();
      },
    );
  }
}

class FirebaseFallbackShell extends StatelessWidget {
  const FirebaseFallbackShell({super.key, required this.errorMessage});

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return MyHomePage(
      bannerMessage:
          'Firebase is not configured, so the app is running in demo mode.',
      bannerActionLabel: 'Setup',
      onBannerAction: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => FirebaseSetupPage(errorMessage: errorMessage),
          ),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const MyHomePage(allowSignOut: true);
        }

        return const LoginPage();
      },
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }

  void updateFavorite(WordPair oldPair) {
    final index = favorites.indexOf(oldPair);
    if (index != -1) {
      favorites[index] = WordPair.random();
      notifyListeners();
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    this.allowSignOut = false,
    this.bannerMessage,
    this.bannerActionLabel,
    this.onBannerAction,
  });

  final bool allowSignOut;
  final String? bannerMessage;
  final String? bannerActionLabel;
  final VoidCallback? onBannerAction;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch (selectedIndex) {
      case 0:
        page = const GeneratorPage();
      case 1:
        page = const FavoritesPage();
      case 2:
        page = const SettingsPage();
      case 3:
        page = const DeletePage();
      case 4:
        page = const UpdatePage();
      default:
        page = const GeneratorPage();
    }

    final user = widget.allowSignOut ? FirebaseAuth.instance.currentUser : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            actions: [
              if (user != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                    child: SizedBox(
                      width: 180,
                      child: Text(
                        user.email ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ),
              if (widget.allowSignOut)
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _signOut,
                  tooltip: 'Logout',
                ),
            ],
          ),
          body: Column(
            children: [
              if (widget.bannerMessage != null)
                Material(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.bannerMessage!,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                        if (widget.onBannerAction != null)
                          TextButton(
                            onPressed: widget.onBannerAction,
                            child: Text(widget.bannerActionLabel ?? 'Details'),
                          ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: Row(
                  children: [
                    SafeArea(
                      child: NavigationRail(
                        extended: constraints.maxWidth >= 600,
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.home),
                            label: Text('Home'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.favorite),
                            label: Text('Favorites'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.settings),
                            label: Text('Settings'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.delete),
                            label: Text('Delete'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.update),
                            label: Text('Update'),
                          ),
                        ],
                        selectedIndex: selectedIndex,
                        onDestinationSelected: (value) {
                          setState(() {
                            selectedIndex = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: page,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: appState.toggleFavorite,
                icon: Icon(icon),
                label: const Text('Like'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: appState.getNext,
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return const Center(child: Text('No favorites yet.'));
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ${appState.favorites.length} favorites:'),
        ),
        for (final pair in appState.favorites)
          ListTile(
            leading: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                appState.removeFavorite(pair);
              },
            ),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return const Center(child: Text('Settings on maintenance.'));
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ${appState.favorites.length} favorites:'),
        ),
        for (final pair in appState.favorites)
          ListTile(
            leading: const Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.pair});

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          semanticsLabel: '${pair.first} ${pair.second}',
          style: style,
        ),
      ),
    );
  }
}

class DeletePage extends StatelessWidget {
  const DeletePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return const Center(child: Text('No favorites to delete.'));
    }

    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text('Delete your favorites:'),
        ),
        for (final pair in appState.favorites)
          ListTile(
            leading: const Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                appState.removeFavorite(pair);
              },
            ),
          ),
      ],
    );
  }
}

class UpdatePage extends StatelessWidget {
  const UpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return const Center(child: Text('Nothing to update'));
    }

    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text('Update Favorites'),
        ),
        for (final pair in appState.favorites)
          ListTile(
            title: Text(pair.asLowerCase),
            trailing: ElevatedButton(
              onPressed: () {
                appState.updateFavorite(pair);
              },
              child: const Text('Update'),
            ),
          ),
      ],
    );
  }
}
