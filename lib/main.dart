import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/storage/local_storage.dart';
import 'features/settings/controllers/settings_controller.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // System UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize local storage before anything reads from it
  await LocalStorage.init();

  // Pre-register SettingsController so app.dart can reactively drive
  // both theme and darkTheme from it before GetMaterialApp is built.
  Get.put<SettingsController>(SettingsController(), permanent: true);

  // TODO: Uncomment when Firebase is configured:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const BuildOSApp());
}
