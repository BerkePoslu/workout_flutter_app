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
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:fl_chart/fl_chart.dart';
import '../helpers/steps_persistence_helper.dart';
import '../models/daily_steps.dart';

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
  bool _isDisposed = false;
  List<DailySteps> _weeklySteps = [];
  bool _isLoadingWeeklyData = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeHelpers();
    _loadWeeklySteps();
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
      // AI generated - removed print statement
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
          // AI generated - removed error handling for status
        },
        cancelOnError: false,
      );

      // Removed status stream listener
    } catch (e) {
      // AI generated - removed print statement and status updates
    }
  }

  Future<void> _loadWeeklySteps() async {
    if (!mounted) return;

    setState(() => _isLoadingWeeklyData = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      if (authService.userId != null) {
        final steps =
            await StepsPersistenceHelper.getWeeklySteps(authService.userId!);
        if (mounted) {
          setState(() {
            _weeklySteps = steps;
            _isLoadingWeeklyData = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoadingWeeklyData = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingWeeklyData = false);
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

  Widget _buildWeeklyChart() {
    if (_isLoadingWeeklyData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_weeklySteps.isEmpty) {
      return const Center(
        child: Text('No steps data available for this week'),
      );
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDarkMode ? Colors.white : Theme.of(context).primaryColor;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _weeklySteps
                  .map((e) => e.steps.toDouble())
                  .reduce((a, b) => a > b ? a : b) *
              1.2,
          barGroups: _weeklySteps.asMap().entries.map((entry) {
            final day = entry.value.date.weekday;
            final steps = entry.value.steps;
            return BarChartGroupData(
              x: day,
              barRods: [
                BarChartRodData(
                  toY: steps.toDouble(),
                  color: barColor,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun'
                  ];
                  return Text(
                    days[value.toInt() - 1],
                    style: TextStyle(color: textColor),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final number = value.toInt();
                  final displayText = number >= 1000
                      ? '${(number / 1000).toStringAsFixed(1)}k'
                      : number.toString();
                  return Text(
                    displayText,
                    style: TextStyle(color: textColor, fontSize: 12),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return const SizedBox.shrink();
    }

    return PopScope(
      canPop: true,
      // AI generated - onPopInvoked
      onPopInvoked: (didPop) {
        if (!_isDisposed && mounted) {
          _safeSetState(() {});
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          title: Consumer<AuthService>(
            builder: (context, authService, _) => Text(
              authService.username != null
                  ? 'Hello ${authService.username}'
                  : 'Hello User',
              style: const TextStyle(fontSize: 24),
            ),
          ),
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
                        horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(height: 8),
                        _buildStepsCard(),
                        const SizedBox(height: 24),
                        _buildWeeklyChart(),
                        const SizedBox(height: 24),
                        _buildWorkoutPlanCard(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.1),
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
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Steps Today',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '$_steps',
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Calories: ${_caloriesBurned.toStringAsFixed(1)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Today\'s Plan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE').format(DateTime.now()),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
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
                              // Error updating workout (removed print statement)
                            }
                          }
                        },
                      );
                      if (!_isDisposed && mounted) {
                        _safeSetState(() {});
                      }
                    } catch (e) {
                      // Error navigating (removed print statement)
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
                      // Error navigating to week view (removed print statement)
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
                  // Error navigating to week view (removed print statement)
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
        // Error navigating to settings (removed print statement)
      }
    }
  }
}
