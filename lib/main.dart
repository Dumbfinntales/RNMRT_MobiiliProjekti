import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'notification_helper.dart';
import 'ruudut/home_screen.dart'; // Importataan kotiruutu

// Main.dartin tarkoitus on vain käynnistää sovellus ja näyttää kotiruutu
void main() async {WidgetsFlutterBinding.ensureInitialized();

tz.initializeTimeZones();

await NotificationHelper.initialize();

// iOS lupa
await NotificationHelper.requestIOSPermissions(); runApp(ToDoApp());} // Suorittaa sovelluksen

// Rakentaa pääsovelluksen ja näyttää home screenin
class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RNMRT ToDo App', // Sovelluksen nimi
      theme: ThemeData(
        primarySwatch: Colors.teal, // Väri teemaan, näitä voi alkaa muokkaamaan tarkemmin myöhemmin
        fontFamily: 'MyFont',),
      home: HomeScreen(), // Kotiruutu
    );
  }
}