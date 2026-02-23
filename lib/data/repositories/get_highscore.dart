import 'package:flash_pattern/data/repositories/score_repositories.dart';

class GetHighScore {
  final ScoreRepository repository;

  GetHighScore(this.repository);

  Future<int> call() => repository.getHighScore();
}