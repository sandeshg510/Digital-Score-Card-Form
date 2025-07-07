import 'package:digital_score_card_form_for_inspection/providers/coach_cleaning_provider.dart';
import 'package:digital_score_card_form_for_inspection/providers/inspection_provider.dart';
import 'package:digital_score_card_form_for_inspection/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InspectionProvider()),
        ChangeNotifierProvider(create: (_) => CoachCleaningProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Digital Score Card',
        theme: ThemeData(
          fontFamily: 'Amazon',
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
