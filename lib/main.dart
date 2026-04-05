import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        ),
        home: const LoginScreen(),
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

  var dailyInputs = <String>[];

  void addDailyInput(String entry) {
    dailyInputs.add(entry);
    notifyListeners();
  }

  var weeklyInputs = <String>[];

  void addWeeklyInput(String entry) {
    weeklyInputs.add(entry);
    notifyListeners();
  }
}



class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = HistoryPage();
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
  double? recommendedCalories;
 
  double calculateDailyCalories({
    required double weightKg,
    required double heightCm,
    required int age,
    required double caloriesBurned,
  }) {
    final bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    return bmr + caloriesBurned;
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      final height = (data['height'] as num).toDouble();
      final age = data['age'] as int;

      final List dailyinputs = data['dailyInputs'] ?? [];
      final List weeklyinputs = data['weeklyInputs'] ?? [];
      double lastExercise = 0;
      double lastWeight = 0;
      if (dailyinputs.isNotEmpty) {
        final parts = (dailyinputs.last as String).split(',');
        for (final part in parts) {
          if (part.startsWith('exercise:')) {
            lastExercise = double.tryParse(
              part.replaceFirst('exercise:', '')) ?? 0;
          }
        }
      }
      if (weeklyinputs.isNotEmpty) {
        final parts = (weeklyinputs.last as String).split(',');
        for (final part in parts) {
          if (part.startsWith('weight:')) {
            lastWeight = double.tryParse(
              part.replaceFirst('weight:', '')) ?? 0;
          }
        }
      }

      setState(() {
        recommendedCalories = (10 * lastWeight) + (6.25 * height) - (5 * age) + 5 + lastExercise;
      });
    }
  }

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
            const SizedBox(height: 8),
            recommendedCalories != null
                ? Text(
                    "Recommended calories today: ${recommendedCalories!.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : const SizedBox.shrink(),
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
                const SizedBox(width: 10),
                const Text("kcals"),
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
                const SizedBox(width: 10),
                const Text("kcals"),
              ],
            ),

            const SizedBox(height: 50),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      caloriesEaten = double.tryParse(caloriesEatenController.text);
                      waterDrank = double.tryParse(waterController.text);
                      caloriesBurned = double.tryParse(caloriesBurnedController.text);
                    });

                    final appState = context.read<MyAppState>();
                    final today = DateTime.now();
                    final entry = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')},'
                        'cal:${caloriesEaten ?? 0},'
                        'water:${waterDrank ?? 0},'
                        'exercise:${caloriesBurned ?? 0}';
                    appState.addDailyInput(entry);

                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    if (uid != null) {
                      await FirebaseFirestore.instance.collection('users').doc(uid).update({
                        'dailyInputs': FieldValue.arrayUnion([entry]),
                      });
                    }
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


class WeeklyInputWindow extends StatefulWidget {
  const WeeklyInputWindow({super.key});

  @override
  State<WeeklyInputWindow> createState() => _WeeklyInputWindowState();
}

class _WeeklyInputWindowState extends State<WeeklyInputWindow> {
  final weightController = TextEditingController();
  double? lastWeight;
  double? currentWeight;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadLastWeight();
  }

  Future<void> loadLastWeight() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;
    final List inputs = data['weeklyInputs'] ?? [];

    if (inputs.isNotEmpty) {
      final parts = (inputs.last as String).split(',');
      for (final part in parts) {
        if (part.startsWith('weight:')) {
          setState(() {
            lastWeight = double.tryParse(part.replaceFirst('weight:', ''));
          });
        }
      }
    }
  }

  Future<void> submitWeight() async {
  currentWeight = double.tryParse(weightController.text);
  if (currentWeight == null) return;

  setState(() { isLoading = true; });

  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null) {
    try {
      final today = DateTime.now();
      final entry =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')},'
          'weight:$currentWeight';

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
        'weeklyInputs': FieldValue.arrayUnion([entry]),
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MyHomePage(),
        ),
      );
    } catch (e) {
      print("Error saving: $e");
    }
  }
}

  double? get weightDifference {
    if (lastWeight == null || currentWeight == null) return null;
    return currentWeight! - lastWeight!;
  }

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
                    controller: weightController,
                    decoration: inputDecoration("82"),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                const Text("kg"),
              ],
            ),

            const SizedBox(height: 25),

            Text(
              "Last Week's Weight: ${lastWeight != null ? '${lastWeight!.toStringAsFixed(1)} kg' : 'No data yet'}",
            ),

            const SizedBox(height: 25),

            if (weightDifference != null)
              Text(
                "Difference: ${weightDifference! >= 0 ? '+' : ''}${weightDifference!.toStringAsFixed(1)} kg",
                style: TextStyle(
                  color: weightDifference! <= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 50),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: isLoading ? null : submitWeight,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Submit"),
                ),
                ElevatedButton(
                  onPressed: (){
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MyHomePage(),
                    ),
                  );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child:
                      const Text("Cancel"),
                ),
              ],
            )
          ],
        ),
      ),
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



