import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'amiibo.dart';
import 'firestore.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
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
      home: const MyAppPage(title: 'Project 3 App Page'),
    );
  }
}

class MyAppPage extends StatefulWidget {
  const MyAppPage({super.key, required this.title});
  final String title;

  @override
  State<MyAppPage> createState() => _MyAppPageState();
}

class _MyAppPageState extends State<MyAppPage> {
  // Text input controller
  final _inputTextController = TextEditingController();

  // Shared preferences variable to store search terms and favorites
  late SharedPreferences _preferences;

  // The url used to search for amiibos by name
  String nameURL = "https://amiiboapi.com/api/amiibo/?name=";

  // Search control variables
  String inputText = "";
  int resultNum = 1;
  int columnNum = 1;

  // Feedback message variable
  String feedbackMessage = "Enter a search term to find an Amiibo!";

  // List which stores amiibo information returned by the API
  List<Amiibo> results = [];

  // Map which stores favorited amiibo information returned by the API
  List<Amiibo> favorites = [];

  // Favorite Button Text
  String favoriteButtonText = "Favorite";

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

  //Overriding the initState method to add a listener to the input controller and to call init method
  @override
  void initState() {
    super.initState();
    _inputTextController.addListener(() {
      setState(() {
        inputText = _inputTextController.text;
      });
    });
    init();
  }

