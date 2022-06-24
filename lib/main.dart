import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:waydchatapp/dashboard/dashboard_screen.dart';
import 'package:waydchatapp/login/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
          title: 'ChatApp',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          initialRoute: LoginScreen.name,
          routes: {
            LoginScreen.name: (ctx) => const LoginScreen(),
            DashboardScreen.name: (ctx) => DashboardScreen('', '', null),
          },
        );
  }
}
