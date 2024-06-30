import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:uber_shop_app/controllers/categories_controller.dart';
import 'package:uber_shop_app/views/screens/auth/login_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: FirebaseOptions(
              apiKey: 'AIzaSyB7pzDBa0YYtxFxrNuUakszdubW7gWx4PA',
              appId: '1:1086554644168:android:d9211d443218a92f170ffd',
              messagingSenderId: '1086554644168',
              projectId: 'uber-shop-app-b37fc',
              storageBucket: 'uber-shop-app-b37fc.appspot.com'),
        )
      : await Firebase.initializeApp();
  Get.put(CategoryController());
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}
