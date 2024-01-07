import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app.dart';
import 'community.dart';
import 'documentation.dart';
import 'favorites.dart';
import 'firebase_options.dart';

// GoRouter for page navigation
final _router = GoRouter(initialLocation: "/app", routes: [
  GoRoute(
    path: "/app",
    builder: (context, state) {
      return const App();
    },
  ),
  GoRoute(
    path: "/favorites",
    builder: (context, state) {
      return const Favorites();
    },
  ),
  GoRoute(
    path: "/community",
    builder: (context, state) {
      return const Community();
    },
  ),
  GoRoute(
    path: "/documentation",
    builder: (context, state) {
      return const Documentation();
    },
  ),
]);

Future main() async {
  // Loading firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Loading and playing music
  final musicPlayer = AudioPlayer();
  double musicVolume = 0.5;
  musicPlayer.setVolume(musicVolume);
  musicPlayer.play(AssetSource("audio/music_zapsplat_easy_cheesy.mp3"));
  musicPlayer.setReleaseMode(ReleaseMode.loop);

  // Run the application
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  // Building the application
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "Main Page",
      routerConfig: _router,
    );
  }
}
