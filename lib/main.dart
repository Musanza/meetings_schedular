import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meetings_scheduler/firebase_options.dart';
import 'package:meetings_scheduler/widgets/bottom_navigation.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
  } catch (e, st) {
    print(e);
    print(st);
  }

  // The first step to using Firebase is to configure it so that our code can
  // find the Firebase project on the servers. This is not a security risk, as
  // explained here: https://stackoverflow.com/a/37484053
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // initialRoute: '/',
      // routes: {
      //   '/': (context) => const LoginScreen(),
      //   '/home': (context) => const HomeScreen(),
      // },
      home: BottomNavigation(),
    );
  }
}
