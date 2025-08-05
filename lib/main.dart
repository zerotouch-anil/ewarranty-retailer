import 'package:flutter/material.dart';
import 'package:retailer_app/screens/splashscreen.dart';
import 'package:retailer_app/utils/pixelutil.dart';
import 'package:retailer_app/utils/shared_preferences.dart';

void main() async{
   WidgetsFlutterBinding.ensureInitialized(); 
  await SharedPreferenceHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    ScreenUtil.initialize(context);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Warranty Retailer',
      home: SplashScreen(),
    );
  }
}
