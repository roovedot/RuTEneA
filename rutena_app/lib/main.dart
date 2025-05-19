import 'package:flutter/material.dart';
import 'package:rutena_app/dashboard.dart';
import 'package:rutena_app/login.dart';
import 'package:rutena_app/register.dart';
import 'package:rutena_app/crear_evento.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      theme: ThemeData(
        fontFamily: 'NotoSans',
      ),

      initialRoute: '/login',
      routes: {
        '/dashboard': (context) => Dashboard(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/crearEvento': (context) => const CrearEventoPage(),
      },
    );
  }
}
