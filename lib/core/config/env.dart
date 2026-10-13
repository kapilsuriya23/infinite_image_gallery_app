import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get pixabayApiKey =>
      dotenv.isInitialized ? (dotenv.maybeGet('PIXABAY_API_KEY') ?? '') : '';

  static bool get hasApiKey => pixabayApiKey.isNotEmpty;
}