import 'package:flutter/material.dart';
import '../models/week.dart';
import '../helpers/week_helper.dart';
import './workout_template.dart';
import '../models/workout_template.dart';
import '../helpers/workout_template_helper.dart';

class WorkoutWeek extends StatefulWidget {
  const WorkoutWeek({super.key});

  @override
  State<WorkoutWeek> createState() => _WorkoutWeekState();
}

class _WorkoutWeekState extends State<WorkoutWeek> {
  Map<String, Week?>? _weekSchedule;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeekSchedule();
  }

  Future<void> _loadWeekSchedule() async {
    try {
      final schedule = await WeekHelper.getWeekSchedule();
      setState(() {
        _weekSchedule = schedule;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading week schedule: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _createWorkout(String day) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Workout for $day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Create New Workout'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutTemplateScreen(
                      onTemplateSelected: (template) {
                        setState(() {
                          _weekSchedule![day] = Week(
                            id: template.id,
                            name: template.name,
                            type: template.type,
                            day: day,
                            exercises: [...template.exercises],
                            notes: template.notes,
                            duration: template.duration,
                          );
                        });
                        WeekHelper.updateWeekSchedule(_weekSchedule!);
                        WorkoutTemplateHelper.updateTemplateLastUsed(
                            template.id);
                        Navigator.pop(context);
                      },
                      isSelectionMode: false,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Use Template'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutTemplateScreen(
                      onTemplateSelected: (template) {
                        setState(() {
                          _weekSchedule![day] = Week(
                            id: template.id,
                            name: template.name,
                            type: template.type,
                            day: day,
                            exercises: [...template.exercises],
                            notes: template.notes,
                            duration: template.duration,
                          );
                        });
                        WeekHelper.updateWeekSchedule(_weekSchedule!);
                        WorkoutTemplateHelper.updateTemplateLastUsed(
                            template.id);
                        Navigator.pop(context);
                      },
                      isSelectionMode: true,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_weekSchedule == null) {
      return const Scaffold(
        body: Center(
          child: Text('Error loading week schedule'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Week View'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _weekSchedule!.entries.map((entry) {
              return Column(
                children: [
                  _buildDaySection(entry.key, entry.value),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDaySection(String day, Week? workout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          day,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: InkWell(
            onTap: () => workout == null
                ? _createWorkout(day)
                : _editWorkout(day, workout),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout?.name ?? 'create...',
                          style: TextStyle(
                            fontSize: 16,
                            color: workout == null ? Colors.grey : null,
                          ),
                        ),
                        if (workout?.exercises?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${workout!.exercises!.length} exercises',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        if (workout?.duration != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${workout!.duration!.inMinutes} minutes',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (workout != null)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _removeWorkout(day),
                      tooltip: 'Remove workout',
                      color: Colors.red[300],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _editWorkout(String day, Week workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutTemplateScreen(
          onTemplateSelected: (template) {
            setState(() {
              _weekSchedule![day] = Week(
                id: template.id,
                name: template.name,
                type: template.type,
                day: day,
                exercises: [...template.exercises],
                notes: template.notes,
                duration: template.duration,
              );
            });
            WeekHelper.updateWeekSchedule(_weekSchedule!);
            Navigator.pop(context);
          },
          isSelectionMode: false,
          initialTemplate: WorkoutTemplate(
            id: workout.id ?? WorkoutTemplateHelper.generateId(),
            name: workout.name,
            type: workout.type,
            exercises: workout.exercises ?? [],
            notes: workout.notes,
            duration: workout.duration,
          ),
        ),
      ),
    );
  }

  void _removeWorkout(String day) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Workout'),
        content: const Text('Are you sure you want to remove this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _weekSchedule![day] = null;
              });
              WeekHelper.updateWeekSchedule(_weekSchedule!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Workout removed'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Remove'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}
