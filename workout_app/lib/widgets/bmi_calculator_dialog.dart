import 'package:flutter/material.dart';
import '../helpers/settings_helper.dart';

class BMICalculatorDialog extends StatefulWidget {
  const BMICalculatorDialog({super.key});

  @override
  State<BMICalculatorDialog> createState() => _BMICalculatorDialogState();
}

class _BMICalculatorDialogState extends State<BMICalculatorDialog> {
  double? _bmi;
  String? _bmiCategory;
  double? _height;
  double? _weight;

  @override
  void initState() {
    super.initState();
    _calculateBMI();
  }

  Future<void> _calculateBMI() async {
    _height = await SettingsHelper.getHeight();
    _weight = await SettingsHelper.getWeight();

    if (_height! > 0 && _weight! > 0) {
      final heightInMeters = _height! / 100;
      final bmi = _weight! / (heightInMeters * heightInMeters);

      String category;
      if (bmi < 18.5) {
        category = 'Underweight';
      } else if (bmi < 25) {
        category = 'Normal weight';
      } else if (bmi < 30) {
        category = 'Overweight';
      } else {
        category = 'Obese';
      }

      setState(() {
        _bmi = bmi;
        _bmiCategory = category;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('BMI Calculator'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_bmi != null) ...[
            Text(
              'Your BMI: ${_bmi!.toStringAsFixed(1)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Category: $_bmiCategory',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Based on:\nHeight: ${_height!.toStringAsFixed(1)} cm\nWeight: ${_weight!.toStringAsFixed(1)} kg',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ] else
            const Text('Please set your height and weight in settings'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
