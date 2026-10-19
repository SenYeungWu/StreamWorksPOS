import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/core/routing/app_router.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'Stream Works',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.grey[50],
          primaryColor: Colors.deepOrangeAccent,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrangeAccent,
            primary: Colors.deepOrangeAccent,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.deepOrangeAccent,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
