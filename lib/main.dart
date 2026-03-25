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
      case 1:
        page = StatsPage();
      case 2:
        page = DailyInputWindow(
          onSubmitNavigate: () {
            setState(() {
              selectedIndex = 1;
              });
            },
        );
      case 3:
        page = HelpPage();
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

class DailyInputWindow extends StatefulWidget {
  final VoidCallback onSubmitNavigate;

  const DailyInputWindow({
    super.key,
    required this.onSubmitNavigate,
  });


  @override
  State<DailyInputWindow> createState() => _DailyInputWindowState();

  static InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: const OutlineInputBorder(),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }
}

class _DailyInputWindowState extends State<DailyInputWindow> {
  final TextEditingController caloriesEatenController = TextEditingController();
  final TextEditingController waterController = TextEditingController();
  final TextEditingController caloriesBurnedController = TextEditingController();
  double? caloriesEaten;
  double? waterDrank;
  double? caloriesBurned;
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FitPanionAppBar(),
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

            Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text("Calories Eaten:"),
                ),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: caloriesEatenController,
                    decoration: DailyInputWindow.inputDecoration("3,000"),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text("Water Drank:"),
                ),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: waterController,
                    decoration: DailyInputWindow.inputDecoration("15.5"),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                const Text("cups"),
              ],
            ),

            const SizedBox(height: 25),

            Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text("Calories Burned:"),
                ),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: caloriesBurnedController,
                    decoration: DailyInputWindow.inputDecoration("2,400"),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      caloriesEaten = double.tryParse(caloriesEatenController.text);
                      waterDrank = double.tryParse(waterController.text);
                      caloriesBurned = double.tryParse(caloriesBurnedController.text);
                    });

                    print("Calories Eaten: $caloriesEaten");
                    print("Water Drank: $waterDrank");
                    print("Calories Burned: $caloriesBurned");


                    widget.onSubmitNavigate();
                  },
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
}


class WeeklyInputWindow extends StatelessWidget {
  const WeeklyInputWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FitPanionAppBar(),
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
                  onPressed: () {
                    




                  },
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


class FitPanionAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const FitPanionAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("FitPanion"),
      centerTitle: true,
      backgroundColor: Colors.purple,
      leading: IconButton(
        icon: const Icon(Icons.mail),
        onPressed: () {
          // this is where it would take them to the weekly input page
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help),
          onPressed: () {
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HelpPage(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class HelpPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: const FitPanionAppBar(),
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(),
              Expanded(
                flex: 8,
                child: SingleChildScrollView(
                  child: Center(
                    child: Text(
                      '''
                          This is the help page of this app. This app aims to help people eat better, drink more water and keep themselves healthier by allowing you to take care of your own FitPanion by taking care of yourself.

                          Everyday you should input the amount of calories your have eaten, amount of calories you have burned and water you have drank with the "Input" window located at the bottom of the app. Every week a notification will come in at the top left hand side of the app asking for your weight, so we can track how well you are doing. To view your past inputs, visit the history page and to view your own FitPanion, visit the FitPanion page.

                          Your FitPanion needs the same calories water and exercise as you so be sure to take care of it and yourself. To view this page again, tap the "?" in the top right.
                          ''',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Colors.black26),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Got it',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FitPanionAppBar(),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

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
  return SizedBox(
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
  return SizedBox(
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