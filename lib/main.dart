import 'package:flutter/material.dart'; // Flutterin widgetit
import 'package:timezone/data/latest.dart' as tz; // Importataan timezone kirjasto
import 'notification_helper.dart'; // Popup yrityksestä
import 'ruudut/home_screen.dart'; // Importataan kotiruutu

// Main.dartin tarkoitus on vain käynnistää sovellus ja näyttää kotiruutu
void main() async {WidgetsFlutterBinding.ensureInitialized();

tz.initializeTimeZones(); // Alustaa aikavyöhykkeet

await NotificationHelper.initialize(); // Alustaa notifikaatiot

// iOS lupa (Jos popup olisi toiminut)
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