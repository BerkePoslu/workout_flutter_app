class AppConfig {
  // AI generated class
  static const String baseUrl = 'https://workout-app-backend-delta.vercel.app';
  static const String apiVersion = 'api';

  static String getApiUrl(String endpoint) {
    return '$baseUrl/$apiVersion/$endpoint';
  }

  static const Map<String, String> endpoints = {
    'login': 'auth/login',
    'register': 'auth/register',
    'steps': 'steps',
    'weeklySteps': 'steps/weekly',
  };

  static String getFullUrl(String endpoint) {
    final path = endpoints[endpoint];
    if (path == null) {
      throw Exception('Invalid endpoint: $endpoint');
    }
    return getApiUrl(path);
  }
}
