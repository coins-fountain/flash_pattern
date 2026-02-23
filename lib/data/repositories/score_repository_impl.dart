
import 'package:flash_pattern/core/utils/preferences.dart';
import 'package:flash_pattern/data/repositories/score_repositories.dart';

class ScoreRepositoryImpl implements ScoreRepository {
  final Preferences datasource;

  ScoreRepositoryImpl(this.datasource);

  @override
  Future<int> getHighScore() => datasource.getHighScore();

  @override
  Future<void> saveHighScore(int score) =>
      datasource.saveHighScore(score);
}