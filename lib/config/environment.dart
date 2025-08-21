class Environment {
  static const String _environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'production');
  
  static bool get isDevelopment => _environment == 'development';
  static bool get isProduction => _environment == 'production';
  
  static String get current => _environment;
}
