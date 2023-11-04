// Documentation: https://codelabs.developers.google.com/codelabs/flutter-codelab-first#6
// On responsiveness

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Run the application.
void main() {
  runApp(MyApp());
}

// As stated by the documentation, 'widgets' are the
// fundamental building blocks to each Flutter application.
//
// The top-most 'MyApp' class is a state-less widget
// which encapsulates the entire application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer Application',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 67, 252, 76)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

// This class encapsulates the state of the entire application.
//
// In this case, the only state which is being tracked is the
// word-pair to be displayed on the main page along with a collection
// of favorites.
class MyAppState extends ChangeNotifier {
  var currentWord = WordPair.random(); // generate initial word-pair
  var favorites = <WordPair>[]; // to save favorite word-pairs

  // Generate a new word-pair
  void getNextWord() {
    currentWord = WordPair.random();
    notifyListeners();
  }

  // Remove a word-pair if it has already been favorited,
  // otherwise add the word-pair as a favorite.
  void toggleFavorite() {
    if (favorites.contains(currentWord)) {
      favorites.remove(currentWord);
    } else {
      favorites.add(currentWord);
    }
    notifyListeners();
  }
}

// This class encapsulates the content of the main home page.
//
// Here, we have refactored the home page to be a stateful widget.
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var iconSize = 40.0; // sets the size for all icons on the page
  var navbarFontSize = 23.0;
  var minimumWidthToShowLabels = 600; // number in logical pixels

  var selectedIndex = 0; // sets the selected page on the navbar, state-aware

  @override
  Widget build(BuildContext context) {
    // Handle page selection
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= minimumWidthToShowLabels,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(
                      Icons.home,
                      size: iconSize,
                    ),
                    label: Text('Home',
                        style: TextStyle(
                            fontSize: navbarFontSize,
                            fontWeight: FontWeight.bold)),
                  ),
                  NavigationRailDestination(
                    icon: Icon(
                      Icons.favorite,
                      size: iconSize,
                    ),
                    label: Text(
                      'Favorites',
                      style: TextStyle(
                          fontSize: navbarFontSize,
                          fontWeight: FontWeight.bold),
                    ),
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
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var wordPair = appState.currentWord;

    IconData favoritesIcon;
    if (appState.favorites.contains(wordPair)) {
      favoritesIcon = Icons.favorite;
    } else {
      favoritesIcon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: wordPair),
          SizedBox(height: 30),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFavorite();
                  },
                  icon: Icon(favoritesIcon),
                  label: Text(
                    "Like",
                    style: TextStyle(fontSize: 30), // Set the font size to 30
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: () {
                    appState.getNextWord();
                  },
                  child: Text(
                    'Generate Word',
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

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
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text(
          'No favorites yet.',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Center(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'You have ${appState.favorites.length} favorites:',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          ...appState.favorites.map((pair) => ListTile(
                leading: Icon(Icons.favorite),
                title: Text(
                  pair.toString().toLowerCase(),
                  style: TextStyle(fontSize: 25),
                ),
              )),
        ],
      ),
    );
  }
}
