import 'package:flash_pattern/core/utils/preferences.dart';
import 'package:flash_pattern/data/repositories/get_highscore.dart';
import 'package:flash_pattern/data/repositories/save_highscore.dart';
import 'package:flash_pattern/data/repositories/score_repositories.dart';
import 'package:flash_pattern/data/repositories/score_repository_impl.dart';
import 'package:flash_pattern/features/game/controllers/ads_controller/ads_controller.dart';
import 'package:flash_pattern/features/game/controllers/game_controller.dart';
import 'package:flash_pattern/logic/game_engine.dart';
import 'package:get/get.dart';


class GameBinding extends Bindings {
  @override
  void dependencies() async{
    Get.put(AdController(), permanent: true);
    Get.lazyPut(() => Preferences());
    Get.lazyPut<ScoreRepository>(() => ScoreRepositoryImpl(Get.find()));
    Get.lazyPut(() => GetHighScore(Get.find()));
    Get.lazyPut(() => SaveHighScore(Get.find()));
    Get.lazyPut(() => GameEngine());
    Get.lazyPut(() => GameController(
      engine: Get.find(),
      getHighScore: Get.find(),
      saveHighScore: Get.find(),
    ));
  }
}