class FitPanionAppBar extends StatefulWidget implements PreferredSizeWidget {
  const FitPanionAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<FitPanionAppBar> createState() => _FitPanionAppBarState();
}

class _FitPanionAppBarState extends State<FitPanionAppBar> {
  bool showNotification = false;

  @override
  void initState() {
    super.initState();
    checkWeeklyInput();
  }

  Future<void> checkWeeklyInput() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;
    final List weeklyInputs = data['weeklyInputs'] ?? [];

    if (weeklyInputs.isEmpty) {
      setState(() { showNotification = true; });
      return;
    }

    final lastEntry = weeklyInputs.last as String;
    final datePart = lastEntry.split(',').first;
    final parts = datePart.split('-');

    if (parts.length == 3) {
      final lastDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final daysSince = DateTime.now().difference(lastDate).inDays;
      setState(() { showNotification = daysSince >= 7; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("FitPanion"),
      centerTitle: true,
      backgroundColor: Colors.purple,
      leading: Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.mail),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WeeklyInputWindow(),
                ),
              );
            },
          ),
          if (showNotification)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
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

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  double calorieRatio = 0.0;
  double waterRatio = 0.0;
  double exerciseRatio = 0.0;
  double happyRatio = 0.0;
  String fitpanionImage = "assets/FitPanion.png";

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;
    final height = (data['height'] as num).toDouble();
    final age = data['age'] as int;
    final sex = data['sex'] as String;

    final List inputs = data['dailyInputs'] ?? [];
    final List weeklyinputs = data['weeklyInputs'] ?? [];
    double lastCaloriesEaten = 0;
    double lastExercise = 0;
    double lastWeight = 70;
    double lastWater = 0;
    double sexwaterAdjustment = 0;
    int sexexerciseAdjustment = 50;
    double ageAdjustment = 0;

    if (inputs.isNotEmpty) {
      final parts = (inputs.last as String).split(',');
      for (final part in parts) {
        if (part.startsWith('cal:')) {
          lastCaloriesEaten = double.tryParse(
              part.replaceFirst('cal:', '')) ?? 0;
        } else if (part.startsWith('exercise:')) {
          lastExercise = double.tryParse(
              part.replaceFirst('exercise:', '')) ?? 0;
        } else if (part.startsWith('water:')) {
          lastWater = double.tryParse(
              part.replaceFirst('water:', '')) ?? 0;
        }
      }
    }
    if (weeklyinputs.isNotEmpty) {
      final parts = (weeklyinputs.last as String).split(',');
      for (final part in parts) {
        if (part.startsWith('weight:')) {
          lastWeight = double.tryParse(
              part.replaceFirst('weight:', '')) ?? 0;
        }
      }
    }

    if (sex == 'male'){
      sexwaterAdjustment = 0.3;
      sexexerciseAdjustment = 50;
    }
    if (age > 40){
      ageAdjustment = (age - 40) *2.5;
    }

    final recommendedintake = (10 * lastWeight) + (6.25 * height) - (5 * age) + 5 + lastExercise;
    final recommendedwater = (((lastWeight * .033) + ((height - 170)*.01)) + sexwaterAdjustment) * 4.227;
    final recommendedexercise = ((lastWeight*3.5) + ((height -170) * 1.5) + sexexerciseAdjustment - ageAdjustment);


    setState(() {
      calorieRatio = lastCaloriesEaten / recommendedintake;
      if (calorieRatio >= 2 || calorieRatio < 0){
        calorieRatio = 0.0;
      }
      else if (calorieRatio >= 1){
        calorieRatio = 2 - calorieRatio;
      }
      waterRatio = lastWater / recommendedwater;
      if (waterRatio >= 2 || waterRatio < 0){
        waterRatio = 0.0;
      }
      else if (waterRatio >= 1){
        waterRatio = 2 - waterRatio;
      }
      exerciseRatio = lastExercise / recommendedexercise;
      if (exerciseRatio >= 2 || exerciseRatio < 0){
        exerciseRatio = 0.0;
      }
      else if (exerciseRatio >= 1){
        exerciseRatio = 2 - exerciseRatio;
      }
      happyRatio = (waterRatio + calorieRatio + exerciseRatio)/3;
      if(lastCaloriesEaten > recommendedintake + 100){
        fitpanionImage = "assets/FitPanionFat.png";
      }
      else if (lastCaloriesEaten < recommendedintake - 100){
        fitpanionImage = "assets/FitPanionSkinny.png";
      }
      else{
        fitpanionImage = "assets/FitPanionFit.png";
      }
    });
  }

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
                  buildStatBar("Calories", calorieRatio),
                  const SizedBox(height: 10),
                  buildStatBar("Water", waterRatio),
                  const SizedBox(height: 10),
                  buildStatBar("Exercise", exerciseRatio),
                  const SizedBox(height: 10),
                  buildStatBar("Happiness", happyRatio),
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
                    buildFitPanionImageBox(fitpanionImage),
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

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, String>> parsedEntries = [];
  List<Map<String, String>> parsedWeeklyEntries = [];
  bool isLoading = true;
  bool showingDaily = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    final List dailyInputs = data['dailyInputs'] ?? [];
    final List<Map<String, String>> entries = [];
    for (final input in dailyInputs.reversed) {
      final parts = (input as String).split(',');
      String date = '';
      String calories = '';
      String water = '';
      String exercise = '';
      for (final part in parts) {
        if (part.contains('-') && !part.startsWith('cal') &&
            !part.startsWith('water') && !part.startsWith('exercise')) {
          date = part;
        } else if (part.startsWith('cal:')) {
          calories = part.replaceFirst('cal:', '');
        } else if (part.startsWith('water:')) {
          water = part.replaceFirst('water:', '');
        } else if (part.startsWith('exercise:')) {
          exercise = part.replaceFirst('exercise:', '');
        }
      }
      entries.add({
        'date': date,
        'calories': calories,
        'water': water,
        'exercise': exercise,
      });
    }

    final List weeklyInputs = data['weeklyInputs'] ?? [];
    final List<Map<String, String>> weeklyEntries = [];
    for (final input in weeklyInputs.reversed) {
      final parts = (input as String).split(',');
      String date = '';
      String weight = '';
      for (final part in parts) {
        if (part.contains('-') && !part.startsWith('weight')) {
          date = part;
        } else if (part.startsWith('weight:')) {
          weight = part.replaceFirst('weight:', '');
        }
      }
      weeklyEntries.add({
        'date': date,
        'weight': weight,
      });
    }

    setState(() {
      parsedEntries = entries;
      parsedWeeklyEntries = weeklyEntries;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FitPanionAppBar(),
      backgroundColor: Colors.grey[200],
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() { showingDaily = true; }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: showingDaily ? Colors.purple : Colors.grey[300],
                            borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(8)),
                          ),
                          child: Center(
                            child: Text(
                              "Daily",
                              style: TextStyle(
                                color: showingDaily ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() { showingDaily = false; }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: showingDaily ? Colors.grey[300] : Colors.purple,
                            borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(8)),
                          ),
                          child: Center(
                            child: Text(
                              "Weekly",
                              style: TextStyle(
                                color: showingDaily ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: showingDaily
                    ? parsedEntries.isEmpty
                        ? const Center(child: Text("No daily entries yet."))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: parsedEntries.length,
                            itemBuilder: (context, index) {
                              final entry = parsedEntries[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry['date'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple,
                                        ),
                                      ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _statItem(Icons.local_fire_department,
                                              "Calories", "${entry['calories']} kcal", Colors.orange),
                                          _statItem(Icons.water_drop,
                                              "Water", "${entry['water']} cups", Colors.blue),
                                          _statItem(Icons.fitness_center,
                                              "Exercise", "${entry['exercise']} kcal", Colors.green),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                    : parsedWeeklyEntries.isEmpty
                        ? const Center(child: Text("No weekly entries yet."))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: parsedWeeklyEntries.length,
                            itemBuilder: (context, index) {
                              final entry = parsedWeeklyEntries[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry['date'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple,
                                        ),
                                      ),
                                      const Divider(),
                                      _statItem(Icons.monitor_weight,
                                          "Weight", "${entry['weight']} kg", Colors.purple),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
    );
  }

  Widget _statItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}