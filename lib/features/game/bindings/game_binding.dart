import 'package:flash_pattern/core/utils/preferences.dart';
import 'package:flash_pattern/data/repositories/get_highscore.dart';
import 'package:flash_pattern/data/repositories/save_highscore.dart';
import 'package:flash_pattern/data/repositories/score_repositories.dart';
import 'package:flash_pattern/data/repositories/score_repository_impl.dart';
import 'package:flash_pattern/core/services/ad_service.dart';
import 'package:flash_pattern/core/services/consent_service.dart';
import 'package:flash_pattern/features/game/controllers/game_controller.dart';
import 'package:flash_pattern/core/logic/game_engine.dart';
import 'package:get/get.dart';

class GameBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Core Services (Early registration)
    Get.put(ConsentService(), permanent: true);
    Get.put(AdService(), permanent: true);

    // 2. Data & Repositories
    final prefs = Get.put(Preferences());
    final repository = Get.put<ScoreRepository>(ScoreRepositoryImpl(prefs));
    final getHighScore = Get.put(GetHighScore(repository));
    final saveHighScore = Get.put(SaveHighScore(repository));

    // 3. Logic & Engine
    final engine = Get.put(GameEngine());

    // 4. Main Controller
    Get.put(
      GameController(
        engine: engine,
        getHighScore: getHighScore,
        saveHighScore: saveHighScore,
      ),
      permanent: true,
    );
  }
}
