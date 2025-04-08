import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/helpers/steps_persistence_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'steps_persistence_helper_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('StepsPersistenceHelper Tests', () {
    late MockClient mockClient;

    setUp(() {
      // Initialize mock client
      mockClient = MockClient();
      StepsPersistenceHelper.httpClient = mockClient;

      // Set up shared preferences with token
      SharedPreferences.setMockInitialValues({'token': 'test_token'});
    });

    test('getWeeklySteps should parse response correctly', () async {
      // Mock the HTTP response
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
            '''[
          {"id": "step_1", "userId": "user_1", "steps": 5000, "date": "2024-04-08T12:00:00.000Z"},
          {"id": "step_2", "userId": "user_1", "steps": 6000, "date": "2024-04-09T12:00:00.000Z"}
        ]''',
            200,
          ));

      final steps = await StepsPersistenceHelper.getWeeklySteps('user_1');

      expect(steps.length, 2);
      expect(steps[0].steps, 5000);
      expect(steps[1].steps, 6000);
      expect(steps[0].userId, 'user_1');
      expect(steps[1].userId, 'user_1');
    });

    test('getWeeklySteps should return empty list on error', () async {
      // Mock the HTTP response with error
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('Error', 500));

      final steps = await StepsPersistenceHelper.getWeeklySteps('user_1');
      expect(steps, isEmpty);
    });

    test('saveCurrentSteps and getCurrentSteps should work correctly',
        () async {
      await StepsPersistenceHelper.saveCurrentSteps(5000);
      final steps = await StepsPersistenceHelper.getCurrentSteps();
      expect(steps, 5000);
    });

    test('getCurrentSteps should return 0 when no steps saved', () async {
      final steps = await StepsPersistenceHelper.getCurrentSteps();
      expect(steps, 0);
    });
  });
}
