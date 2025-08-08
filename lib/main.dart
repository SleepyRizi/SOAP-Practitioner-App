import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Theme/app_theme.dart';
import 'firebase_options.dart';
import 'routes/app_pages.dart';
import 'bindings/initial_binding.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MVVM Firebase GetX',
      initialBinding: InitialBinding(),
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
        theme: AppTheme.light
    );
  }
}
