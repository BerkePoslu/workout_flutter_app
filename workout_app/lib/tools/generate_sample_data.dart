import '../helpers/sample_data_generator.dart';

void main() {
  // Generate and print a single day of step data
  print('\n--- SINGLE DAY SAMPLE ---');
  SampleDataGenerator.printSampleDataForPostman();

  // Generate and print a week of step data
  print('\n--- WEEKLY SAMPLE ---');
  SampleDataGenerator.printSampleDataForPostman(weekly: true);

  // Generate custom data for a specific user ID
  print('\n--- CUSTOM USER ID SAMPLE ---');
  SampleDataGenerator.printSampleDataForPostman(userId: 'custom_admin_123');

  // Example of how to use the generated data in your code
  final sampleDailySteps = SampleDataGenerator.generateAdminDailySteps();
  print('\n--- SAMPLE OBJECT PROPERTIES ---');
  print('ID: ${sampleDailySteps.id}');
  print('User ID: ${sampleDailySteps.userId}');
  print('Steps: ${sampleDailySteps.steps}');
  print('Date: ${sampleDailySteps.date}');
}