  @override
  Widget build(BuildContext context) {
    // Gesturedetector which will minimize the keyboard when the user interacts with the page
    return GestureDetector(
      onTap: FocusManager.instance.primaryFocus?.unfocus,
      child: Scaffold(
        // ----- Appbar -----
        appBar: AppBar(
          title: Text(
            "Amiibo Finder - App",
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
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
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
                // ----- Search Controls -----
                Container(
                  // Giving the container rounded corners
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6E6E6),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                    child: Column(
                      children: [
                        // ----- Search Term Text Field -----
                        TextField(
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.name,
                          controller: _inputTextController,
                          decoration: InputDecoration(
                            errorText: validateInput(_inputTextController.text),
                            border: const OutlineInputBorder(),
                            labelText: "Search Term",
                            contentPadding: const EdgeInsets.all(12.0),
                            fillColor: Colors.white,
                            filled: true,
                            suffixIcon: IconButton(
                              onPressed: () {
                                _inputTextController.clear();
                                inputText = "";
                              },
                              icon: const Icon(Icons.close_sharp),
                            ),
                          ),
                          // Pressing the enter key removes the keyboard
                          onSubmitted: (value) {
                            FocusScope.of(context).unfocus();
                            setState(
                              () {
                                inputText = value;
                              },
                            );
                          },
                        ),

                        // Sized Box creates additional spacing between the Search Term input and the dropdown dontrols
                        const SizedBox(
                          height: 16.0,
                        ),

                        // ----- Result Count Drop-Down -----
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                color: Colors.white,
                                child: Center(
                                  child: DropdownButtonFormField(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      fillColor: Colors.white,
                                      labelText: "Result Count",
                                    ),
                                    value: resultNum,
                                    items: resultCount,
                                    // Selecting a new value updates the 'results' variable
                                    onChanged: (newString) {
                                      setState(
                                        () {
                                          resultNum = newString!;
                                        },
                                      );
                                      saveState();
                                    },
                                  ),
                                ),
                              ),
                            ),

                            // Sized Box creates additional spacing between the dropdown controls
                            const SizedBox(
                              width: 16.0,
                            ),

                            // ----- Column Count Drop-Down -----
                            Expanded(
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ----- Button Controls -----
                Row(
                  children: [
                    // ----- Search Button -----
                    Expanded(
                      child: ElevatedButton(
                        // Pressing the button calls the 'getAmiibo' method
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          sfxPlayer.play(AssetSource("audio/pickup_coin.wav"));
                          getAmiibo();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text("Find Some Amiibos!"),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // ----- Reset Button -----
                    Expanded(
                      child: ElevatedButton(
                        // Pressing the button calls the 'reset' method
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          sfxPlayer.play(AssetSource("audio/hit_hurt.wav"));
                          reset();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Reset All Data"),
                      ),
                    ),
                  ],
                ),

                // ----- Message Text to inform user of page state -----
                Center(
                  child: Text(
                    feedbackMessage,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),

                // ----- Grid of Resulting Amiibos -----
                Container(
                  // Giving the container rounded corners
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  height: 420,
                  // ----- Grid Builder -----
                  child: GridView.builder(
                    itemCount: resultNum,
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columnNum,
                    ),
                    // Adding items to the grid based on the list detailing items of the search results
                    itemBuilder: (context, index) {
                      if (index < results.length) {
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
                                    results[index].character,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  // The content of the alert is a larger image of the amiibo and additional information regarding the amiibo's amiibo series, game series, model number, and release dates
                                  content: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Column(
                                      children: [
                                        Image.network(results[index].imageURL),
                                        const SizedBox(
                                          height: 64.0,
                                        ),
                                        Text(
                                          "Amiibo Series:\t\t\t\t${results[index].amiiboSeries}\nGame Series:\t\t\t\t\t\t${results[index].gameSeries}\nModel Number:\t\t${results[index].model}\n\nRelease Date (NA): ${results[index].releaseNA}\nRelease Date (EU): ${results[index].releaseEU}\nRelease Date (JP): ${results[index].releaseJP}\nRelease Date (AU): ${results[index].releaseAU}",
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
                                          // Text button for adding amiibo to favorites
                                          child: TextButton(
                                              onPressed: () async {
                                                if (results[index].favorites ==
                                                        0 &&
                                                    isFavorite(
                                                            results[index]) ==
                                                        false) {
                                                  results[index].favorites++;
                                                  favorites.add(results[index]);
                                                  // Adding/updating FireStore Data
                                                  addData(results[index]);
                                                  setState(() {
                                                    favoriteButtonText =
                                                        "Add to Favorites";
                                                  });
                                                }
                                                sfxPlayer.play(AssetSource(
                                                    "audio/pickup_coin.wav"));
                                                Navigator.pop(context);
                                                setState(() {});
                                                await saveState();
                                              },
                                              child: Text(favoriteButtonText)),
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
                                  child: Image.network(results[index].imageURL),
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

  // ----- validateInput Method -----
  String? validateInput(String value) {
    if (value == "") {
      return "Please enter a search term";
    }
    return null;
  }

  // ----- reset Method -----
  Future reset() async {
    // Resetting all variable to their default value
    _inputTextController.text = "";
    resultNum = 1;
    columnNum = 1;
    feedbackMessage = "Enter a search term to find some Amiibos!";
    results = [];

    // Updating the favorites count for all amiibos in FireStore before resetting the 'favorites' amiibo list
    for (int index = 0; index < favorites.length; index++) {
      removeData(favorites[index]);
    }
    favorites = [];

    // Calling the saveState method to update the sharedpreferences
    await saveState();
  }

  // ----- getAmiibo Method -----
  Future getAmiibo() async {
    // Updating the feedback message to inform user that a search is being performed
    setState(() {
      feedbackMessage = "Searching for \"$inputText\" Amiibos...";
    });

    // Clearing results
    results = [];

    // Waiting for a positive response from the API to continue
    var response = await http.get(Uri.parse(nameURL + inputText));
    if (response.statusCode == 200) {
      // Decoding response
      var jsonResponse = jsonDecode(response.body);

      // Setting the limit of images to be displayed
      if (jsonResponse["amiibo"].length != 0) {
        int limit = resultNum;

        // If the limit the user imposed is less than the amount of items in the response, the limit is updated
        if (jsonResponse["amiibo"].length < resultNum) {
          limit = jsonResponse["amiibo"].length;
        }

        // Changing the feedback to reflect the amount of results found
        if (limit == 1) {
          feedbackMessage = "1 \"$inputText\" Amiibo has been found!";
        } else {
          feedbackMessage = "$limit \"$inputText\" Amiibos have been found!";
        }

        setState(() {
          for (int index = 0; index < limit; index++) {
            // Creating an Amiibo object based on the results
            results.add(Amiibo(
                jsonResponse["amiibo"][index]["character"],
                jsonResponse["amiibo"][index]["gameSeries"],
                jsonResponse["amiibo"][index]["amiiboSeries"],
                jsonResponse["amiibo"][index]["head"],
                jsonResponse["amiibo"][index]["tail"],
                jsonResponse["amiibo"][index]["release"]["na"],
                jsonResponse["amiibo"][index]["release"]["eu"],
                jsonResponse["amiibo"][index]["release"]["jp"],
                jsonResponse["amiibo"][index]["release"]["au"],
                jsonResponse["amiibo"][index]["image"],
                0));

            if (isFavorite(results[index])) {
              results[index].favorites++;
            }
          }
        });

        // In case there was a positive response with no results
      } else {
        setState(() {
          feedbackMessage = "No results found for \"$inputText\"";
        });
      }

      // If the user failed to input any text before searching, the feebackMessage is updated accordingly
    } else if (inputText == "") {
      setState(() {
        feedbackMessage = "Please enter a search term before searching";
      });

      // If no results are found for the input search term, the feebackMessage is updated accordingly
    } else {
      setState(() {
        feedbackMessage = "No results found for \"$inputText\"";
        //feedbackMessage = "Error: ${response.statusCode}, ${response.reasonPhrase}";
      });
    }

    // Calling the saveState method to update the sharedpreferences
    await saveState();
  }

  // ----- init Method -----
  Future init() async {
    // Load sound effect volume
    sfxPlayer.setVolume(sfxVolume);

    // Loads any saved sharedpreferences
    _preferences = await SharedPreferences.getInstance();
    _inputTextController.text = _preferences.getString("myInput") ?? "";

    int? res = _preferences.getInt("myResultNum");
    if (res != null) {
      resultNum = res;
    }

    int? col = _preferences.getInt("myColumnNum");
    if (col != null) {
      columnNum = col;
    }

    String fav = _preferences.getString("myFavorites") ?? "";
    List<dynamic> favoritesList = [];
    if (fav != "") {
      favoritesList = jsonDecode(fav) as List<dynamic>;
      favorites = convertListToAmiibos(favoritesList);
    }

    // If there were saved preferences, call the getAmiibo method
    if (inputText != "") {
      getAmiibo();
    }
  }

  // ----- saveState Method -----
  Future saveState() async {
    // Saving Controls
    _preferences.setString("myInput", _inputTextController.text);
    _preferences.setInt("myResultNum", resultNum);
    _preferences.setInt("myColumnNum", columnNum);

    // Saving Favorites
    List<Map<String, dynamic>> favoritesList =
        convertAllAmiiboToMapList(favorites);
    _preferences.setString("myFavorites", jsonEncode(favoritesList));
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
