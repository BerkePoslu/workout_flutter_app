import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockClient mockClient;

    setUp(() {
      authService = AuthService();
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state should be unauthenticated', () {
      expect(authService.isAuthenticated, false);
      expect(authService.token, null);
      expect(authService.userId, null);
      expect(authService.username, null);
    });

    test('login should update state on success', () async {
      mockClient = MockClient((request) async {
        return http.Response(
          '''{
            "token": "test_token",
            "user": {
              "id": "user_1",
              "name": "Test User"
            }
          }''',
          200,
        );
      });

      await authService.login('test@example.com', 'password');

      expect(authService.isAuthenticated, true);
      expect(authService.token, 'test_token');
      expect(authService.userId, 'user_1');
      expect(authService.username, 'Test User');
    });

    test('login should handle error gracefully', () async {
      mockClient = MockClient((request) async {
        return http.Response('Error', 401);
      });

      expect(
        () async =>
            await authService.login('test@example.com', 'wrong_password'),
        throwsException,
      );

      expect(authService.isAuthenticated, false);
    });

    test('logout should clear all data', () async {
      // First login
      mockClient = MockClient((request) async {
        return http.Response(
          '''{
            "token": "test_token",
            "user": {
              "id": "user_1",
              "name": "Test User"
            }
          }''',
          200,
        );
      });

      await authService.login('test@example.com', 'password');
      await authService.logout();

      expect(authService.isAuthenticated, false);
      expect(authService.token, null);
      expect(authService.userId, null);
      expect(authService.username, null);
    });
  });
}
