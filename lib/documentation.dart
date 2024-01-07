import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Documentation extends StatelessWidget {
  const Documentation({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // Implementing custom font
        fontFamily: "Patua",

        // Changing appbar color
        appBarTheme: const AppBarTheme(color: Colors.red),

        // Altering elevated button theme to remove sound effects
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(enableFeedback: false),
        ),

        // Created test themes
        textTheme: const TextTheme(
          // titleLarge Text Style used for the appbar, feedback message, and alert dialogue titles
          titleLarge: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          // displayMedium Text Style used for alert dialogue content
          displayMedium: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      home: const MyDocumentationPage(title: 'Project 3 Documentation Page'),
    );
  }
}

class MyDocumentationPage extends StatefulWidget {
  const MyDocumentationPage({super.key, required this.title});
  final String title;

  @override
  State<MyDocumentationPage> createState() => _DocumentationState();
}

class _DocumentationState extends State<MyDocumentationPage> {
  // Audio
  final sfxPlayer = AudioPlayer();
  double sfxVolume = 1.0;

  //Overriding the initState method to call init method
  @override
  void initState() {
    super.initState();

    // Load audio volume
    sfxPlayer.setVolume(sfxVolume);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusManager.instance.primaryFocus?.unfocus,
      child: Scaffold(
        // ----- Appbar -----
        appBar: AppBar(
          title: Text(
            "Documentation",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          // Leading amiibo app icon
          leading: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/amiibo-icon.png"))),
            ),
          ),
          // Info button which displays the documentation when clicked
          actions: [
            IconButton(
              onPressed: () => showDialog(
                context: context,
                // Building the alert dialogue used for page navigation
                builder: (context) => AlertDialog(
                  title: Text(
                    "Navigation",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  content: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            sfxPlayer.play(AssetSource("audio/click.wav"));
                            context.go("/app");
                          },
                          child: const Text("App"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            sfxPlayer.play(AssetSource("audio/click.wav"));
                            context.go("/favorites");
                          },
                          child: const Text("Favorites"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            sfxPlayer.play(AssetSource("audio/click.wav"));
                            context.go("/community");
                          },
                          child: const Text("Community"),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Documentation"),
                        ),
                      ],
                    ),
                  ),
                  // "OK" Button closes the navigation alert dialogue
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    )
                  ],
                ),
              ),
              // Creating the icon itself
              icon: const Icon(
                Icons.menu,
                color: Colors.black,
              ),
            )
          ],
        ),

        // ----- Page Body -----

        // The entire page is scrollable just in case there is any overflow
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                // Project Development Overview
                Text(
                  "\nDevelopment Overview\n",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text(
                    "This project was initially inteded to be something completely different; I had envisioned creating a top-down infinite runner game utilizing the Flame engine, however due to multiple complications I was unable to move forward with this original concept.\n\nAfter coming to this unsatisfying conclusion, I shifted my focus to improving a previous project to turn it into a more complete experience. This project in question was Project02, for which I created a application which utilized the Amiibo API to allow users to search for any amiibos they wanted to. Like Project02, I used a previous project I had completed in IGME 330which utilized the same API as a reference; this project can be found here: https://people.rit.edu/jjp1723/330/pionzio-p1/app.html.\n\nMy first course of action was to implement multiple pages into my application by utilizing the Go_Router package; in addition to the \"App\" page, I created a \"Favorites\" page, \"Community\" page, and \"Documentation\" page. To navigate between the pages, I altered the functionality of the action button in the app bar to display a alert dialogue box containing buttons which would route the player to the page indicated by the button's text. After successfully implementing multiple pages and page navigation, I decided to simplify the storage of amiibo data by creating a custom \"Amiibo\" class, which stored all returned data from the API as well as a count of how many times an the amiibo had been favorited, which I planned to utilize when adding functionality to the \"Community\" page. With the \"Amiibo\" class functional, I worked on the implementation of a favoriting system, which utilized the Shared_Preferenced package to save the data for each amiibo the user favorited on the \"App\" page, and then load that data on the \"Favorites\" to display the favorited amiibos to the user, which the user could then remove from their favorites. In addition, I altered the application to save the user's selection for the amount of results they wanted and the amount fo columns they wanted the results displayed in, the latter being loaded into the \"Favorites\" and \"Community\" pages to keep the display of amiibos consitent with the \"App\" page, and I altered the functionality of the \"Reset\" button on the \"App\" page to clear this new data from Shared_Preferences.\n\nOnce the favoriting system was functional and Shared_Prefeerences was properly saving/deleting relevant data, I altered the app's splash screen via the Flutter_Native_Splash package to make it better represent the application itself, and implemented custom sound effects and a music track to play while the application is running via the AudioPlayers package. Finally, I began work on implementing the feature I wanted the most, which was the utilization of FireBase via the Firebase_Core and Firebase_Database packages to allow the user to view all the favorited amiibos of other users and the amount of favorites each relevant amiibo had accumulated. Once this final piece of functionality was working properly, I began a round of debugging my having some of my friends experiment with the app through discord streaming, and I also updated the application's styling where I saw fit."),
                // Project Functionality Overview
                Text(
                  "\n\nApp Functionality\n",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text(
                    "This application utilizes the Amiibo API, and allows the user to search for specific amiibos by the name of the character. To view additional information about an Amiibo, click on its image in the results section. The additional information for each amiibo includes its name, the amiibo series it is from, the game sereis it is from, its model number, and its release date in North America, Europe, Japan, and Australia. The user can also add an amiibo to their favorites and subsequently view their favorited amiibos on the \"Favorites\" page, where they can also remove amiibos from their favorites. Users can also view the ammibos favorited by the community on the \"Community\" page, which also allows them to see the amount of favorites each amiibo has. Additional controls provided to the user on the \"App\" page allow the user to change to total amount of results they wish to view and the amount of colums they want the results to be displayed in, with the latter control also present on the \"Favorites\" page and the \"Community\" page. Updating the amount of results will require the user to perform another search, but updating the amount of columns will update the results immediately."),
                // Project Functionality Overview
                Text(
                  "\n\nRequirements Met\n",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text(
                    "Functionality: This project enhances project 2, and as such, is primarily used to search for amiibos from the amiibo api, with additional features allowing the user to favorite specific amiibos and view the community's favorites. The functionality goes well beyond what we did in class, thanks in large part to this projects use of FireBase, which we never used in class, but also due to the use of a custom class to store data, and the conversion of said cutom class objects into data that can, in turn, stored into and loaded from shared preferences. This application utilizes input validation to verify search terms, shared preferences to ssave and load data localy, and has more than 1 page (4 pages). This application doesn't crash.\n\nDesign and Interation: This project utilizes pleasing graphic design with well-labeled widgets that allow the user to figure out how to use it with minimal instruction, with user errors being handled gracefully.\n\nMedia: This project makes use of properly optimized images, music, sound effects, and a custom font.\n\nFunctionality: This project uses one class of my own creation, that being the \"amiibo\" class, and all variable are type aware. All repeated code is condensed into utility function or, in the case of FireStore-related functions, an external utility document (firestore.dart). All functions have propper names making use of camel case, with all code being thuroughly commented and with no print statements."),
                // Project Sources
                Text(
                  "\n\nSources\n",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text(
                    "Amiibo API: https://amiiboapi.com\n\nAmiibo Icon Source: http://videogames-fanon.wikia.com/wiki/File:Amiibo_icon.png\n\nMusic Source: https://www.zapsplat.com/music/easy-cheesy-fun-up-tempo-funky-retro-action-arcade-game-music-great-for-menu-or-pause-sections/\n\nAudio Effects Generated Using: https://sfxr.me\n\nFont Source: https://fonts.google.com/specimen/Patua+One?query=Patua\n\nFlutter Code Tutorials Utilized: https://www.youtube.com/@dowerchin\n\nFireStore Code Tutorials Utilized: https://www.youtube.com/playlist?list=PLjOFHn8uDrvR-nZtbKtV6NX_-4GaBkGNg\n\nCloud_Firestore API Reference: https://pub.dev/packages/cloud_firestore"),
                // Project Mockups
                Text(
                  "\n\nProject 2 Mockup\n",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  height: 320.0,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/project-2-mockup.PNG"),
                    ),
                  ),
                ),
                // Original Proposal
                Text(
                  "\n\nOriginal Project Proposal\n",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text(
                    "Game Title: Crash and Burn\nDeveloper: John Pionzio, Student, Game Design and Development major, 4th year.\nConcept: An infinite-runner style game where the player must dodge obstacles and collect collectibles to achieve as high a score as possible.\nGenre: Infinite Runner\nPlatform Mobile (Android)\nAesthetics Portrait oriented with top-down view and pixelated graphics. Background music will be intense, akin to Pizza Tower's “It's Pizza Time”.\nStory: The player is a bank robber who has hijacked a car and is on the run from the authorities. The player has no weapons and must dodge any and all obstacles or else they will crash and get caught by the police.  While running, the robber will come across loose cash and gold on the street which he can collect to increase his haul.\nVictory Conditions: There are none; the player must get as high of a score as possible.\nLoss Condition: The player fails to avoid an obstacle.\nGameplay Mechanics: The player will spawn obstacles and collectibles randomly, and the player will be able to move left or right to avoid them or collect them. There will also be powerups which allow the player to ignore obstacles for a time.\nControls: There will be a navigation bar at the top of the screen that will allow the user to navigate between the game, a page displaying their high scores, a settings page to control music and sound volume, a help screen detailing how to play the game, and the documentation page to outline the game's development. The game itself will have two buttons at the bottom of the screen which the player will use to move left and right during gameplay.\n\n"),
                Container(
                  height: 320.0,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/project-3-mockup.PNG"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
