import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'ble_service.dart';
import 'main.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final List<WorkoutSet> playlist;
  const ActiveWorkoutScreen({super.key, required this.playlist});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  int currentSetIndex = 0;
  bool isFinished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BleService>(context, listen: false).resetTrainingData();
      _sendCurrentSetToGlove();
    });
  }

  void _sendCurrentSetToGlove() {
    final bleService = Provider.of<BleService>(context, listen: false);
    final currentSet = widget.playlist[currentSetIndex];
    int exerciseId = 0;

    bleService.sendWorkoutSetup(
        1,
        exerciseId,
        currentSet.targetReps,
        currentSet.weightKg
    );

    print("Sende Setup an Glove: Start=1, ExID=$exerciseId, Reps=${currentSet.targetReps}");
  }

  void _nextSet() {
    final bleService = Provider.of<BleService>(context, listen: false);

    widget.playlist[currentSetIndex].actualReps = bleService.currentReps;
    widget.playlist[currentSetIndex].repFeedbacks = List.from(bleService.currentSetFeedbacks);

    if (currentSetIndex < widget.playlist.length - 1) {
      setState(() => currentSetIndex++);
      bleService.resetTrainingData();
      _sendCurrentSetToGlove();
    } else {
      setState(() => isFinished = true);
      bleService.sendWorkoutSetup(0, 0, 0, 0.0);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutSummaryScreen(session: WorkoutSession(date: DateTime.now(), sets: widget.playlist)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.playlist.isEmpty) return const Scaffold(body: Center(child: Text("No workout planned.")));
    final currentSet = widget.playlist[currentSetIndex];

    return Consumer<BleService>(
      builder: (context, bleService, child) {
        if (bleService.currentReps >= currentSet.targetReps && !isFinished) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _nextSet());
        }

        return Scaffold(
          appBar: AppBar(
            title: Text("Set ${currentSetIndex + 1} of ${widget.playlist.length}"),
            automaticallyImplyLeading: false,
            elevation: 0,
          ),
          body: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentSet.exercise.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
                  child: Text("Weight: ${currentSet.weightKg} kg", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 50),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: currentSet.targetReps > 0 ? (bleService.currentReps / currentSet.targetReps).clamp(0.0, 1.0) : 0,
                        strokeWidth: 18,
                        backgroundColor: Colors.grey.shade300,
                        color: Theme.of(context).primaryColor,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      children: [
                        Text("${bleService.currentReps}", style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w900, color: Colors.black87)),
                        Text("/ ${currentSet.targetReps} Reps", style: const TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.psychology_alt, color: Theme.of(context).primaryColor, size: 30),
                      const SizedBox(width: 15),
                      Flexible(
                        child: Text(
                          bleService.currentFeedback,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade800,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _nextSet,
                    child: const Text("NEXT SET", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}