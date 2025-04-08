import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:isolate';
import 'steps_persistence_helper.dart';

// AI generated Error Handling
// Pedometer Helper class
// Author: Berke Poslu
// Date: 2025-04-07
// Description: Helper class for pedometer functionality, error handling with AI

class PedometerHelper {
  Stream<StepCount>? _stepCountStream;
  Stream<PedestrianStatus>? _pedestrianStatusStream;
  Timer? _mockStepTimer;
  bool _isMockMode = false;
  int _steps = 0;
  String _status = 'Initializing...';
  Isolate? _isolate;
  ReceivePort? _receivePort;

  // getters
  bool get isMockMode => _isMockMode; // mock for testing and emulation
  int get steps => _steps;
  String get status => _status;

  // stream controllers for external listeners
  final _stepController = StreamController<int>.broadcast();
  final _statusController = StreamController<String>.broadcast();

  // stream getters for external listeners
  Stream<int> get stepStream => _stepController.stream;
  Stream<String> get statusStream => _statusController.stream;

  Future<void> initialize() async {
    try {
      _steps = await StepsPersistenceHelper.getCurrentSteps();
      _stepController.add(_steps);

      final status = await Permission.activityRecognition.request();
      if (status.isGranted) {
        await _initPedometer();
      } else {
        _updateStatus('Please grant activity recognition permission');
        _startMockStepCounter();
      }
    } catch (e) {
      _updateStatus('Error initializing pedometer: $e');
      _startMockStepCounter();
    }
  }

  Future<void> _initPedometer() async {
    try {
      // check if pedometer is available before trying to use it
      bool isAvailable = false;
      try {
        // try to access the stream to see if its available
        Pedometer.stepCountStream;
        isAvailable = true;
      } catch (e) {
        isAvailable = false;
      }

      if (!isAvailable) {
        _updateStatus('Step counter not available on this device');
        _startMockStepCounter();
        return;
      }

      _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
      _stepCountStream = Pedometer.stepCountStream;

      if (_pedestrianStatusStream != null) {
        _pedestrianStatusStream!.listen(
          onPedestrianStatusChanged,
          onError: (error) {
            onPedestrianStatusError(error);
          },
          cancelOnError: false,
        );
      }

      if (_stepCountStream != null) {
        _stepCountStream!.listen(
          onStepCount,
          onError: (error) {
            onStepCountError(error);
          },
          cancelOnError: false,
        );
      } else {
        _updateStatus('Step counter not available');
        _startMockStepCounter();
      }
    } catch (e) {
      // check for specific error messages
      if (e.toString().contains('StepDetection not available') ||
          e.toString().contains('StepCount not available')) {
        _updateStatus('Step counter not available on this device');
      } else {
        _updateStatus('Error initializing step counter: $e');
      }
      _startMockStepCounter();
    }
  }

  void _startMockStepCounter() {
    try {
      _isMockMode = true;
      _updateStatus('Mock Mode (Testing)');

      _mockStepTimer?.cancel(); // cancel any existing timer AI generated
      _mockStepTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        try {
          _updateSteps(_steps + 2);
        } catch (e) {
          timer.cancel();
        }
      });
    } catch (e) {
      _updateStatus('Error starting mock counter: $e');
    }
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    _updateStatus(event.status);
  }

  void onPedestrianStatusError(error) {
    _updateStatus('Pedestrian Status not available');
  }

  void onStepCount(StepCount event) {
    _updateSteps(event.steps);
  }

  void onStepCountError(error) {
    // check for specific error messages
    if (error.toString().contains('StepDetection not available') ||
        error.toString().contains('StepCount not available')) {
      _updateStatus('Step counter not available on this device');
    } else {
      _updateStatus('Step Count not available');
    }
    _startMockStepCounter();
  }

  void _updateSteps(int newSteps) {
    _steps = newSteps;
    _stepController.add(_steps);
    StepsPersistenceHelper.saveCurrentSteps(_steps);
  }

  void _updateStatus(String newStatus) {
    _status = newStatus;
    _statusController.add(_status);
  }

  // AI generated - Add method to reset step count
  void resetSteps() {
    try {
      _updateSteps(0);
    } catch (e) {
      // Error in resetSteps (removed print statement)
    }
  }

  void dispose() {
    _mockStepTimer?.cancel();
    _stepController.close();
    _statusController.close();
    _isolate?.kill();
    _receivePort?.close();
  }
}
