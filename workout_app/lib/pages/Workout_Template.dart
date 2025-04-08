import 'package:flutter/material.dart';
import '../models/workout_template.dart';
import '../models/exercise.dart';
import '../helpers/workout_template_helper.dart';
import 'Exercise_Edit.dart';
import 'package:intl/intl.dart';

class WorkoutTemplateScreen extends StatefulWidget {
  final Function(WorkoutTemplate)? onTemplateSelected;
  final bool isSelectionMode;
  final WorkoutTemplate? initialTemplate;

  const WorkoutTemplateScreen({
    super.key,
    this.onTemplateSelected,
    this.isSelectionMode = false,
    this.initialTemplate,
  });

  @override
  State<WorkoutTemplateScreen> createState() => _WorkoutTemplateScreenState();
}

class _WorkoutTemplateScreenState extends State<WorkoutTemplateScreen> {
  List<WorkoutTemplate>? _templates;
  bool _isLoading = true;
  WorkoutTemplate? _currentTemplate;

  @override
  void initState() {
    super.initState();
    if (widget.initialTemplate != null) {
      _loadSingleTemplate(widget.initialTemplate!);
    } else {
      _loadTemplates();
    }
  }

  Future<void> _loadSingleTemplate(WorkoutTemplate template) async {
    try {
      // Load the latest version of the template from storage
      final templates = await WorkoutTemplateHelper.getAllTemplates();
      final latestTemplate = templates.firstWhere(
        (t) => t.id == template.id,
        orElse: () => template,
      );
      setState(() {
        _currentTemplate = latestTemplate;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentTemplate = template;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTemplates() async {
    try {
      final templates = await WorkoutTemplateHelper.getAllTemplates();
      if (mounted) {
        setState(() {
          _templates = templates;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _createTemplate() async {
    final newTemplate = WorkoutTemplate(
      id: WorkoutTemplateHelper.generateId(),
      name: 'New Workout',
      type: 'Custom',
      exercises: [],
    );
    await _showNameDialog(newTemplate, isNew: true);
  }

  Future<void> _showNameDialog(WorkoutTemplate template,
      {bool isNew = false}) async {
    final nameController = TextEditingController(text: template.name);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isNew ? 'Create Workout' : 'Edit ${template.name}'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Workout Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final updatedTemplate = template.copyWith(
        name: nameController.text.trim(),
        lastUsed: DateTime.now(),
      );

      try {
        await WorkoutTemplateHelper.saveTemplate(updatedTemplate);
        if (mounted) {
          setState(() {
            if (isNew) {
              _currentTemplate = updatedTemplate;
            } else if (_currentTemplate?.id == template.id) {
              _currentTemplate = updatedTemplate;
            }
          });
          await _loadTemplates();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save workout')),
          );
        }
      }
    }
  }

  Future<void> _editExercise(
      WorkoutTemplate template, Exercise? exercise) async {
    final nameController = TextEditingController(text: exercise?.name ?? '');
    final weightController =
        TextEditingController(text: exercise?.weight.toString() ?? '');
    final setsController =
        TextEditingController(text: exercise?.sets.toString() ?? '');
    final repsController =
        TextEditingController(text: exercise?.reps.toString() ?? '');
    final notesController = TextEditingController(text: exercise?.notes ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercise == null ? 'New Exercise' : 'Edit Exercise'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Exercise Name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(
                  labelText: 'Current Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: setsController,
                      decoration: const InputDecoration(
                        labelText: 'Sets',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: repsController,
                      decoration: const InputDecoration(
                        labelText: 'Reps',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final updatedExercise = Exercise(
                name: nameController.text,
                weight: double.tryParse(weightController.text) ?? 0.0,
                sets: int.tryParse(setsController.text) ?? 0,
                reps: int.tryParse(repsController.text) ?? 0,
                notes:
                    notesController.text.isEmpty ? null : notesController.text,
              );

              final exercises = List<Exercise>.from(template.exercises);
              final index =
                  exercises.indexWhere((e) => e.name == exercise?.name);
              if (index >= 0) {
                exercises[index] = updatedExercise;
              } else {
                exercises.add(updatedExercise);
              }

              final updatedTemplate = template.copyWith(
                exercises: exercises,
                lastUsed: DateTime.now(),
              );

              try {
                await WorkoutTemplateHelper.saveTemplate(updatedTemplate);
                if (mounted) {
                  setState(() {
                    if (_currentTemplate?.id == template.id) {
                      _currentTemplate = updatedTemplate;
                    }
                  });
                  await _loadTemplates();
                  if (widget.onTemplateSelected != null) {
                    widget.onTemplateSelected!(updatedTemplate);
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to save exercise')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise, WorkoutTemplate template) {
    return Dismissible(
      key: Key('${template.id}-${exercise.name}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove Exercise'),
            content:
                Text('Are you sure you want to remove "${exercise.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Remove'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        final exercises = List<Exercise>.from(template.exercises);
        exercises.removeWhere((e) => e.name == exercise.name);

        final updatedTemplate = template.copyWith(
          exercises: exercises,
          lastUsed: DateTime.now(),
        );

        try {
          await WorkoutTemplateHelper.saveTemplate(updatedTemplate);
          if (mounted) {
            setState(() {
              if (_currentTemplate?.id == template.id) {
                _currentTemplate = updatedTemplate;
              }
            });
            await _loadTemplates();
            if (widget.onTemplateSelected != null) {
              widget.onTemplateSelected!(updatedTemplate);
            }
            // Show a snackbar to confirm deletion
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${exercise.name} removed'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to remove exercise')),
            );
          }
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          title: Text(
            exercise.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current weight: ${exercise.weight}kg'),
              Text('${exercise.sets}×${exercise.reps} Reps'),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editExercise(template, exercise),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleWorkoutView(WorkoutTemplate template) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            template.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (template.exercises.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No exercises yet',
                style: TextStyle(fontSize: 16),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: template.exercises.length,
              itemBuilder: (context, index) {
                return _buildExerciseCard(
                  template.exercises[index],
                  template,
                );
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _editExercise(template, null),
            icon: const Icon(Icons.add),
            label: const Text('Add Exercise'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),
        ),
      ],
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTemplate?.name ?? 'Workouts'),
        leading: BackButton(
          onPressed: () {
            if (_currentTemplate != null && widget.onTemplateSelected != null) {
              widget.onTemplateSelected!(_currentTemplate!);
            }
          },
        ),
        actions: _currentTemplate != null && !widget.isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showNameDialog(_currentTemplate!),
                  tooltip: 'Edit Name',
                ),
              ]
            : null,
      ),
      body: _currentTemplate != null
          ? _buildSingleWorkoutView(_currentTemplate!)
          : _templates == null || _templates!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No workouts yet',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _createTemplate,
                        icon: const Icon(Icons.add),
                        label: const Text('Create Workout'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _templates!.length,
                  itemBuilder: (context, index) {
                    final template = _templates![index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(
                          template.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${template.exercises.length} exercises',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                setState(() {
                                  _currentTemplate = template;
                                });
                              },
                              tooltip: 'Edit Exercises',
                            ),
                            if (!widget.isSelectionMode)
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteTemplate(template),
                                tooltip: 'Delete Workout',
                              ),
                          ],
                        ),
                        onTap: widget.onTemplateSelected != null
                            ? () => widget.onTemplateSelected!(template)
                            : () {
                                setState(() {
                                  _currentTemplate = template;
                                });
                              },
                      ),
                    );
                  },
                ),
      floatingActionButton: _currentTemplate == null
          ? FloatingActionButton(
              onPressed: _createTemplate,
              child: const Icon(Icons.add),
              tooltip: 'Create Workout',
            )
          : null,
    );
  }

  Future<void> _deleteTemplate(WorkoutTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await WorkoutTemplateHelper.deleteTemplate(template.id);
        _loadTemplates();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete template')),
          );
        }
      }
    }
  }
}
