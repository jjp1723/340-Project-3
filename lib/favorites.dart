import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'amiibo.dart';
import 'firestore.dart';

class Favorites extends StatelessWidget {
  const Favorites({super.key});

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

        // Changing background color
        scaffoldBackgroundColor: const Color(0xFFC00000),

        // Altering elevated button theme to remove sound effects
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(enableFeedback: false),
        ),

        // Altering text button theme to remove sound effects
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(enableFeedback: false),
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
      home: const MyFavoritesPage(title: 'Project 3 Favorites Page'),
    );
  }
}

class MyFavoritesPage extends StatefulWidget {
  const MyFavoritesPage({super.key, required this.title});
  final String title;

  @override
  State<MyFavoritesPage> createState() => _FavoritesState();
}

class _FavoritesState extends State<MyFavoritesPage> {
  // Shared preferences variable to store search terms and favorites
  late SharedPreferences _preferences;
  List<Amiibo> favorites = [];
  int columnNum = 1;

  // Entries to populate the result dropdown control
  final resultCount = [
    const DropdownMenuItem(
      value: 1,
      child: Text("1"),
    ),
    const DropdownMenuItem(
      value: 2,
      child: Text("2"),
    ),
    const DropdownMenuItem(
      value: 3,
      child: Text("3"),
    ),
    const DropdownMenuItem(
      value: 4,
      child: Text("4"),
    ),
    const DropdownMenuItem(
      value: 5,
      child: Text("5"),
    ),
    const DropdownMenuItem(
      value: 10,
      child: Text("10"),
    ),
    const DropdownMenuItem(
      value: 20,
      child: Text("20"),
    ),
  ];

  // Entries to populate the column dropdown control
  final columnCount = [
    const DropdownMenuItem(
      value: 1,
      child: Text("1"),
    ),
    const DropdownMenuItem(
      value: 2,
      child: Text("2"),
    ),
    const DropdownMenuItem(
      value: 3,
      child: Text("3"),
    ),
    const DropdownMenuItem(
      value: 4,
      child: Text("4"),
    ),
  ];

  // Audio
  final sfxPlayer = AudioPlayer();
  double sfxVolume = 1.0;

  //Overriding the initState method to call init method
  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusManager.instance.primaryFocus?.unfocus,
      child: Scaffold(
        // ----- Appbar -----
        appBar: AppBar(
          title: Text(
            "My Favorites",
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
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
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
                          onPressed: () {
                            sfxPlayer.play(AssetSource("audio/click.wav"));
                            context.go("/documentation");
                          },
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
            // All page content is organized into a column
            child: Column(
              children: [
                // ----- Display Controls -----
                Container(
                  // Giving the container rounded corners
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6E6E6),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                    child: Container(
                      color: Colors.white,
                      child: Center(
                        child: DropdownButtonFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            labelText: "# of Columns",
                          ),
                          value: columnNum,
                          items: columnCount,
                          // Selecting a new value updates the 'columns' variable
                          onChanged: (newString) {
                            setState(
                              () {
                                columnNum = newString!;
                              },
                            );
                            saveState();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                // ----- Grid of Resulting Amiibos -----
                Container(
                  // Giving the container rounded corners
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  height: 580,
                  // ----- Grid Builder -----
                  child: GridView.builder(
                    itemCount: favorites.length,
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columnNum,
                    ),
                    // Adding items to the grid based on the list detailing items of the search favorites
                    itemBuilder: (context, index) {
                      if (index < favorites.length) {
                        return GridTile(
                          footer: const Center(),
                          // Each grid item displays an alert dialogue when clicked, detailing further information about the result itself
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  // The title of the alert is the name of the amiibo
                                  title: Text(
                                    favorites[index].character,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  // The content of the alert is a larger image of the amiibo and additional information regarding the amiibo's amiibo series, game series, model number, and release dates
                                  content: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Column(
                                      children: [
                                        Image.network(
                                            favorites[index].imageURL),
                                        const SizedBox(
                                          height: 64.0,
                                        ),
                                        Text(
                                          "Amiibo Series:\t\t\t\t${favorites[index].amiiboSeries}\nGame Series:\t\t\t\t\t\t${favorites[index].gameSeries}\nModel Number:\t\t${favorites[index].model}\n\nRelease Date (NA): ${favorites[index].releaseNA}\nRelease Date (EU): ${favorites[index].releaseEU}\nRelease Date (JP): ${favorites[index].releaseJP}\nRelease Date (AU): ${favorites[index].releaseAU}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium,
                                        )
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    Row(
                                      children: [
                                        Expanded(
                                          // Text button for removing amiibos from favorites
                                          child: TextButton(
                                              onPressed: () async {
                                                favorites[index].favorites--;
                                                // Updates FireStore data
                                                removeData(favorites[index]);
                                                favorites
                                                    .remove(favorites[index]);
                                                sfxPlayer.play(AssetSource(
                                                    "audio/hit_hurt.wav"));
                                                setState(() {});
                                                Navigator.pop(context);
                                                // Calling saveState to update sharedPreferences
                                                await saveState();
                                              },
                                              child: const Text(
                                                  "Remove from Favorites")),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        // Close button for closing the alert dialogue
                                        Expanded(
                                          child: TextButton(
                                            onPressed: () {
                                              sfxPlayer.play(AssetSource(
                                                  "audio/click.wav"));
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Close"),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                            // Each result displays just the amiibos picture for simplicity
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6E6E6),
                                  border:
                                      Border.all(width: 1, color: Colors.black),
                                ),
                                child: Center(
                                  child:
                                      Image.network(favorites[index].imageURL),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----- init Method -----
  Future init() async {
    // Load audio volume
    sfxPlayer.setVolume(sfxVolume);

    // Loads any saved sharedpreferences
    _preferences = await SharedPreferences.getInstance();

    int? col = _preferences.getInt("myColumnNum");
    if (col != null) {
      columnNum = col;
    }

    List<dynamic> favoritesList =
        jsonDecode(_preferences.getString("myFavorites") ?? "")
            as List<dynamic>;
    favorites = convertListToAmiibos(favoritesList);

    setState(() {});
  }

  // ----- saveState Method -----
  Future saveState() async {
    List<Map<String, dynamic>> favoritesList =
        convertAllAmiiboToMapList(favorites);
    _preferences.setString("myFavorites", jsonEncode(favoritesList));
    _preferences.setInt("myColumnNum", columnNum);
  }

  // ----- isFavorite Method -----
  bool isFavorite(Amiibo amiibo) {
    for (int index = 0; index < favorites.length; index++) {
      if (favorites[index].model == amiibo.model) {
        return true;
      }
    }
    return false;
  }
}
