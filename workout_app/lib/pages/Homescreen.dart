import 'package:flutter/material.dart';
import 'package:workout_app/helpers/navigation_helper.dart';
import 'package:workout_app/helpers/settings_helper.dart';
import 'package:workout_app/helpers/vibration_helper.dart';
import 'package:workout_app/helpers/week_helper.dart';
import 'package:workout_app/pages/Settings.dart';
import '../helpers/pedometer_helper.dart';
import '../helpers/steps_calorie_helper.dart';
import '../models/week.dart';
import '../models/workout_template.dart';
import 'Workout_Template.dart';
import './Workout_Week.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../helpers/workout_template_helper.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../widgets/bmi_calculator_dialog.dart';
import '../widgets/workout_gallery.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _pedometerHelper = PedometerHelper();
  late StepsCalorieHelper _stepsCalorieHelper;
  int _steps = 0;
  double _caloriesBurned = 0.0;
  String _status = 'Initializing...';
  bool _isMockMode = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeHelpers();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    // cancel any pending operations got the idea from stackoverflow
    _pedometerHelper.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isDisposed && mounted && state == AppLifecycleState.resumed) {
      _initializePedometer();
    }
  }

  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted && (context != null)) {
      setState(fn);
    }
  }

  Future<void> _initializeHelpers() async {
    if (_isDisposed) return;

    try {
      final weight = await SettingsHelper.getWeight();
      _stepsCalorieHelper = StepsCalorieHelper(weightInKg: weight);
      await _initializePedometer();
    } catch (e) {
      print('Error initializing helpers: $e');
      _stepsCalorieHelper = StepsCalorieHelper(weightInKg: 70.0);
    }
  }

  Future<void> _updateWeight() async {
    if (_isDisposed) return;

    try {
      final weight = await SettingsHelper.getWeight();
      _stepsCalorieHelper = StepsCalorieHelper(weightInKg: weight);
      if (!_isDisposed && mounted) {
        _safeSetState(() {
          _caloriesBurned = _stepsCalorieHelper.calculateCaloriesBurned(_steps);
        });
      }
    } catch (e) {
      print('Error updating weight: $e');
    }
  }

  Future<void> _initializePedometer() async {
    if (_isDisposed || !mounted) return;

    try {
      await _pedometerHelper.initialize();

      if (_isDisposed || !mounted) return;

      _pedometerHelper.stepStream.listen(
        (steps) {
          _safeSetState(() {
            _steps = steps;
            _caloriesBurned =
                _stepsCalorieHelper.calculateCaloriesBurned(steps);
          });
        },
        onError: (error) {
          print('Step stream error: $error');
          _safeSetState(() {
            if (error.toString().contains('StepDetection not available') ||
                error.toString().contains('StepCount not available')) {
              _status = 'Step counter not available on this device';
            } else {
              _status = 'Error: $error';
            }
          });
        },
        cancelOnError: false,
      );

      if (_isDisposed || !mounted) return;

      _pedometerHelper.statusStream.listen(
        (status) {
          _safeSetState(() {
            _status = status;
            _isMockMode = _pedometerHelper.isMockMode;
          });
        },
        onError: (error) {
          print('Status stream error: $error');
          _safeSetState(() {
            if (error.toString().contains('StepDetection not available') ||
                error.toString().contains('StepCount not available')) {
              _status = 'Step counter not available on this device';
            } else {
              _status = 'Error: $error';
            }
          });
        },
        cancelOnError: false,
      );
    } catch (e) {
      print('Error initializing pedometer: $e');
      if (!_isDisposed && mounted) {
        _safeSetState(() {
          if (e.toString().contains('StepDetection not available') ||
              e.toString().contains('StepCount not available')) {
            _status = 'Step counter not available on this device';
          } else {
            _status = 'Error initializing: $e';
          }
        });
      }
    }
  }

  void _openGallery() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WorkoutGallery(),
      ),
    );
  }

  void _showBMICalculator() {
    showDialog(
      context: context,
      builder: (context) => const BMICalculatorDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return const SizedBox.shrink();
    }

    return WillPopScope(
      onWillPop: () async {
        if (!_isDisposed && mounted) {
          _safeSetState(() {});
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          title: const Text('Workout App', style: TextStyle(fontSize: 24)),
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _navigateToSettings,
            )
          ],
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStepsCard(),
                        const SizedBox(height: 16),
                        _buildStatusCard(),
                        const SizedBox(height: 16),
                        _buildWorkoutPlanCard(),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.photo_library),
                        onPressed: _openGallery,
                        tooltip: 'View Progress Photos',
                      ),
                      IconButton(
                        icon: const Icon(Icons.calculate),
                        onPressed: _showBMICalculator,
                        tooltip: 'Calculate BMI',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 24.0 * 2, horizontal: 16.0 * 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Steps Today',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$_steps',
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Calories: ${_caloriesBurned.toStringAsFixed(1)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Status',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _status,
              style: const TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            if (_isMockMode) ...[
              const SizedBox(height: 8),
              Text(
                '(Mock Mode - For Testing)',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutPlanCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Today\'s Plan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              DateFormat('EEEE').format(DateTime.now()),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            _buildTodaysWorkout(),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysWorkout() {
    return FutureBuilder<Week?>(
      future: WeekHelper.getTodaysWorkout(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return const Text('Error loading workout');
        }

        final todaysWorkout = snapshot.data;
        if (todaysWorkout != null) {
          return Column(
            children: [
              InkWell(
                onTap: () async {
                  if (!_isDisposed && mounted) {
                    try {
                      await NavigationHelper.push(
                        context,
                        'workout_template',
                        initialTemplate: WorkoutTemplate(
                          id: todaysWorkout.id ??
                              WorkoutTemplateHelper.generateId(),
                          name: todaysWorkout.name,
                          type: todaysWorkout.type,
                          exercises: todaysWorkout.exercises ?? [],
                          notes: todaysWorkout.notes,
                          duration: todaysWorkout.duration,
                        ),
                        isSelectionMode: false,
                        onTemplateSelected: (template) async {
                          if (!_isDisposed && context.mounted) {
                            try {
                              await WeekHelper.updateTodaysWorkout(Week(
                                id: template.id,
                                name: template.name,
                                type: template.type,
                                day: DateFormat('EEEE').format(DateTime.now()),
                                exercises: template.exercises,
                                notes: template.notes,
                                duration: template.duration,
                              ));
                              await WorkoutTemplateHelper
                                  .updateTemplateLastUsed(template.id);
                              if (!_isDisposed && context.mounted) {
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              print('Error updating workout: $e');
                            }
                          }
                        },
                      );
                      if (!_isDisposed && mounted) {
                        _safeSetState(() {});
                      }
                    } catch (e) {
                      print('Error navigating: $e');
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      todaysWorkout.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () async {
                  if (!_isDisposed && mounted) {
                    try {
                      await NavigationHelper.push(
                        context,
                        'workout_week',
                      );
                      if (!_isDisposed && mounted) {
                        _safeSetState(() {});
                      }
                    } catch (e) {
                      print('Error navigating to week view: $e');
                    }
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Week Schedule'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.purple,
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          );
        } else {
          return TextButton.icon(
            onPressed: () async {
              if (!_isDisposed && mounted) {
                try {
                  await NavigationHelper.push(
                    context,
                    'workout_week',
                  );
                  if (!_isDisposed && mounted) {
                    _safeSetState(() {});
                  }
                  VibrationHelper.vibrate();
                } catch (e) {
                  print('Error navigating to week view: $e');
                }
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Workout'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.purple,
              textStyle: const TextStyle(fontSize: 16),
            ),
          );
        }
      },
    );
  }

  void _navigateToSettings() async {
    if (!_isDisposed && mounted) {
      try {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Settings(
              toggleTheme: widget.toggleTheme,
              isDarkMode: widget.isDarkMode,
              onWeightChanged: _updateWeight,
            ),
          ),
        );
        if (!_isDisposed && mounted) {
          _safeSetState(() {});
        }
      } catch (e) {
        print('Error navigating to settings: $e');
      }
    }
  }
}
