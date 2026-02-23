import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Fitpanion',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext(){
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
}

// ...

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = StatsPage();
        break;
      case 2:
        page = DailyInputWindow();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: page,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'FitPanion',
          ),
          NavigationDestination(
            icon: Icon(Icons.input),
            label: 'Input',
          ),
        ],
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

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
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    var theme = Theme.of(context);

    return Center(
      child: ListView(
        
        children: [
          Center(
            child: Card(
              color: theme.colorScheme.primary, 
              child:Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:const <Widget>[Text("Saved Messages: ")]
                ),
              )
              ),
          ),
          for (var msg in appState.favorites) ListTile(leading:Icon(Icons.favorite), title:Text(msg.first+msg.second)),
        ],
      ),
    );
  }
}

class DailyInputWindow extends StatelessWidget {
  const DailyInputWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FitPanion"),
        centerTitle: true,
        backgroundColor: Colors.purple,
        leading: const Icon(Icons.mail),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.help),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Good Morning",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Please enter your stats"),
            const SizedBox(height: 40),

            // Calories Eaten
            buildInputRow("Calories Eaten:", "3,000"),

            const SizedBox(height: 25),

            // Water Drank
            Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text("Water Drank:"),
                ),
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: inputDecoration("15.5"),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                const Text("cups"),
              ],
            ),

            const SizedBox(height: 25),

            // Calories Burned
            buildInputRow("Calories Burned:", "2,400"),

            const SizedBox(height: 50),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: const Text("Submit"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  static Widget buildInputRow(String label, String hint) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label),
        ),
        Expanded(
          flex: 3,
          child: TextField(
            decoration: inputDecoration(hint),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  static InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: const OutlineInputBorder(),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }
}


class WeeklyInputWindow extends StatelessWidget {
  const WeeklyInputWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FitPanion"),
        centerTitle: true,
        backgroundColor: Colors.purple,
        leading: const Icon(Icons.mail),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.help),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Happy Monday",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Please enter your stats"),
            const SizedBox(height: 40),

            Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text("Weight:"),
                ),
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: inputDecoration("180"),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                const Text("lbs"),
              ],
            ),

            buildInputRow("Last Week's Weight", "182 lbs"),

            const SizedBox(height: 25),
            

            const SizedBox(height: 25),

            Text("Difference: 2 lbs"),

            const SizedBox(height: 50),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: const Text("Submit"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  static Widget buildInputRow(String label, String hint) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label),
        ),
        Expanded(
          flex: 3,
          child: TextField(
            decoration: inputDecoration(hint),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  static InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: const OutlineInputBorder(),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }
}


class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FitPanion"),
        centerTitle: true,
        backgroundColor: Colors.purple,
        leading: const Icon(Icons.mail),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.help),
          )
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Top Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  buildStatBar("Calories", 0.8),
                  const SizedBox(height: 10),
                  buildStatBar("Water", 0.7),
                  const SizedBox(height: 10),
                  buildStatBar("Exercise", 0.85),
                  const SizedBox(height: 10),
                  buildStatBar("Happiness", 0.65),
                ],
              ),
            ),

            const SizedBox(height: 40),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    buildBackgroundImageBox('assets/FitPanionBG.png'),
                    buildFitPanionImageBox('assets/FitPanion.png'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget buildFitPanionImageBox(String path) {
  return Container(
    width: 150,
    height: 150,
    child: ClipRRect(
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.none,
      ),
    ),
  );
  } 

  Widget buildBackgroundImageBox(String path) {
  return Container(
    width: 1000,
    height: 300,
    child: ClipRRect(
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.none,
      ),
    ),
  );
  } 

  Widget buildStatBar(String label, double value) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            "$label:",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey[400],
            color: Colors.green,
            minHeight: 10,
          ),
        ),
      ],
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
  var theme = Theme.of(context);
  var style = theme.textTheme.displayMedium!.copyWith(color:theme.colorScheme.onPrimary,);

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(pair.asLowerCase, style: style, semanticsLabel: pair.asPascalCase,),
      ),
    );
  }
}