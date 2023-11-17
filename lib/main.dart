import 'package:chat_app/provider/login_Provider.dart';
import 'package:chat_app/provider/main_provider.dart';
import 'package:chat_app/provider/profile_provider.dart';
import 'package:chat_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

late Size mq;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  ).then((_) {
    _initializeFirebase();
    runApp(
      MultiProvider(
        // Using MultiProvider to manage multiple providers
        providers: [
          ChangeNotifierProvider<MyProvider>(
            create: (_) => MyProvider(), // Provide instance of MyProvider
          ),
          ChangeNotifierProvider<LoginProvider>(
            create: (_) => LoginProvider(), // Provide instance of MyProvider
          ),
          ChangeNotifierProvider<ProfileProvider>(
            create: (_) => ProfileProvider(), // Provide instance of MyProvider
          ),
          // Add more providers if needed
        ],
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Baat-Chit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreen(),
    );
  }
}

_initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showing Message Notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
  print('Notification Channel Result: $result');
}
