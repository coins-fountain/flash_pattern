import 'package:flash_pattern/data/repositories/score_repositories.dart';

class SaveHighScore {
  final ScoreRepository repository;

  SaveHighScore(this.repository);

  Future<void> call(int score) {
    return repository.saveHighScore(score);
  }
}