abstract class ScoreRepository {
  Future<int> getHighScore();
  Future<void> saveHighScore(int score);
}