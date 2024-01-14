import 'package:flutter/material.dart';
import 'package:nodejs/providers/user_provider.dart';
import 'package:nodejs/screens/home_screen.dart';
import 'package:nodejs/screens/signup_screen.dart';
import 'package:nodejs/services/auth_services.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();
  @override
  void initState() {
    authService.getUserData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Node Auth',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Provider.of<UserProvider>(context).user.token.isEmpty
            ? const SignupScreen()
            : HomeScreen());
  }
}
