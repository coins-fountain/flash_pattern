import 'package:shared_preferences/shared_preferences.dart';

class ScoreService {
  static const _keyHighScore = "high_score";

  Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyHighScore) ?? 0;
  }

  Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHighScore, score);
  }
}