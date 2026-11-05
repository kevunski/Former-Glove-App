import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ble_service.dart';
import 'models.dart';
import 'active_workout_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => BleService()..init())],
      child: const FormerApp(),
    ),
  );
}

class FormerApp extends StatelessWidget {
  const FormerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Former',
      theme: ThemeData(
        primaryColor: const Color(0xFF0F4C81),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F4C81)),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F4C81),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
      ),
      home: const StartScreen(),
    );
  }
}

// --- SCREEN 1: START SCREEN ---
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'Logo.png',
              width: 280,
              height: 280,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            const Text(
              "FORMER",
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 4.0),
            ),
            Text(
              "SMART GLOVE TRAINER",
              style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8), letterSpacing: 2.0, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 80),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
              ),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MenuScreen())),
              child: const Text("START TRAINING", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}

// --- SCREEN 2: MENU & EXERCISE SELECTION ---
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final List<Exercise> availableExercises = [
    Exercise(id: '1', name: 'Bicep Curls', description: 'Dumbbell arm flexion'),
    Exercise(id: '2', name: 'Lateral Raises', description: 'Shoulder muscle training'),
    Exercise(id: '3', name: 'Bench Press', description: 'Chest muscle barbell training'),
  ];
  List<Exercise> selectedExercises = [];
  bool isCreatingSet = false;

  @override
  Widget build(BuildContext context) {
    final bleService = Provider.of<BleService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Former", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: bleService.isConnected ? Colors.green.shade500 : Colors.red.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(bleService.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(bleService.isConnected ? "Connected" : "Searching...", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen())),
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_events, color: Colors.white, size: 32),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Workout History", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("View past performances & AI feedback", style: TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              isCreatingSet ? "Select exercises for your workout:" : "Available exercises:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.blueGrey.shade800),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: availableExercises.length,
              itemBuilder: (context, index) {
                final exercise = availableExercises[index];
                final isSelected = selectedExercises.contains(exercise);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: (isCreatingSet && isSelected) ? BorderSide(color: Theme.of(context).primaryColor, width: 2) : BorderSide.none,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text("${index + 1}", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 18))),
                    ),
                    title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Padding(padding: const EdgeInsets.only(top: 4.0), child: Text(exercise.description, style: TextStyle(color: Colors.grey.shade600))),
                    trailing: isCreatingSet
                        ? Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade400, size: 30)
                        : Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    onTap: () {
                      if (isCreatingSet) {
                        setState(() { isSelected ? selectedExercises.remove(exercise) : selectedExercises.add(exercise); });
                      } else {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            content: Text(exercise.description),
                            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SafeArea(
              child: isCreatingSet
                  ? Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: BorderSide(color: Colors.grey.shade400)),
                      onPressed: () => setState(() { isCreatingSet = false; selectedExercises.clear(); }),
                      child: const Text("Cancel", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)),
                      onPressed: selectedExercises.isEmpty ? null : () {
                        final list = List<Exercise>.from(selectedExercises);
                        setState(() { isCreatingSet = false; selectedExercises.clear(); });
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SetupWorkoutScreen(selectedExercises: list)));
                      },
                      child: Text("Next (${selectedExercises.length})", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, padding: const EdgeInsets.symmetric(vertical: 18)),
                  onPressed: () => setState(() => isCreatingSet = true),
                  child: const Text("CREATE SET", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseConfig {
  final Exercise exercise;
  int setsCount = 3;
  int targetReps = 10;
  double weightKg = 0;
  _ExerciseConfig(this.exercise);
}

// --- SCREEN 3: SETUP SCREEN ---
class SetupWorkoutScreen extends StatefulWidget {
  final List<Exercise> selectedExercises;
  const SetupWorkoutScreen({super.key, required this.selectedExercises});

  @override
  State<SetupWorkoutScreen> createState() => _SetupWorkoutScreenState();
}

class _SetupWorkoutScreenState extends State<SetupWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<_ExerciseConfig> configs;

  @override
  void initState() {
    super.initState();
    configs = widget.selectedExercises.map((e) => _ExerciseConfig(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Workout Setup")),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: configs.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final config = configs[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                                child: Text("${index + 1}", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Text(config.exercise.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Divider(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Number of sets:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                              SizedBox(
                                width: 80,
                                child: TextFormField(
                                  initialValue: config.setsCount.toString(),
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    filled: true, fillColor: Colors.grey.shade50,
                                  ),
                                  onChanged: (v) => config.setsCount = int.tryParse(v) ?? 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: config.targetReps.toString(),
                                  decoration: InputDecoration(
                                    labelText: "Reps per set", prefixIcon: const Icon(Icons.repeat),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    filled: true, fillColor: Colors.grey.shade50,
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) => config.targetReps = int.tryParse(v) ?? 10,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  initialValue: config.weightKg.toString(),
                                  decoration: InputDecoration(
                                    labelText: "Weight (kg)", prefixIcon: const Icon(Icons.fitness_center),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    filled: true, fillColor: Colors.grey.shade50,
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) => config.weightKg = double.tryParse(v) ?? 0,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        List<WorkoutSet> finalPlaylist = [];
                        for (var config in configs) {
                          for (int i = 0; i < config.setsCount; i++) {
                            finalPlaylist.add(WorkoutSet(exercise: config.exercise, targetReps: config.targetReps, weightKg: config.weightKg));
                          }
                        }
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ActiveWorkoutScreen(playlist: finalPlaylist)));
                      }
                    },
                    child: const Text("START WORKOUT", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- WORKOUT SUMMARY SCREEN ---
class WorkoutSummaryScreen extends StatefulWidget {
  final WorkoutSession session;
  const WorkoutSummaryScreen({super.key, required this.session});

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> {
  @override
  void initState() {
    super.initState();
    _saveSession();
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedSessions = prefs.getStringList('workout_history') ?? [];
    savedSessions.add(jsonEncode(widget.session.toJson()));
    await prefs.setStringList('workout_history', savedSessions);
  }

  Map<String, int> _countFeedbacks(List<String> feedbacks) {
    var counts = <String, int>{};
    for (var f in feedbacks) {
      counts[f] = (counts[f] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Workout Summary"), automaticallyImplyLeading: false),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Theme.of(context).primaryColor,
            child: const Column(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber, size: 60),
                SizedBox(height: 10),
                Text("Great job!", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                Text("Here is your AI evaluation:", style: TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.session.sets.length,
              itemBuilder: (context, index) {
                final set = widget.session.sets[index];
                final feedbackCounts = _countFeedbacks(set.repFeedbacks);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${set.exercise.name} - Set ${index + 1}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("${set.actualReps} / ${set.targetReps} Reps | ${set.weightKg} kg", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                        const Divider(height: 24),
                        const Text("AI feedback per repetition:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        if (feedbackCounts.isEmpty) const Text("No data recorded.", style: TextStyle(fontStyle: FontStyle.italic)),
                        ...feedbackCounts.entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            children: [
                              Icon(entry.key.contains("correct form") ? Icons.check_circle : Icons.warning_amber_rounded,
                                  color: entry.key.contains("correct form") ? Colors.green : Colors.orange, size: 18),
                              const SizedBox(width: 8),
                              Text("${entry.value}x", style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(entry.key)),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("BACK TO MENU", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// --- HISTORY SCREEN ---
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<WorkoutSession> sessions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedData = prefs.getStringList('workout_history') ?? [];

    setState(() {
      sessions = savedData.map((s) => WorkoutSession.fromJson(jsonDecode(s))).toList();
      sessions.sort((a, b) => b.date.compareTo(a.date));
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Performances")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : sessions.isEmpty
          ? const Center(child: Text("No workouts completed yet. Get started!", style: TextStyle(fontSize: 16, color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          // Simple formatting YYYY-MM-DD
          final dateStr = "${session.date.year}-${session.date.month.toString().padLeft(2, '0')}-${session.date.day.toString().padLeft(2, '0')} - ${session.date.hour}:${session.date.minute.toString().padLeft(2, '0')}";

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.fitness_center, color: Theme.of(context).primaryColor),
              ),
              title: Text("Workout from $dateStr", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${session.sets.length} sets completed"),
              children: session.sets.map((set) {
                var counts = <String, int>{};
                for (var f in set.repFeedbacks) { counts[f] = (counts[f] ?? 0) + 1; }

                return ListTile(
                  title: Text(set.exercise.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${set.actualReps} Reps | ${set.weightKg} kg"),
                      const SizedBox(height: 4),
                      ...counts.entries.map((e) => Text("• ${e.value}x ${e.key}", style: const TextStyle(fontSize: 12))),
                      const Divider(),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}