import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../screens/home_screen.dart';
import '../screens/signup_screen.dart';
import '../services/auth_services.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService().getUserData(context),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Center(
            child: Text('An error occurred: ${snapshot.error}'),
          );
        } else {
          return MaterialApp(
            title: 'Flutter Node Auth',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: Consumer<UserProvider>(
              builder: (ctx, userProvider, _) => userProvider.user.token.isEmpty
                  ? const SignupScreen()
                  : const HomeScreen(),
            ),
          );
        }
      },
    );
  }
}
